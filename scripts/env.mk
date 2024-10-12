ENV_HOME = $(SIM_HOME)/env

CSRCS := $(shell find $(ENV_HOME) -name "*.cc")
ifeq ($(COSIM),yes)
CSRCS := $(filter-out $(ENV_HOME)/tiny_platform_main.cc, $(CSRCS))
else
CSRCS := $(filter-out $(ENV_HOME)/tiny_platform_cosim_main.cc, $(CSRCS))
endif

CSRCS_INC := $(shell find $(ENV_HOME) -name "*.h")
