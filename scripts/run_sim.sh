#!/usr/bin/env bash
# Runs the testbenches with Icarus Verilog (free, open source).
#   ./scripts/run_sim.sh                 -> all six testbenches
#   ./scripts/run_sim.sh main_block_tb   -> just one
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$ROOT/build"
mkdir -p "$BUILD"
cd "$BUILD"

# ROM_design.v loads sigmoid_values_14bit.hex from the working directory
python3 "$ROOT/scripts/sigmoid_values_14bit.py"

TBS=${1:-"mul_tb adder_tb ROM_tb neuron_tb color_mapping_tb main_block_tb"}
for tb in $TBS; do
  echo "===== $tb ====="
  iverilog -g2005 -Wall -s "$tb" -o "$tb.vvp" "$ROOT"/rtl/*.v "$ROOT/tb/$tb.v"
  vvp -n "$tb.vvp"
  echo
done
