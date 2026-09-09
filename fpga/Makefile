SRC_DIR   := src
TB_DIR    := tb
BUILD_DIR := build

IVERILOG := iverilog # Path to the icarus-verilog binary
VVP      := vvp      # Path to the vvp binary
GTKWAVE  := gtkwave  # Path to the gtkwave binary

IFLAGS   := -g2012 -Wall

BUILDFILES := $(filter-out $(TB_DIR)/common.f, $(wildcard $(TB_DIR)/*.f))
MODULES    := $(patsubst $(TB_DIR)/%.f,%,$(BUILDFILES)) # Extract basename from buildfile

SIMS := $(patsubst %,$(BUILD_DIR)/%_sim,$(MODULES))
VCDS := $(patsubst %,$(BUILD_DIR)/%.vcd,$(MODULES))

.PHONY: all
all: $(SIMS) $(VCDS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Generate simulators
$(BUILD_DIR)/%_sim: $(TB_DIR)/%.f $(TB_DIR)/common.f | $(BUILD_DIR)
	$(IVERILOG) $(IFLAGS) -f $< -o $@

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
	$(GTKWAVE) -O /dev/null $^ &

.PRECIOUS: $(SIMS) $(VCDS)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
