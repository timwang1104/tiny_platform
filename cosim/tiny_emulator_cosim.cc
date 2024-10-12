#include "tiny_emulator_cosim.h"

TinyEmulatorCosim::TinyEmulatorCosim(const char *ram_hier_path, int ram_size_words)
    : TinyEmulator(ram_hier_path, ram_size_words), _cosim(nullptr) {}


void TinyEmulatorCosim::CreateCosim(bool secure_tiny, bool icache_en, uint32_t pmp_num_regions,
                   uint32_t pmp_granularity, uint32_t mhpm_counter_num) {
    _cosim = std::make_unique<SpikeCosim>(
        GetIsaString(), 0x100080, 0x100001, "tiny_emulator_cosim.log",
        secure_tiny, icache_en, pmp_num_regions, pmp_granularity,
        mhpm_counter_num);

    _cosim->add_memory(0x100000, 1024 * 1024);
    _cosim->add_memory(0x20000, 4096);

    CopyMemAreaToCosim(&_ram, 0x100000);
}

void TinyEmulatorCosim::CopyMemAreaToCosim(MemArea *area, uint32_t base_addr) {
    auto mem_data = area->Read(0, area->GetSizeWords());
    _cosim->backdoor_write_mem(base_addr, area->GetSizeBytes(), &mem_data[0]);
}

int TinyEmulatorCosim::SetUp(int argc, char **argv, bool &exit_app) {
    int ret_code = TinyEmulator::SetUp(argc, argv, exit_app);
    if (exit_app) {
        return ret_code;
    }

    return 0;
}

bool TinyEmulatorCosim::Finish() {
    std::cout << "Co-simulation matched " << _cosim->get_insn_cnt()
              << " instructions\n" << std::endl;

    return TinyEmulator::Finish();
}
