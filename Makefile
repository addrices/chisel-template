.PHONY: all emu clean-all run-emu

OBJ_DIR := output
SRC_DIR := src
SCALA_FILES := $(shell find $(SRC_DIR) -name "*.scala")
WAVE_VIEWER := gtkwave
LOG_FILE := logs/vlt_dump.vcd
V_FILES := $(shell find $(SRC_DIR) -name "*.v")
SV_FILES := $(shell find $(SRC_DIR) -name "*.sv")

EMU_SRC_DIR := emu
EMU_INCLUDEPATH := $(EMU_SRC_DIR)/include
EMU_TOP_MODULE := top
EMU_TOP_V := $(OBJ_DIR)/emu_top.v
EMU_MK := $(OBJ_DIR)/emu.mk
EMU_BIN := $(OBJ_DIR)/emulator
EMU_CXXFILES := $(shell find $(EMU_SRC_DIR) -name "*.cpp")
EMU_HFILES := $(shell find $(EMU_SRC_DIR) -name "*.h")

VERILATOR_TRACE ?= true
VERILATOR_GDB ?= true
VERILATOR = verilator
# Create C++ output,Link to create executable, set top module, 
VERILATOR_FLAGS = --cc --exe --top-module $(EMU_TOP_MODULE) -O2 
# set target dir, set output execute filename, set top level class name ,set CFLAGS
VERILATOR_FLAGS += --Mdir $(OBJ_DIR) -o $(notdir $(EMU_BIN)) --prefix $(basename $(notdir $(EMU_MK)))  -CFLAGS "-I $(EMU_INCLUDEPATH) "
# trace
ifeq ($(VERILATOR_TRACE), true)
	VERILATOR_FLAGS += --trace -CFLAGS "-D __TRACE__" 
	EMU_ARGC += +trace
endif
# gdb
ifeq ($(VERILATOR_GDB), true)
	VERILATOR_FLAGS += -CFLAGS -g
endif

emu: $(EMU_BIN)
run-emu: emu
	@$(EMU_BIN) $(EMU_ARGC)

$(EMU_TOP_V): $(SCALA_FILES)
	@mkdir -p $(@D)
	@sbt "run MainDriver -X verilog -td $(@D) -o $(notdir $@)"

$(EMU_MK): $(EMU_TOP_V) $(SV_FILES) $(V_FILES) $(EMU_CXXFILES) $(EMU_HFILES)
	@verilator $(VERILATOR_FLAGS) $(V_FILES) $(EMU_TOP_V) $(SV_FILES) $(EMU_CXXFILES)

$(EMU_BIN): $(EMU_MK) $(EMU_CXXFILES) $(EMU_HFILES)
	@cd $(@D) && make -s -f $(notdir $<)

show: run-emu
	@$(WAVE_VIEWER) $(LOG_FILE)

clean-all:
	rm -rf $(OBJ_DIR) $(LOG_FILE)
