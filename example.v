`timescale 1ns/100ps
module  top;
reg     clk,reset;
initial clk = 0;
initial begin
	reset = 0;
	#5;
	reset = 1;
	#525 reset = 0;
end

always  #5 clk = ~clk;
initial begin
	#1000;
	$display("clk=%b", clk);
	$display("reset=%b", reset);
	$stop;
end
endmodule