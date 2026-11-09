`timescale 1ns/1ps
module adder_tb;
// Port declarations
reg  signed [15:0] multiplier_stage_1;
reg  signed [15:0] multiplier_stage_2;
reg  signed [15:0] multiplier_stage_3;
reg  signed [15:0] bias;
wire signed [13:0] adder_out; // Output of Adder circuit.
// Instantiate DUT
Adder DUT (
  .multiplier_stage_1(multiplier_stage_1),.multiplier_stage_2(multiplier_stage_2),
  .multiplier_stage_3(multiplier_stage_3),.bias(bias),.adder_out(adder_out));
initial begin
  // Monitors any change in the ports, and displays it on console
  $monitor("Time=%0t mul_stage1=%0d mul_stage2=%0d mul_stage3=%0d bias=%0d adder_out=%0d",
           $time, multiplier_stage_1, multiplier_stage_2, multiplier_stage_3, bias, adder_out);
// Test_vector-1
  multiplier_stage_1 = 16'sd2500;
  multiplier_stage_2 = 16'sd3000;
  multiplier_stage_3 = 16'sd1800;
  bias               = 16'sd2000;
#5;
  // Test-vector-2
  multiplier_stage_1 = 16'sd1000;
  multiplier_stage_2 = 16'sd6000;
  multiplier_stage_3 = 16'sd1500;
  bias               = 16'sd1200;
#30;
  $finish;
end
endmodule
