#include "tiny_emulator_cosim.h"

bool TinyEmulatorCosim::Finish() {
    std::cout << "Co-simulation matched " << _cosim->get_insn_cnt()
              << " instructions\n";

    return TinyEmulator::Finish();
}
