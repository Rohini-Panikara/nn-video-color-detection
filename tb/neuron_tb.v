`timescale 1ns/1ps
module neuron_tb;
  // Inputs are unsigned pixels; weights/bias are signed
  reg  [7:0]          R_input, G_input, B_input;
  reg  signed [7:0]   weight1, weight2, weight3;    // w1->R, w2->G, w3->B
  reg  signed [15:0]  bias;
  wire [7:0]          neuron_output;
  reg                 clk, rst;
  // Instantiate Neuron module
  neuron_design DUT (
    .clk(clk),
    .rst(rst),
    .R_input(R_input),
    .G_input(G_input),
    .B_input(B_input),
    .weight1(weight1),
    .weight2(weight2),
    .weight3(weight3),
    .bias(bias),
    .neuron_output(neuron_output)
  );
  // Clock generation :10 ns period clock
  initial clk = 1'b0;
  always #5 clk = ~clk;
  // Apply inputs and print after ROM's 1-cycle latency
  task apply(
    input [7:0] r, input [7:0] g, input [7:0] b,
    input signed [7:0] w1, input signed [7:0] w2, input signed [7:0] w3,
    input signed [15:0] b_in
  );
    begin
      @(negedge clk);
      R_input  = r;  G_input = g;  B_input = b;
      weight1  = w1; weight2 = w2; weight3 = w3;
      bias     = b_in;
      @(posedge clk);  // sampled into ROM address
      @(posedge clk);  // ROM_out valid
      $display("t=%0t | R=%0d G=%0d B=%0d | w1=%0d w2=%0d w3=%0d | bias=%0d | neuron_out=%0d",
               $time, r, g, b, w1, w2, w3, b_in, neuron_output);
    end
  endtask
initial begin
    // Reset
    rst = 1'b1;
    R_input = 0; G_input = 0; B_input = 0;
    weight1 = 0; weight2 = 0; weight3 = 0; bias = 0;
    repeat (2) @(posedge clk);
    rst = 1'b0;

    // TV1: Near midpoint (sum18 = 128 - 128 + 0 + 0 = 0) -> ~128
    apply(8'd128, 8'd128, 8'd128,    8'sd1,  -8'sd1,  8'sd0,     16'sd0);
    // TV2: Small positive (sum18 = 160 - 120 + 10 - 20 = +30) -> slightly >128
    apply(8'd160, 8'd120, 8'd10,     8'sd1,  -8'sd1,  8'sd1,    -16'sd20);
    // TV3: Small negative (sum18 = 60 - 140 + 0 - 10 = -90) -> below 128
    apply(8'd60,  8'd140, 8'd90,     8'sd1,  -8'sd1,  8'sd0,    -16'sd10);
    // TV4: Mixed signs, tiny negative (sum18 = 200 + 180 - 440 + 50 = -10)
    apply(8'd200, 8'd180, 8'd220,    8'sd1,   8'sd1, -8'sd2,     16'sd50);
    // TV5: High but non-saturating positive (sum18 = 200 - 100 + 50 - 30 = +120)
    apply(8'd200, 8'd100, 8'd50,     8'sd1,  -8'sd1,  8'sd1,    -16'sd30);
    // TV6: Positive saturation (sum18 = 255*1 + 0 + 255*1 = +510)
    apply(8'd255, 8'd0,   8'd255,    8'sd1,   8'sd0,  8'sd1,     16'sd0);
    // TV7: Negative saturation (sum18 = -255 -255 -255 = -765)
    apply(8'd255, 8'd255, 8'd255,   -8'sd1,  -8'sd1, -8'sd1,     16'sd0);
    // TV8: Non-saturating negative (sum18 = 40 - 160 + 0 + 0 = -120)
    apply(8'd40,  8'd160, 8'd0,      8'sd1,  -8'sd1,  8'sd0,     16'sd0);
    #10 $finish;
  end
endmodule
