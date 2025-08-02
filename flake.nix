{
  description = "Bluespec SystemVerilog development environment with Verilator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Bluespec compiler
            bluespec
            
            # Verilog simulation tools (for bsvbuild.sh compatibility)
            verilog               # Icarus Verilog (iverilog)
            
            # Verilator for advanced simulation
            verilator
            
            # Build tools
            gnumake
            gcc
            gdb
            cmake                 # For Verilator C++ builds
            bear                  # Generate compile_commands.json
            
            # Shell
            zsh
            
            # Development utilities
            git
            which                 # Command location utility
            file                  # File type detection
            
            # C++ development (for Verilator simulation)
            valgrind              # Memory debugging
            
            # Waveform viewing
            gtkwave
            
            # Text processing
            coreutils             # Basic utilities
            findutils             # Find utilities
            gnugrep                  # Text search
            gnused                   # Stream editor
          ];

          shellHook = ''
            echo "🚀 Bluespec SystemVerilog Development Environment"
            echo "📦 Available tools:"
            echo "   • bsc (Bluespec compiler): $(which bsc)"
            echo "   • iverilog (Verilog simulator): $(which iverilog)"
            echo "   • verilator (Advanced simulator): $(which verilator)"
            echo "   • gtkwave (Waveform viewer): $(which gtkwave)"
            echo ""
            echo "� Project structure:"
            echo "   • bsv_src/ - BSV source files"
            echo "   • verilator_src/ - Verilator C++ simulation files"
            echo "   • Use 'make help' to see available targets"
            echo ""
            
            # Add bsvbuild.sh to PATH
            export PATH="$PWD:$PATH"
            chmod +x bsvbuild.sh
            
            # Set BSV library path
            export BLUESPECDIR="${pkgs.bluespec}/lib"
            
            # Verilator flags for better performance
            export VERILATOR_FLAGS="-Wall -Wno-UNUSED -Wno-UNOPTFLAT --trace"

            # Switch to zsh if available and not already running
            if [ -n "$ZSH_VERSION" ]; then
              echo "Already running zsh"
            elif command -v zsh >/dev/null 2>&1; then
              export SHELL=$(which zsh)
              exec zsh
            fi

          '';
        };
      });
}