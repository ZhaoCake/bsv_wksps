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
            
            # Verilator for simulation
            verilator
            
            # Build tools
            gnumake
            gcc
            gdb
            
            # Version control
            git
            
            # Text editors and tools
            vim
            gtkwave
            
            # Python for scripting
            python3
            python3Packages.pip
            
            # Documentation tools
            pandoc
            texlive.combined.scheme-basic
          ];

          shellHook = ''
            echo "Bluespec SystemVerilog development environment loaded!"
            echo "Available tools:"
            echo "  - bsc (Bluespec compiler): $(which bsc)"
            echo "  - verilator: $(which verilator)"
            echo "  - gtkwave (waveform viewer): $(which gtkwave)"
            echo ""
            echo "Project structure:"
            echo "  src/     - BSV source files"
            echo "  tb/      - Testbenches"
            echo "  sim/     - Simulation files"
            echo "  scripts/ - Build and utility scripts"
            echo ""
          '';
        };
      });
}