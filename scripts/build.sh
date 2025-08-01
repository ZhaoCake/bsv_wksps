#!/bin/bash

# Build script for BSV projects

set -e

PROJECT_NAME=${1:-example}
BUILD_DIR="sim/build"

echo "Building project: $PROJECT_NAME"

# Create build directory
mkdir -p $BUILD_DIR

# Compile BSV
echo "Compiling BSV modules..."
bsc -aggressive-conditions -show-schedule -show-module-use \
    -bdir $BUILD_DIR -vdir $BUILD_DIR -simdir $BUILD_DIR \
    -p src:tb:+ -g mk${PROJECT_NAME} src/${PROJECT_NAME}/*.bsv

echo "Build completed successfully!"
echo "Generated files are in: $BUILD_DIR"