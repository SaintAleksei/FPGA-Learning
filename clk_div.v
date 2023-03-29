module clk_div
(
	input wire clk,
	input wire reset,
	output reg clk_div2,
	output reg clk_div4,
	output reg clk_div8
);
always @(posedge clk)
if (reset)
	{clk_div2, clk_div4, clk_div8} <= 3'h0;
else begin
	clk_div2 <= ~clk_div2;
	clk_div4 <= clk_div2 ^ clk_div4;
	clk_div8 <= (clk_div2 & clk_div4) ^ clk_div8;
end
endmodule
module
test;
reg reset;
reg clk;
wire 	   clk_div2;
wire 	   clk_div4;
wire       clk_div8;
wire [2:0] counter;
clk_div
clk_div_ins(
	.clk(clk),
	.reset(reset),
	.clk_div2(clk_div2),
	.clk_div4(clk_div4),
	.clk_div8(clk_div8)
);
assign counter = {clk_div8, clk_div4, clk_div2};
initial begin
	reset = 1;
	clk = 0;
	#10;
	reset = 0;
end
always begin
	#5;
	clk = ~clk;
end
endmodule