`timescale 1ns/1ps
module mul_tb;
// port declaration
reg  [7:0]          RGB_input;
reg  signed [7:0]   RGB_weight;
wire signed [15:0]  mul_out;
// Instantiate DUT
multiplier_stage DUT (
  .RGB_input (RGB_input),
  .RGB_weight(RGB_weight),
  .mul_out   (mul_out)
);
initial begin
  RGB_input  = 8'd0;
  RGB_weight = 8'sd0;
  #1;
$monitor("Time = %0t color = %0d weight %0d mul_out = %0d",$time, RGB_input, RGB_weight, mul_out);
RGB_input = 8'd20;  RGB_weight = 8'sd25;
  #5; RGB_input = 8'd255; RGB_weight = 8'sd10;
  #5; RGB_input = 8'd150; RGB_weight = 8'sd40;
  #5; RGB_input = 8'd200; RGB_weight = 8'sd25;
#20; $finish;
end
endmodule
