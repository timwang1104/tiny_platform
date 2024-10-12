# Verilator flags
TOPNAME = tiny_platform
VERILATOR = verilator
VERILATOR_FLAGS = --top-module $(TOPNAME)

# Source and build directories
SIM_HOME = $(TINY_HOME)/examples/tiny_platform
BUILD_DIR = $(SIM_HOME)/build

# Build files
OBJ_DIR = $(BUILD_DIR)/obj_dir

# Read cc source files
CSRCS := $(shell find $(SIM_HOME)/csrcs -name "*.cc")
CSRCS_INC := $(shell find $(SIM_HOME)/csrcs -name "*.h")

# Read verilog source files
VSRCS := $(shell find $(SIM_HOME)/rtl -name "*.sv")
VSRCS_INC := $(shell find $(TINY_HOME)/shared/util -name "*.svh" -or -name "*.vh")

# Read core files
include $(TINY_HOME)/rtl/core.mk

# Read common files
include $(SIM_HOME)/scripts/shared.mk

# Read dv source files
include $(TINY_HOME)/vendor/lowrisc_ip/dv/verilator/verilator.mk
include $(SIM_HOME)/scripts/pcount.mk
include $(SIM_HOME)/scripts/cosim.mk

# test image
IMAGE = $(TINY_HOME)/examples/tiny_sdk/software/hello_world/hello_world.elf

# Libraries
LIBS += "-lelf -ldl"

all: run

app: verilate
# Add TOPLEVEL_NAME macro define
	echo 'CXXFLAGS+=-D TOPLEVEL_NAME=$(TOPNAME)' > V$(TOPNAME).mk.tmp
	cat $(OBJ_DIR)/V$(TOPNAME).mk >> V$(TOPNAME).mk.tmp
	mv V$(TOPNAME).mk.tmp $(OBJ_DIR)/V$(TOPNAME).mk
	make -C $(OBJ_DIR) -f V$(TOPNAME).mk V$(TOPNAME) LIBS=${LIBS}

verilate:
	mkdir -p $(OBJ_DIR)
	cp -u $(VSRCS_INC) $(OBJ_DIR)/ || true
	cp -u $(CSRCS_INC) $(OBJ_DIR)/ || true
	$(VERILATOR) -cc $(VSRCS) -Mdir $(OBJ_DIR) $(VERILATOR_FLAGS) --exe $(CSRCS) --trace

run: app
	$(OBJ_DIR)/V$(TOPNAME) -t --meminit=ram,$(IMAGE)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean