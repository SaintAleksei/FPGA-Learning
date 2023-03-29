module
prior_decoder (
	input  [7:0] number,
	output [2:0] highone
);
	assign  highone = (number[7]) ? 3'd7 :
		      	  (number[6]) ? 3'd6 :
		      	  (number[5]) ? 3'd5 :
		      	  (number[4]) ? 3'd4 :
		      	  (number[3]) ? 3'd3 :
                      	  (number[2]) ? 3'd2 :
		      	  (number[1]) ? 3'd1 : 3'd0;
endmodule

module
test;
reg  [7:0] in;
wire [2:0] out;
prior_decoder
prior_decoder_inst(
	.number(in),
	.highone(out)
	);
initial begin
	in = 1;
end
always begin
	#1;
	$display("in  = %d", in);
	$display("out = %d", highone);
	in = in + 1;
end
initial begin
	#257;
	$stop;
end
endmodule
