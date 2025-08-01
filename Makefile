# Makefile for BSV + Verilator simulation project
# BSV sources in bsv_src/, Verilator simulation in verilator_src/

# Project configuration
TOP_MODULE ?= mkCounter
TOP_FILE ?= Counter.bsv
BSV_SRC_DIR = bsv_src
VERILATOR_SRC_DIR = verilator_src
WAVES_DIR = waves

# Tools
BSV_BUILD = ./bsvbuild.sh
VERILATOR = verilator
GTKWAVE = gtkwave
MAKE = make

# Verilator configuration
VERILATOR_FLAGS = --cc --exe --build --trace -j 0
VERILATOR_FLAGS += -Wall -Wno-UNUSED -Wno-UNOPTFLAT
VERILATOR_FLAGS += --top-module $(TOP_MODULE)
VERILATOR_WARNINGS = -Wno-WIDTH -Wno-CASEINCOMPLETE -Wno-CASEX

# Files and directories
BSV_FILES = $(shell find $(BSV_SRC_DIR) -name "*.bsv" 2>/dev/null)
CPP_FILES = $(shell find $(VERILATOR_SRC_DIR) -name "*.cc" 2>/dev/null)
VERILOG_FILES = $(BSV_SRC_DIR)/$(TOP_MODULE).v
VERILATOR_MAKEFILE = obj_dir/V$(TOP_MODULE)
SIMULATION_EXE = obj_dir/V$(TOP_MODULE)
VCD_FILE = $(WAVES_DIR)/simulation.vcd

.PHONY: all clean help dirs bsv-compile bsv-sim verilator-build verilator-sim wave status

# Default target
all: help

help:
	@echo "🚀 BSV + Verilator Simulation Project"
	@echo ""
	@echo "📋 Available targets:"
	@echo "  bsv-compile     - Generate Verilog from BSV using bsvbuild.sh"
	@echo "  bsv-sim         - Run BSV simulation with bsvbuild.sh"
	@echo "  verilator-build - Build Verilator C++ simulation"
	@echo "  verilator-sim   - Run Verilator simulation"
	@echo "  wave           - Open waveform viewer (GTKWave)"
	@echo "  clean          - Clean all generated files"
	@echo "  dirs           - Create necessary directories"
	@echo "  status         - Show project status"
	@echo ""
	@echo "📁 Project structure:"
	@echo "  $(BSV_SRC_DIR)/         - BSV source files"
	@echo "  $(VERILATOR_SRC_DIR)/   - Verilator C++ simulation files"
	@echo "  $(WAVES_DIR)/           - Generated waveform files"
	@echo "  obj_dir/               - Verilator build directory"
	@echo ""
	@echo "🔧 Usage examples:"
	@echo "  make bsv-compile                              # Generate Verilog from .bsv"
	@echo "  make verilator-sim                            # Full build and run mkXXX simulation"
	@echo "  make wave                                     # View waveforms"

# Create necessary directories
dirs:
	@echo "📁 Creating directories..."
	@mkdir -p $(WAVES_DIR)

# Generate Verilog from BSV using bsvbuild.sh
bsv-compile: dirs
	@echo "🔄 Compiling BSV to Verilog..."
	@if [ ! -f "$(BSV_SRC_DIR)/$(TOP_FILE)" ]; then \
		echo "❌ Error: $(BSV_SRC_DIR)/$(TOP_FILE) not found!"; \
		echo "Available BSV files:"; \
		find $(BSV_SRC_DIR) -name "*.bsv" 2>/dev/null || echo "  (none found)"; \
		exit 1; \
	fi
	@cd $(BSV_SRC_DIR) && ../$(BSV_BUILD) -v $(TOP_MODULE) $(TOP_FILE) || true
	@if [ -f "$(VERILOG_FILES)" ]; then \
		echo "✅ Verilog generated: $(VERILOG_FILES)"; \
	else \
		echo "❌ Error: Failed to generate Verilog"; \
		exit 1; \
	fi

# Run BSV simulation with waveform generation
bsv-sim: dirs
	@echo "🏃 Running BSV simulation..."
	@if [ ! -f "$(BSV_SRC_DIR)/$(TOP_FILE)" ]; then \
		echo "❌ Error: $(BSV_SRC_DIR)/$(TOP_FILE) not found!"; \
		exit 1; \
	fi
	@cd $(BSV_SRC_DIR) && ../$(BSV_BUILD) -bsw $(TOP_MODULE) $(TOP_FILE)
	@echo "✅ BSV simulation completed"

