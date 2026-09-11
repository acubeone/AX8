FPGA_DIR  := fpga
SRC_DIR   := $(FPGA_DIR)/src
TB_DIR    := $(FPGA_DIR)/tb
BUILD_DIR := build

IVERILOG   := iverilog # Path to the icarus-verilog binary
VVP        := vvp      # Path to the vvp binary
WAVEVIEWER := gtkwave  # Path to the wave-viewer binary

IFLAGS   := -g2012 -Wall -f $(FPGA_DIR)/common.vf

SRCS    := $(wildcard $(SRC_DIR)/*.sv)
TB_SRCS := $(wildcard $(TB_DIR)/*_tb.sv)

MODULES := $(patsubst $(TB_DIR)/%_tb.sv,%,$(TB_SRCS)) # Extract base name from files
SIMS    := $(patsubst %,$(BUILD_DIR)/%_sim,$(MODULES))
VCDS    := $(patsubst %,$(BUILD_DIR)/%.vcd,$(MODULES))

.PHONY: all
all: $(SIMS) $(VCDS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Generate simulators
$(BUILD_DIR)/%_sim: $(FPGA_DIR)/common.vf $(FPGA_DIR)/build.vf $(SRCS) $(TB_DIR)/%_tb.sv | $(BUILD_DIR)
	$(IVERILOG) $(IFLAGS) -s $*_tb -o $@

# Run simulation and generate waveforms
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/%_sim
	cd $(BUILD_DIR) && $(VVP) $(notdir $<)
	@echo "== $* simulation complete =="

# Compile just one file (e.g. 'make full_adder')
.PHONY: $(MODULES)
$(MODULES): %: $(BUILD_DIR)/%.vcd

# View waveforms with GTKWave (e.g. 'make wave_full_adder')
.PHONY: wave_%
wave_%: $(BUILD_DIR)/%.vcd
	$(WAVEVIEWER) $^ > /dev/null 2>&1 &

.PRECIOUS: $(SIMS) $(VCDS)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: list
list:
	@echo "Available modules:"
	@for m in $(MODULES); do echo "  $$m"; done
