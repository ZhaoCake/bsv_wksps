# Bluespec SystemVerilog Template Project

A template project for Bluespec SystemVerilog development with Verilator simulation support.

## Prerequisites

- Nix with flakes enabled
- Git

## Quick Start

1. Clone this template:
```bash
git clone <this-repo> my-bsv-project
cd my-bsv-project
```

2. Enter the development environment:
```bash
nix develop
```

3. Build and simulate:
```bash
make all
make sim
```

## Project Structure

```
├── flake.nix          # Nix development environment
├── Makefile           # Build automation
├── README.md          # This file
├── .gitignore         # Git ignore patterns
├── src/               # BSV source files
│   └── example/       # Example modules
├── tb/                # Testbenches
│   └── example/       # Example testbenches
├── sim/               # Simulation outputs
│   └── build/         # Generated files
└── scripts/           # Utility scripts
    ├── build.sh       # Build script
    └── clean.sh       # Clean script
```

## Development Workflow

1. Write your BSV modules in `src/`
2. Create testbenches in `tb/`
3. Use `make build` to compile
4. Use `make sim` to run simulations
5. View waveforms with `gtkwave sim/build/*.vcd`

## Make Targets

- `make all` - Build all modules
- `make sim` - Run simulation
- `make clean` - Clean generated files
- `make help` - Show available targets

## Tools Available

- **bsc**: Bluespec SystemVerilog compiler
- **verilator**: Verilog simulator
- **gtkwave**: Waveform viewer
- **make**: Build automation
- **python3**: For scripting and analysis