# Build Verilator simulation
verilator-build: $(VERILOG_FILES)
	@echo "🔨 Building Verilator simulation..."
	@if [ ! -f "$(VERILOG_FILES)" ]; then \
		echo "🔄 Verilog not found, generating from BSV first..."; \
		$(MAKE) bsv-compile; \
	fi
	@if [ -z "$(CPP_FILES)" ]; then \
		echo "❌ Error: No C++ files found in $(VERILATOR_SRC_DIR)/"; \
		echo "Please create main.cpp in $(VERILATOR_SRC_DIR)/"; \
		exit 1; \
	fi
	@mkdir -p $(WAVES_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_WARNINGS) \
		$(VERILOG_FILES) \
		$(CPP_FILES)
	@echo "✅ Verilator simulation built: $(SIMULATION_EXE)"

# Run Verilator simulation
verilator-sim: verilator-build
	@echo "🏃 Running Verilator simulation..."
	@mkdir -p $(WAVES_DIR)
	$(SIMULATION_EXE)
	@echo "✅ Verilator simulation completed"
	@if [ -f "$(VCD_FILE)" ]; then \
		echo "📊 Waveform saved: $(VCD_FILE)"; \
	fi

# Open waveform viewer
wave:
	@if [ -f "$(VCD_FILE)" ]; then \
		echo "📊 Opening Verilator waveform: $(VCD_FILE)"; \
		$(GTKWAVE) $(VCD_FILE) & \
	elif [ -f "$(BSV_SRC_DIR)/$(TOP_MODULE)_bw.vcd" ]; then \
		echo "📊 Opening BSV waveform: $(BSV_SRC_DIR)/$(TOP_MODULE)_bw.vcd"; \
		$(GTKWAVE) $(BSV_SRC_DIR)/$(TOP_MODULE)_bw.vcd & \
	else \
		echo "❌ No waveform files found!"; \
		echo "Available waveform files:"; \
		find . -name "*.vcd" 2>/dev/null || echo "  (none found)"; \
		echo "Run 'make verilator-sim' or 'make bsv-sim' first."; \
	fi

# Show project status
status:
	@echo "📊 Project Status"
	@echo "=================="
	@echo "TOP_MODULE: $(TOP_MODULE)"
	@echo "TOP_FILE: $(TOP_FILE)"
	@echo ""
	@echo "📁 Files:"
	@echo "  BSV files in $(BSV_SRC_DIR)/: $$(find $(BSV_SRC_DIR) -name '*.bsv' 2>/dev/null | wc -l)"
	@echo "  C++ files in $(VERILATOR_SRC_DIR)/: $$(find $(VERILATOR_SRC_DIR) -name '*.cpp' 2>/dev/null | wc -l)"
	@echo "  Verilog files: $$(find $(BSV_SRC_DIR) -name '*.v' 2>/dev/null | wc -l)"
	@echo "  Wave files: $$(find . -name '*.vcd' 2>/dev/null | wc -l)"
	@echo ""
	@echo "🔧 Tools:"
	@echo "  bsc: $$(which bsc 2>/dev/null || echo 'not found')"
	@echo "  verilator: $$(which verilator 2>/dev/null || echo 'not found')"
	@echo "  gtkwave: $$(which gtkwave 2>/dev/null || echo 'not found')"
	@echo ""
	@echo "📋 Build status:"
	@if [ -f "$(VERILOG_FILES)" ]; then \
		echo "  ✅ Verilog generated: $(VERILOG_FILES)"; \
	else \
		echo "  ❌ Verilog not found: $(VERILOG_FILES)"; \
	fi
	@if [ -f "$(SIMULATION_EXE)" ]; then \
		echo "  ✅ Verilator executable built: $(SIMULATION_EXE)"; \
	else \
		echo "  ❌ Verilator executable not found: $(SIMULATION_EXE)"; \
	fi

# Ensure Verilog is regenerated when BSV files change
$(VERILOG_FILES): $(BSV_FILES)
	@echo "🔄 BSV source files changed, regenerating Verilog..."
	$(MAKE) bsv-compile

# Clean all generated files
clean:
	@echo "🧹 Cleaning generated files..."
	@cd $(BSV_SRC_DIR) && ../$(BSV_BUILD) -clean 2>/dev/null || true
	@rm -rf obj_dir $(WAVES_DIR)
	@find $(BSV_SRC_DIR) -name "*.v" -delete 2>/dev/null || true
	@find $(BSV_SRC_DIR) -name "*.vcd" -delete 2>/dev/null || true
	@echo "✅ Clean completed"

# Debug Info - show variables
debug:
	@echo "🐛 Debug Information"
	@echo "==================="
	@echo "TOP_MODULE: $(TOP_MODULE)"
	@echo "TOP_FILE: $(TOP_FILE)"
	@echo "BSV_FILES: $(BSV_FILES)"
	@echo "CPP_FILES: $(CPP_FILES)"
	@echo "VERILOG_FILES: $(VERILOG_FILES)"
	@echo "SIMULATION_EXE: $(SIMULATION_EXE)"
