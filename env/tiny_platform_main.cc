#include "tiny_emulator.h"

int main(int argc, char **argv) {
  TinyEmulator TinyEmulator(
      "TOP.tiny_platform.u_ram.u_ram.gen_generic.u_impl_generic",
      1024 * 1024);
  return TinyEmulator.Main(argc, argv);
}

