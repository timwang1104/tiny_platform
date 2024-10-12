#pragma once
#include <svdpi.h>
#include <cassert>
#include <memory>
#include "cosim.h"
#include "tiny_emulator.h"
#include "spike_cosim.h"
#include "verilator_memutil.h"

class TinyEmulatorCosim : public TinyEmulator {
  public:
    TinyEmulatorCosim(const char *ram_hier_path, int ram_size_words);
    virtual ~TinyEmulatorCosim() {};

    std::unique_ptr<SpikeCosim> _cosim;
    void CreateCosim(bool secure_tiny, bool icache_en, uint32_t pmp_num_regions,
                   uint32_t pmp_granularity, uint32_t mhpm_counter_num);

  protected:
    void CopyMemAreaToCosim(MemArea *area, uint32_t base_addr);

    virtual int SetUp(int argc, char **argv, bool &exit_app) override;
    virtual bool Finish() override;
};
