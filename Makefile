# Bluespec SystemVerilog Makefile

# Project configuration
PROJECT_NAME ?= example
BSC_FLAGS = -aggressive-conditions -show-schedule -show-module-use
VERILATOR_FLAGS = --cc --exe --build --trace

# Directories
SRC_DIR = src
TB_DIR = tb
SIM_DIR = sim
BUILD_DIR = $(SIM_DIR)/build
SCRIPT_DIR = scripts

# Source files
BSV_SOURCES = $(wildcard $(SRC_DIR)/**/*.bsv $(SRC_DIR)/*.bsv)
TB_SOURCES = $(wildcard $(TB_DIR)/**/*.bsv $(TB_DIR)/*.bsv)

# Default target
.PHONY: all
all: build

# Create necessary directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build BSV modules
.PHONY: build
build: $(BUILD_DIR)
	@echo "Building BSV modules..."
	bsc $(BSC_FLAGS) -bdir $(BUILD_DIR) -vdir $(BUILD_DIR) -simdir $(BUILD_DIR) \
		-p $(SRC_DIR):$(TB_DIR):+ -g mk$(PROJECT_NAME) $(SRC_DIR)/$(PROJECT_NAME)/*.bsv

# Generate Verilog
.PHONY: verilog
verilog: build
	@echo "Generating Verilog..."
	bsc $(BSC_FLAGS) -verilog -vdir $(BUILD_DIR) -bdir $(BUILD_DIR) \
		-p $(SRC_DIR):+ -g mk$(PROJECT_NAME) $(SRC_DIR)/$(PROJECT_NAME)/*.bsv

# Simulate with Bluesim
.PHONY: sim-bluesim
sim-bluesim: build
	@echo "Running Bluesim simulation..."
	bsc $(BSC_FLAGS) -sim -simdir $(BUILD_DIR) -bdir $(BUILD_DIR) \
		-p $(SRC_DIR):$(TB_DIR):+ -g mk$(PROJECT_NAME)TB $(TB_DIR)/$(PROJECT_NAME)/*.bsv
	cd $(BUILD_DIR) && ./mk$(PROJECT_NAME)TB

# Simulate with Verilator
.PHONY: sim-verilator
sim-verilator: verilog
	@echo "Running Verilator simulation..."
	cd $(BUILD_DIR) && verilator $(VERILATOR_FLAGS) --top-module mk$(PROJECT_NAME) \
		mk$(PROJECT_NAME).v -o V$(PROJECT_NAME)
	cd $(BUILD_DIR) && ./V$(PROJECT_NAME)

# Default simulation target (Bluesim)
.PHONY: sim
sim: sim-bluesim

# View waveforms
.PHONY: wave
wave:
	@if [ -f $(BUILD_DIR)/dump.vcd ]; then \
		gtkwave $(BUILD_DIR)/dump.vcd; \
	else \
		echo "No VCD file found. Run simulation first."; \
	fi

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -rf $(BUILD_DIR)
	rm -f *.bo *.ba

# Deep clean (including sim directory)
.PHONY: distclean
distclean: clean
	rm -rf $(SIM_DIR)

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all           - Build all modules (default)"
	@echo "  build         - Compile BSV modules"
	@echo "  verilog       - Generate Verilog from BSV"
	@echo "  sim           - Run simulation (Bluesim)"
	@echo "  sim-bluesim   - Run Bluesim simulation"
	@echo "  sim-verilator - Run Verilator simulation"
	@echo "  wave          - View waveforms with GTKWave"
	@echo "  clean         - Clean generated files"
	@echo "  distclean     - Deep clean all build outputs"
	@echo "  help          - Show this help"
	@echo ""
	@echo "Variables:"
	@echo "  PROJECT_NAME  - Name of the project/module (default: example)"