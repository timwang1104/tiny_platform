#include "TinyEmulator.h"

int main(int argc, char **argv) {
  TinyEmulator TinyEmulator(
      "TOP.TinyPlatform.u_ram.u_ram.gen_generic.u_impl_generic",
      1024 * 1024);

  return TinyEmulator.main(argc, argv);
}

