#!/usr/bin/env bash
# Cadence Xcelium (xrun) + SimVision, adapted from the command I used on the SDSU volta server.
#   ./scripts/run_xrun.sh main_block_tb        -> batch run, prints to console
#   ./scripts/run_xrun.sh main_block_tb gui    -> opens the waveform in SimVision
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOP=${1:-main_block_tb}
GUI=""
[ "$2" = "gui" ] && GUI="-gui"

mkdir -p "$ROOT/build_xrun"
cd "$ROOT/build_xrun"
python3 "$ROOT/scripts/sigmoid_values_14bit.py"

xrun -clean -sv -coverage all -status -errormax 50 -access rwc -64bit \
     "$ROOT"/rtl/*.v "$ROOT"/tb/*.v \
     -timescale 1ns/1ps -top "$TOP" $GUI
