`timescale 1ns/1ps
module color_mapping_tb;

reg [7:0] neuron_output;
wire [7:0] R_out;
wire [7:0] G_out;
wire [7:0] B_out;

color_mapping_design DUT (.neuron_output(neuron_output),.R_out(R_out),.G_out(G_out),.B_out(B_out));

initial begin

$monitor("For input: %d R = %d G = %d B= %d",neuron_output,R_out,G_out,B_out);
neuron_output = 8'd130;
#10; neuron_output = 8'd100;
#10; neuron_output = 8'd128;
#10; neuron_output = 8'd255;
#10; neuron_output = 8'd50;

#10;
$finish;
end
endmodule
