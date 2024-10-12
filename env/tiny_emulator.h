#pragma once
#include "verilated_toplevel.h"
#include "verilator_memutil.h"

#define MAX_SIM_TIME 250

class TinyEmulator
{
  public:
    TinyEmulator(const char *ram_hier_path, int ram_size_words);
    virtual ~TinyEmulator() {};
    virtual int Main(int argc, char **argv);

    // Return an ISA string, as understood by Spike, for the system being
    // simulated.
    std::string GetIsaString() const;
  protected:
    tiny_platform _top;
    VerilatorMemUtil _memutil;
    MemArea _ram;

    virtual int SetUp(int argc, char **argv, bool &exit_app);
    virtual void Run();
    virtual bool Finish();
};

