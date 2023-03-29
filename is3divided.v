module
is3divided(
	input [7:0] number,
	output is_divided
);
	assign is_divided = (5'b10000  +
			     number[0] -
		  	     number[1] +
		             number[2] -
		             number[3] +
		             number[4] -
		             number[5] +
		             number[6] -
		             number[7] == 5'b10000) ? 1'b1 : 1'b0;  
endmodule

module
test;
reg [7:0] number;
wire      is_divided;
is3divided
is3divided_inst(
	.number(number),
	.is_divided(is_divided)
	);
initial begin
	number = 0;
end
always begin
	#1;
	$display("number     = %d", number);
	$display("is_divided = %d", is_divided);
	number = number + 1;
end
initial begin
	#257;
	$stop;
end
endmodule