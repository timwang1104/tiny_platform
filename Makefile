# Verilator flags
TOPNAME = tiny_platform
VERILATOR = verilator
VERILATOR_FLAGS = --top-module $(TOPNAME)

# Source and build directories
SIM_HOME = $(TINY_HOME)/examples/tiny_platform
BUILD_DIR = $(SIM_HOME)/build

# Build files
OBJ_DIR = $(BUILD_DIR)/obj_dir

# Read env source files
include $(SIM_HOME)/scripts/env.mk

# Read core files
include $(TINY_HOME)/rtl/core.mk

# Read common files
include $(SIM_HOME)/scripts/shared.mk

# Read dv source files
include $(TINY_HOME)/vendor/lowrisc_ip/dv/verilator/verilator.mk
include $(SIM_HOME)/scripts/pcount.mk

ifeq ($(COSIM),yes)
include $(SIM_HOME)/scripts/cosim.mk
endif


# test image
# IMAGE = $(TINY_HOME)/examples/tiny_sdk/software/hello_world/hello_world.elf
IMAGE = $(TINY_HOME)/examples/sw/simple_system/hello_test/hello_test.elf

# Libraries
ifeq ($(COSIM),yes)
LIBS += "-lelf -ldl -lpthread -lboost_system -lboost_regex"
else
LIBS += "-lelf -ldl"
endif

$(info LIBS = $(LIBS))

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