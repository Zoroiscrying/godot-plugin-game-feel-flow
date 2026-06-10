@echo off
REM Game Feel Flow Test Runner (Windows)
REM Usage: run_tests.bat

echo === Game Feel Flow Tests ===
echo.

REM Check if Godot is installed
where godot >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Godot not found. Please install Godot 4.2+
    pause
    exit /b 1
)

REM Check if GdUnit4 exists
if not exist "addons\gdUnit4" (
    echo Warning: GdUnit4 not found. Downloading...
    mkdir addons
    cd addons
    git clone https://github.com/MikeSchulze/gdUnit4.git
    cd gdUnit4
    git checkout v4.2.0
    cd ..\..
)

echo Running tests...
echo.

REM Run tests
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/"

echo.
echo === Tests Complete ===
pause
