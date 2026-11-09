`timescale 1ns/1ps
module main_block_tb;
  // Port declarations
  reg  [7:0] R, G, B;
  reg  signed [7:0]  weight_n1_1, weight_n1_2, weight_n1_3;
  reg  signed [7:0]  weight_n2_1, weight_n2_2, weight_n2_3;
  reg  signed [7:0]  weight_n3_1, weight_n3_2, weight_n3_3;
  reg  signed [7:0]  weight_n4_1, weight_n4_2, weight_n4_3;
  reg  clk, rst;
  reg  signed [15:0] biasn1, biasn2, biasn3, biasn4;
  wire [7:0] R_out, G_out, B_out;
  integer errors;
  // Instantiate Main module design
  main_block_design DUT (
    .clk(clk), .rst(rst),
    .R(R), .G(G), .B(B),
    .weight_n1_1(weight_n1_1), .weight_n1_2(weight_n1_2), .weight_n1_3(weight_n1_3),
    .weight_n2_1(weight_n2_1), .weight_n2_2(weight_n2_2), .weight_n2_3(weight_n2_3),
    .weight_n3_1(weight_n3_1), .weight_n3_2(weight_n3_2), .weight_n3_3(weight_n3_3),
    .weight_n4_1(weight_n4_1), .weight_n4_2(weight_n4_2), .weight_n4_3(weight_n4_3),
    .biasn1(biasn1), .biasn2(biasn2), .biasn3(biasn3), .biasn4(biasn4),
    .R_out(R_out), .G_out(G_out), .B_out(B_out)
  );
  // Clock generation
  initial clk = 1'b0;
  always #5 clk = ~clk;
  // Helper functions
  function is_white;
    input [7:0] r, g, b;
    begin
      is_white = ((r >= 8'd240) && (g >= 8'd240) && (b >= 8'd240)) ? 1'b1 : 1'b0;
    end
  endfunction
  task wait_clocks;
    input integer n;
    integer i;
    begin
      for (i=0;i<n;i=i+1) @(posedge clk);
    end
  endtask
  task apply_and_check;
    input [7:0] r;
    input [7:0] g;
    input [7:0] b;
    input       exp_white;     // 1=yes, 0=no
    input [127:0] name;
    reg         got_white;
    begin
      R=r; G=g; B=b;
      wait_clocks(3);
      got_white = is_white(R_out, G_out, B_out);

      $display("[%0t] %0s  RGB=(%0d,%0d,%0d) -> out=(%0d,%0d,%0d)  %s",
               $time, name, r, g, b, R_out, G_out, B_out,
               (got_white ? "WHITE" : "BLACK"));
      if (got_white !== exp_white) begin
        $display("  ** MISMATCH: expected %s", exp_white ? "WHITE" : "BLACK");
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    errors = 0;

    // Default Intialization of port signals
    R=0; G=0; B=0;
    weight_n1_1=0; weight_n1_2=0; weight_n1_3=0;
    weight_n2_1=0; weight_n2_2=0; weight_n2_3=0;
    weight_n3_1=0; weight_n3_2=0; weight_n3_3=0;
    weight_n4_1=0; weight_n4_2=0; weight_n4_3=0;
    biasn1=0; biasn2=0; biasn3=0; biasn4=0;

    //  Toggle reset from high to low
    rst = 1'b1;  wait_clocks(3);
    rst = 1'b0;  wait_clocks(1);
// Features Neurons set in such a way that, it checks for yellow(R-high;G-high;Blue-low) at the output:
    //   N1: s1 = R - 200 ---> Returns intensity of Red
    //   N2: s2 = G - 200 ---> Returns intensity of Green
    //   N3: s3 = 150 - B ---> Returns intensity of Non-Blue
    weight_n1_1 = 8'sd1;  weight_n1_2 = 8'sd0;  weight_n1_3 = 8'sd0;   biasn1 = -16'sd200;
    weight_n2_1 = 8'sd0;  weight_n2_2 = 8'sd1;  weight_n2_3 = 8'sd0;   biasn2 = -16'sd200;
    weight_n3_1 = 8'sd0;  weight_n3_2 = 8'sd0;  weight_n3_3 = -8'sd1;  biasn3 =  16'sd150;
//N4(Decision Maker): s4 = out1 + out2 + out3 - 600 ---> Checks if N1,N2,N3 are
//strong enough to detect yellow at output
    weight_n4_1 = 8'sd1;
    weight_n4_2 = 8'sd1;
    weight_n4_3 = 8'sd1;
    biasn4      = -16'sd600;

    wait_clocks(2);

    // Test Vectors: Checks detection of Yellow among wide range of colors
    apply_and_check(8'd255, 8'd255, 8'd0  , 1'b1, "yellow_strong");
    apply_and_check(8'd230, 8'd230, 8'd10 , 1'b1, "yellow_mid");
    apply_and_check(8'd210, 8'd210, 8'd40 , 1'b1, "yellow_soft");
    apply_and_check(8'd255, 8'd255, 8'd255, 1'b0, "white");
    apply_and_check(8'd255, 8'd0  , 8'd0  , 1'b0, "red");
    apply_and_check(8'd0  , 8'd255, 8'd0  , 1'b0, "green");
    apply_and_check(8'd0  , 8'd0  , 8'd255, 1'b0, "blue");
    apply_and_check(8'd0  , 8'd255, 8'd255, 1'b0, "cyan");
    apply_and_check(8'd255, 8'd0  , 8'd255, 1'b0, "magenta");
    apply_and_check(8'd180, 8'd180, 8'd180, 1'b0, "gray");
    apply_and_check(8'd0  , 8'd0  , 8'd0  , 1'b0, "black");

    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("TESTS FAILED: %0d errors", errors);

    $finish;
  end
endmodule
