`timescale 1ns/1ps
module color_mapping_design(
  input  [7:0] neuron_output,
  output [7:0] R_out, output [7:0] G_out, output [7:0] B_out
);
  // white if activation is high enough
  wire white = (neuron_output >= 8'd200);
  assign R_out = white ? 8'hFF : 8'h00;
  assign G_out = white ? 8'hFF : 8'h00;
  assign B_out = white ? 8'hFF : 8'h00;
endmodule
