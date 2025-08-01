#!/bin/bash

# Clean script for BSV projects

echo "Cleaning generated files..."

# Remove build directory
rm -rf sim/build

# Remove BSV generated files
rm -f *.bo *.ba *.v *.h *.cxx *.o

# Remove simulation outputs
rm -f *.vcd *.fsdb *.wlf

# Remove Verilator generated files
rm -rf obj_dir/
rm -f V*

echo "Clean completed!"