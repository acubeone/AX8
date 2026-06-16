SRC_DIR   := src
TB_DIR    := tb
BUILD_DIR := build

IVERILOG := iverilog # Path to the icarus-verilog binary
VVP      := vvp      # Path to the vvp binary
GTKWAVE  := gtkwave  # Path to the gtkwave binary

FILELIST := files.f

IFLAGS := -g2012 -Wall

# Each entry: name of module = name of .v file (without extension)
MODULES := d_latch d_flipflop mux_2to1 register_8 full_adder ripple_adder_4 ripple_adder_8
MODULES += adder_subtractor

SRC_FILES := $(patsubst %,$(SRC_DIR)/%.v,$(MODULES))
TB_FILES  := $(patsubst %,$(TB_DIR)/%_tb.v,$(MODULES))

SIMS := $(patsubst %,$(BUILD_DIR)/%_sim,$(MODULES))
VCDS := $(patsubst %,$(BUILD_DIR)/%.vcd,$(MODULES))

.PHONY: all
all: $(SIMS) $(VCDS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Generate simulators
$(BUILD_DIR)/%_sim: $(SRC_DIR)/%.v $(TB_DIR)/%_tb.v $(FILELIST) | $(BUILD_DIR)
	$(IVERILOG) $(IFLAGS) -f $(FILELIST) -o $@ $(TB_DIR)/$*_tb.v

# Generate waveforms
$(BUILD_DIR)/%.vcd: $(BUILD_DIR)/%_sim
	cd $(BUILD_DIR) && $(VVP) $(notdir $<)
	@echo "== $* simulation complete =="

# View waveforms with GTKWave
.PHONY: wave_%
wave_%: $(BUILD_DIR)/%.vcd
	$(GTKWAVE) -O /dev/null $^ &

.PRECIOUS: $(SIMS) $(VCDS)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
