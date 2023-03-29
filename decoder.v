`timescale 1ns/100ps
module 
decoder3to8(
	input  [2:0] num3,
	output [7:0] num8
);
	assign num8 = 8'd0 | (1 << num3);
endmodule

module
test;
reg  [2:0] in;
wire [7:0] out;
decoder3to8
decoder3to8_inst(
	.num3(in),
	.num8(out)
	);
initial begin
	in = 0;
end
always begin
	#5;
	$display("in  = %d", in);
	$display("out = %b", out);
	in = in + 1;
end
initial begin
	#41;
	$stop;
end
endmodule

