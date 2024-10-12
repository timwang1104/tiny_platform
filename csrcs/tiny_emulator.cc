#include <cassert>
#include <fstream>
#include <iostream>

#include "VTinyEmulator__Syms.h"
#include "tiny_pcounts.h"
#include "tiny_emulator.h"
#include "verilator_sim_ctrl.h"

TinyEmulator::TinyEmulator(const char *ram_hier_path, int ram_size_words)
    : _ram(ram_hier_path, ram_size_words, 4) {}

std::string TinyEmulator::GetIsaString() const {
  const VTinyEmulator &top = _top;
  assert(top.TinyEmulator);

  std::string base = "rv32i";

  std::string extensions;

  extensions += "m";
  extensions += "c";
  return base + extensions;
}

int TinyEmulator::SetUp(int argc, char **argv, bool &exit_app) {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

  simctrl.SetTop(&_top, &_top.IO_CLK, &_top.IO_RST_N, 
                 VerilatorSimCtrlFlags::ResetPolarityNegative);

  _memutil.RegisterMemoryArea("ram", 0x0, &_ram);
  simctrl.RegisterExtension(&_memutil);
  exit_app = false;
  return simctrl.ParseCommandArgs(argc, argv, exit_app);
}

int TinyEmulator::Main(int argc, char **argv) {
  bool exit_app;
  int ret_code = SetUp(argc, argv, exit_app);

  if (exit_app) {
    return ret_code;
  }

  Run();

  if (!Finish()) {
    return 1;
  }

  return 0;
}


void TinyEmulator::Step() {

}



void TinyEmulator::Run() {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();

  std::cout << "Simulation of tiny" << std::endl
            << "==================" << std::endl
            << std::endl;

  simctrl.RunSimulation();
}

bool TinyEmulator::Finish() {
  VerilatorSimCtrl &simctrl = VerilatorSimCtrl::GetInstance();


  if (!simctrl.WasSimulationSuccessful()) {
    return false;
  }

  // Set the scope to the root scope, the tiny_pcount_string function otherwise
  // doesn't know the scope itself. Could be moved to tiny_pcount_string, but
  // would require a way to set the scope name from here, similar to MemUtil.
  svSetScope(svGetScopeFromName("TOP.tiny_simple_system"));

  std::cout << "\nPerformance Counters" << std::endl
            << "====================" << std::endl;
  std::cout << tiny_pcount_string(false);

  std::ofstream pcount_csv("tiny_emulator.csv");
  pcount_csv << tiny_pcount_string(true);

  return true;
}
