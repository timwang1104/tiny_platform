// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
`include "cosim_dpi.svh"
`include "defines.vh"
module tiny_platform_cosim_checker #(
  parameter bit                 SecureTiny     = 1'b0,
  parameter bit                 ICache         = 1'b0,
  parameter bit                 PMPEnable      = 1'b0,
  parameter int unsigned        PMPGranularity = 0,
  parameter int unsigned        PMPNumRegions  = 4,
  parameter int unsigned        MHPMCounterNum  = 0
) (
  input clk_i,
  input rst_ni,

  input logic        host_dmem_req,
  input logic        host_dmem_gnt,
  input logic        host_dmem_we,
  input logic [31:0] host_dmem_addr,
  input logic [3:0]  host_dmem_be,
  input logic [31:0] host_dmem_wdata,

  input logic        host_dmem_rvalid,
  input logic [31:0] host_dmem_rdata,
  input logic        host_dmem_err
);
  import "DPI-C" function chandle get_spike_cosim;
  import "DPI-C" function void create_cosim(bit secure_tiny, bit icache_en,
    bit [31:0] pmp_num_regions, bit [31:0] pmp_granularity, bit [31:0] mhpm_counter_num);

  /*verilator tracing_off*/
  chandle cosim_handle;
  /*verilator tracing_on*/
  int result;

  initial begin
    localparam int unsigned LocalPMPGranularity = PMPEnable ? PMPGranularity : 0;
    localparam int unsigned LocalPMPNumRegions  = PMPEnable ? PMPNumRegions  : 0;

    create_cosim(SecureTiny, ICache, LocalPMPNumRegions, LocalPMPGranularity, MHPMCounterNum);
    cosim_handle = get_spike_cosim();
  end

  always @(posedge clk_i) begin
    if (u_top.rvfi_valid) begin
      riscv_cosim_set_nmi(cosim_handle, u_top.rvfi_ext_nmi);
      riscv_cosim_set_nmi_int(cosim_handle, u_top.rvfi_ext_nmi_int);
      riscv_cosim_set_mip(cosim_handle, u_top.rvfi_ext_mip);
      riscv_cosim_set_debug_req(cosim_handle, u_top.rvfi_ext_debug_req);
      riscv_cosim_set_mcycle(cosim_handle, u_top.rvfi_ext_mcycle);
      for (int i=0; i < 10; i++) begin
        riscv_cosim_set_csr(cosim_handle, int'(`CSR_MHPMCOUNTER3) + i,
          u_top.rvfi_ext_mhpmcounters[i]);
        riscv_cosim_set_csr(cosim_handle, int'(`CSR_MHPMCOUNTER3H) + i,
          u_top.rvfi_ext_mhpmcountersh[i]);
      end
      riscv_cosim_set_ic_scr_key_valid(cosim_handle, u_top.rvfi_ext_ic_scr_key_valid);

      result = riscv_cosim_step(cosim_handle, u_top.rvfi_rd_addr, u_top.rvfi_rd_wdata,
                           u_top.rvfi_pc_rdata, u_top.rvfi_trap,
                           u_top.rvfi_ext_rf_wr_suppress);
      if (result == 0)
      begin
        $display("FAILURE: Co-simulation mismatch at time %t", $time());
        for (int i = 0;i < riscv_cosim_get_num_errors(cosim_handle); ++i) begin
          $display(riscv_cosim_get_error(cosim_handle, i));
        end
        riscv_cosim_clear_errors(cosim_handle);

        $fatal(1, "Co-simulation mismatch seen");
      end
    end
  end

  logic outstanding_store;
  logic [31:0] outstanding_addr;
  logic [3:0] outstanding_be;
  logic [31:0] outstanding_store_data;
  logic outstanding_misaligned_first;
  logic outstanding_misaligned_second;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      outstanding_store <= 1'b0;
    end else begin
      if (host_dmem_req && host_dmem_gnt) begin
        outstanding_store      <= host_dmem_we;
        outstanding_addr       <= host_dmem_addr;
        outstanding_be         <= host_dmem_be;
        outstanding_store_data <= host_dmem_wdata;
        outstanding_misaligned_first <=
          u_top.u_tiny_top.u_tiny_core.u_tiny_execute.u_tiny_lsu.handle_misaligned_d |
          ((u_top.u_tiny_top.u_tiny_core.u_tiny_execute.u_tiny_lsu.lsu_type == 2'b01) &
           (u_top.u_tiny_top.u_tiny_core.u_tiny_execute.u_tiny_lsu.data_offset == 2'b01));

        outstanding_misaligned_second <=
          u_top.u_tiny_top.u_tiny_core.u_tiny_execute.u_tiny_lsu.addr_incr_req_o;
      end

      if (host_dmem_rvalid) begin
        riscv_cosim_notify_dside_access(cosim_handle, outstanding_store, outstanding_addr,
          outstanding_store ? outstanding_store_data : host_dmem_rdata, outstanding_be,
          host_dmem_err, outstanding_misaligned_first, outstanding_misaligned_second);
      end
    end
  end
endmodule
