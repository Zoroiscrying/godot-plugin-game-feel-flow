# Game Feel Flow Tests

## Description

This directory contains unit test scripts for the Game Feel Flow plugin.

**Note:** These tests require the [GdUnit4](https://github.com/MikeSchulze/gdUnit4) framework, which needs to be installed separately.

## Installing GdUnit4

### Method 1: Git Clone

```bash
cd addons
git clone https://github.com/MikeSchulze/gdUnit4.git
cd gdUnit4
git checkout v4.2.0
```

### Method 2: Godot Asset Library

In Godot editor:
1. Open AssetLib tab
2. Search for "GdUnit4"
3. Download and install

## Running Tests

```bash
# Linux/macOS
./run_tests.sh

# Windows
run_tests.bat
```

Or run manually:

```bash
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/"
```

## Test Files

- test_gff_params.gd
- test_gff_feedback.gd
- test_gff_feedback_stack.gd
- test_gff_player.gd
- test_gff_combo.gd
- test_game_feel_flow.gd
- test_gff_shake.gd
