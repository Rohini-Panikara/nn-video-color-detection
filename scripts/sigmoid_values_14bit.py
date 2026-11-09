#!/usr/bin/env python3
# Generates the 14-bit-input / 8-bit-output sigmoid lookup table loaded by ROM_design.v
from math import exp

DEPTH  = 1 << 14          # 16384 entries
CENTER = DEPTH // 2       # 8192
SCALE  = 512.0            # larger=softer, smaller=sharper
                          # (512.0 reproduces the simulation results; 1024.0 makes
                          #  the yellow_soft test fail -- see README)
OUT    = "sigmoid_values_14bit.hex"

with open(OUT, "w") as f:
    for addr in range(DEPTH):                       # 0..16383 (unsigned)
        x = (addr - CENTER) / SCALE                 # center at 0
        y = 1.0 / (1.0 + exp(-x))                   # sigmoid in [0,1]
        v = int(round(y * 255.0))                   # to [0..255]
        if v < 0: v = 0                             # clamp (paranoia)
        elif v > 255: v = 255
        f.write(f"{v:02X}\n")
