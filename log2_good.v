module
log2 (
	input  [7:0] number,
	output [2:0] pow
);
	assign  pow = {3{number[7]}} & 3'd7 |
		      {3{number[6]}} & 3'd6 |
		      {3{number[5]}} & 3'd5 |
		      {3{number[4]}} & 3'd4 |
		      {3{number[3]}} & 3'd3 |
                      {3{number[2]}} & 3'd2 |
		      {3{number[1]}} & 3'd1;
endmodule

module
test;
reg  [7:0] in;
wire [2:0] out;
log2
log2_inst(
	.number(in),
	.pow(out)
	);
initial begin
	in = 1;
end
always begin
	#5;
	$display("in  = %d", in);
	$display("out = %d", out);
	in = in << 1;
end
initial begin
	#41;
	$stop;
end
endmodule
