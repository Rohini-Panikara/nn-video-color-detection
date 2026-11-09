`timescale 1ns/1ps
module main_block_design(
  input  [7:0] R, input [7:0] G, input [7:0] B,
  input  signed [7:0] weight_n1_1, input signed [7:0] weight_n1_2, input signed [7:0] weight_n1_3,
  input  signed [7:0] weight_n2_1, input signed [7:0] weight_n2_2, input signed [7:0] weight_n2_3,
  input  signed [7:0] weight_n3_1, input signed [7:0] weight_n3_2, input signed [7:0] weight_n3_3,
  input  signed [7:0] weight_n4_1, input signed [7:0] weight_n4_2, input signed [7:0] weight_n4_3,
  input               clk, input rst,
  input  signed [15:0] biasn1, input signed [15:0] biasn2,
  input  signed [15:0] biasn3, input signed [15:0] biasn4,
  output [7:0] R_out, output [7:0] G_out, output [7:0] B_out);
  // Neuron outputs
  wire [7:0] out1, out2, out3, out4;
// Feature neurons
  neuron_design N1(.clk(clk), .rst(rst), .R_input(R), .G_input(G), .B_input(B),
                   .weight1(weight_n1_1), .weight2(weight_n1_2), .weight3(weight_n1_3),
                   .bias(biasn1), .neuron_output(out1));

  neuron_design N2(.clk(clk), .rst(rst), .R_input(R), .G_input(G), .B_input(B),
                   .weight1(weight_n2_1), .weight2(weight_n2_2), .weight3(weight_n2_3),
                   .bias(biasn2), .neuron_output(out2));

  neuron_design N3(.clk(clk), .rst(rst), .R_input(R), .G_input(G), .B_input(B),
                   .weight1(weight_n3_1), .weight2(weight_n3_2), .weight3(weight_n3_3),
                   .bias(biasn3), .neuron_output(out3));
 // Fuse features: N4 uses the activations from N1..N3
  neuron_design N4(.clk(clk), .rst(rst), .R_input(out1), .G_input(out2), .B_input(out3),
                   .weight1(weight_n4_1), .weight2(weight_n4_2), .weight3(weight_n4_3),
                   .bias(biasn4), .neuron_output(out4));

  color_mapping_design DUT_CM (.neuron_output(out4), .R_out(R_out), .G_out(G_out), .B_out(B_out));
endmodule
