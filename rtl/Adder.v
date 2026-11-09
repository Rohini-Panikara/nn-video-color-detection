`timescale 1ns/1ps
module Adder(
  input  signed [15:0] multiplier_stage_1,
  input  signed [15:0] multiplier_stage_2,
  input  signed [15:0] multiplier_stage_3,
  input  signed [15:0] bias,
  output signed [13:0] adder_out
);
  // Sum in 18 bits
  wire signed [17:0] sum18 = $signed(multiplier_stage_1)
                           + $signed(multiplier_stage_2)
                           + $signed(multiplier_stage_3)
                           + $signed(bias);

  // Scale (gain) before the sigmoid to push results toward 0/255
  // Change GAIN_SHIFT for sharper/softer transitions (6 = *64)
  localparam integer GAIN_SHIFT = 6;
  wire signed [31:0] sum_scaled = $signed(sum18) <<< GAIN_SHIFT;

  // Saturate to signed 14-bit range [-8192 .. +8191]
  localparam signed [31:0] HI14 = 32'sd8191;
  localparam signed [31:0] LO14 = -32'sd8192;

  assign adder_out = (sum_scaled > HI14) ? 14'sd8191 :
                     (sum_scaled < LO14) ? -14'sd8192 :
                     sum_scaled[13:0];
endmodule
