`timescale 1ns/1ps
// Multiply an unsigned 8-bit channel by a signed 8-bit weight
module multiplier_stage(
  input         [7:0]   RGB_input,    // 0..255 (unsigned pixel channel)
  input  signed [7:0]   RGB_weight,   // signed weight
  output signed [15:0]  mul_out
);
  // extend to a positive signed value, then does signed multiply
  wire signed [8:0] RGB_s = {1'b0, RGB_input}; // +0 .. +255
  assign mul_out = RGB_s * $signed(RGB_weight);
endmodule
