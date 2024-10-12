$(info #Collecting DV Files)
CSRCS_INC += $(shell find $(TINY_HOME)/dv/verilator/pcount -name "*.h")
CSRCS += $(shell find $(TINY_HOME)/dv/verilator/pcount -name "*.cc")