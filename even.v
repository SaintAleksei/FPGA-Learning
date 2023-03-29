`timescale 1ns / 100ps
module even(
	input [31:0] number,
	output       is_even
);

	assign is_even = ~number[0];
endmodule

module top;
reg [31:0] number;
wire is_even;
even
even_inst(
	.number(number),
	.is_even(is_even)
);
initial begin
	number = 0;
end
always begin
	number = number + 1;
	#5
	$display("number  = %d", number);
	$display("is_even = %b", is_even);
end
initial begin
	#1000;
	$stop;
end
endmodule