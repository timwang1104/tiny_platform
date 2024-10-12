#include "tiny_emulator_cosim.h"

TinyEmulatorCosim *tiny_platform_cosim;

extern "C" {
void *get_spike_cosim() {
  assert(tiny_platform_cosim);
  assert(tiny_platform_cosim->_cosim);

  return static_cast<Cosim *>(tiny_platform_cosim->_cosim.get());
}

void create_cosim(svBit secure_tiny, svBit icache_en,
                  const svBitVecVal *pmp_num_regions,
                  const svBitVecVal *pmp_granularity,
                  const svBitVecVal *mhpm_counter_num) {
  assert(tiny_platform_cosim);
  tiny_platform_cosim->CreateCosim(secure_tiny, icache_en, pmp_num_regions[0],
                                   pmp_granularity[0], mhpm_counter_num[0]);
}
}

int main(int argc, char **argv) {
  tiny_platform_cosim = new TinyEmulatorCosim(
      "TOP.tiny_platform.u_ram.u_ram.gen_generic.u_impl_generic",
      (1024 * 1024) / 4);

  int ret_code = tiny_platform_cosim->Main(argc, argv);

  delete tiny_platform_cosim;

  return ret_code;
}
