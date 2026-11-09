`timescale 1ns/1ps
module neuron_design(
  input         [7:0]  R_input,
  input         [7:0]  G_input,
  input         [7:0]  B_input,
  input  signed [7:0]  weight1,  // for R
  input  signed [7:0]  weight2,  // for G
  input  signed [7:0]  weight3,  // for B
  input  signed [15:0] bias,
  output        [7:0]  neuron_output,
  input                clk,
  input                rst
);
  wire signed [15:0] mult_R, mult_G, mult_B;
  wire signed [13:0] sum_temp;

  multiplier_stage MUL_R (.RGB_input(R_input), .RGB_weight(weight1), .mul_out(mult_R));
  multiplier_stage MUL_G (.RGB_input(G_input), .RGB_weight(weight2), .mul_out(mult_G));
  multiplier_stage MUL_B (.RGB_input(B_input), .RGB_weight(weight3), .mul_out(mult_B));

  Adder ADD (
    .multiplier_stage_1(mult_R), .multiplier_stage_2(mult_G), .multiplier_stage_3(mult_B),
    .bias(bias), .adder_out(sum_temp));

  ROM_design ROM_DUT (
    .clk(clk), .rst(rst),
    .adder_out_ROM_in(sum_temp),
    .ROM_out(neuron_output));
endmodule
