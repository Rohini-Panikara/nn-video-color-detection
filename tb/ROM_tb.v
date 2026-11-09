`timescale 1ns/1ps
module ROM_tb;
  reg  signed [13:0] adder_out_ROM_in;
  wire        [7:0]  ROM_out;
  reg                clk;
  reg                rst;
  // Instantiate the ROM module
  ROM_design DUT (
    .clk(clk),
    .rst(rst),
    .adder_out_ROM_in(adder_out_ROM_in),
    .ROM_out(ROM_out)
  );
  initial clk = 1'b0;
  always #10 clk = ~clk;
  // ROM has 1-cycle read latency
  wire [13:0] addr_now = $signed(adder_out_ROM_in) + 14'sd8192;
  // Delay address by one cycle to align with ROM_out
  reg  [13:0] addr_d1;
  always @(posedge clk or posedge rst) begin
    if (rst) addr_d1 <= 14'd0;
    else     addr_d1 <= addr_now;
  end
  // Drive a value and print when ROM_out is valid
  task drive(input signed [13:0] x);
    begin
      @(negedge clk); adder_out_ROM_in = x; // present before sampling edge
      @(posedge clk);                       // ROM samples address
      @(posedge clk);                       // ROM_out valid for previous address
      $display("t=%0t | in=%0d | addr=%0d | ROM_out=0x%02h",
               $time, x, addr_d1, ROM_out);
    end
  endtask
  initial begin
    // Reset
    rst = 1'b1;
    adder_out_ROM_in = 14'sd0;
    repeat (2) @(posedge clk);
    rst = 1'b0;
    // Stimuli input(adder module output )--> range (signed range -8192..+8191)
    drive(14'sd0);
    drive(14'sd1);
    drive(-14'sd2);
    drive(14'sd816);
    drive(14'sd3829);
    drive(-14'sd2818);
    $display("TB completed.");
    #20 $finish;
  end
endmodule
