#!/bin/bash

# Game Feel Flow Test Runner
# Usage: ./run_tests.sh

echo "=== Game Feel Flow Tests ==="
echo ""

# Check if Godot is installed
if ! command -v godot &> /dev/null
then
    echo "Error: Godot not found. Please install Godot 4.2+"
    exit 1
fi

# Check if GdUnit4 exists
if [ ! -d "addons/gdUnit4" ]; then
    echo "Warning: GdUnit4 not found. Downloading..."
    mkdir -p addons
    cd addons
    git clone https://github.com/MikeSchulze/gdUnit4.git
    cd gdUnit4
    git checkout v4.2.0
    cd ../..
fi

echo "Running tests..."
echo ""

# Run tests
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/"

echo ""
echo "=== Tests Complete ==="
