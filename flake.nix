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
            grep                  # Text search
            sed                   # Stream editor
            awk                   # Text processing
          ];

          shellHook = ''
            echo "🚀 Bluespec SystemVerilog Development Environment"
            echo "📦 Available tools:"
            echo "   • bsc (Bluespec compiler): $(which bsc)"
            echo "   • iverilog (Verilog simulator): $(which iverilog)"
            echo "   • verilator (Advanced simulator): $(which verilator)"
            echo "   • gtkwave (Waveform viewer): $(which gtkwave)"
            echo ""
            echo "🔧 Build scripts:"
            echo "   • bsvbuild.sh is available in PATH"
            echo "   • Use 'make help' to see available targets"
            echo ""
            
            # Add bsvbuild.sh to PATH
            export PATH="$PWD:$PATH"
          '';
        };
      });
}