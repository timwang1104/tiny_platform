COSIM_HOME = $(TINY_HOME)/dv/verilator/simple_system_cosim

$(info #Collecting COSIM Files)
CSRCS += $(shell find $(COSIM_HOME) -name "*.cc")
CSRCS += $(shell find $(TINY_HOME)/dv/cosim -name "*.cc")
CSRCS_INC += $(shell find $(TINY_HOME)/dv/cosim -name "*.h")
VSRCS += $(shell find $(COSIM_HOME) -name "*.sv")
VSRCS_INC += $(shell find $(TINY_HOME)/dv/cosim -name "*.svh")

SPIKE ?= $(TINY_HOME)/vendor/riscv-isa-sim-cosim
VERILATOR_FLAGS += +define+RVFI=1
VERILATOR_FLAGS += -CFLAGS -I$(SPIKE)
VERILATOR_FLAGS += -CFLAGS -I$(SPIKE)/softfloat
VERILATOR_FLAGS += -CFLAGS -I$(SPIKE)/build

SPIKE_OBJS := libspike_main.a  libriscv.a  libdisasm.a  libsoftfloat.a  libfesvr.a  libfdt.a
SPIKE_OBJS :=$(addprefix $(SPIKE)/build/,${SPIKE_OBJS})

CSRCS += ${SPIKE_OBJS}

