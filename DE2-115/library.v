// Convert 4-bit number to hexadecimal representation for 7-segment dispay
// TODO: In fact, it is Lookup Table, maybe it can be separate parameterizable module
module sevseg
(
  input  wire [3:0] number,
  output wire [6:0] digit
);
// FIXME: Maybe here can be used wires. What is more effective?
wire [6:0] lut [0:15];
// Values gathered from DE2-115 user manual, p. 37
/*
    0
  5   1
    6
  4   2
    3
*/
// FIXME: How much time is needed for this initialization?
//                  6543210
assign lut[0]  = 7'b0111111;
assign lut[1]  = 7'b0000110;
assign lut[2]  = 7'b1011011;
assign lut[4]  = 7'b1100110;
assign lut[5]  = 7'b1101101;
assign lut[6]  = 7'b1111101;
assign lut[7]  = 7'b0000111;
assign lut[8]  = 7'b1111111;
assign lut[9]  = 7'b1101111;
assign lut[10] = 7'b1110111;
assign lut[11] = 7'b1111100;
assign lut[12] = 7'b0111001;
assign lut[13] = 7'b1011110;
assign lut[14] = 7'b1111001;
assign lut[15] = 7'b1110001;
assign digit   = ~lut[number];
endmodule

// simple sync button
module button
(
  input  wire clk,
  input  wire button_async,
  output wire button_sync
);
reg first, second;
always @(posedge clk) 
begin
  first <= button_async;
  second <= first;
end
assign button_sync = ~second & first;
endmodule

// Simple 4-bit counter
module counter
#(
  BIT_DEPTH = 8
)
(
  input  wire       clk,
  input  wire       inc,
  input  wire       dec,
  input  wire       reset,
  output reg  [BIT_DEPTH-1:0] value
);
always @(posedge clk)
  if (reset)
    value <= 0;
  else if (inc)
    value <= value + 1;
  else if (dec)
    value <= value - 1;
endmodule

module shiftreg
#(
  BIT_DEPTH = 8
)
(
  input  clk,
  input  reset,
  input  left_shift_bit,
  input  left_shift_event,
  input  right_shift_bit,
  input  right_shift_event,
  output reg [BIT_DEPTH-1:0] register 
);
wire [BIT_DEPTH-1:0] left_shifted  = (register << 1) | 8'b00000001 & {8{left_shift_event}};
wire [BIT_DEPTH-1:0] right_shifted = (register >> 1) | 8'b10000000 & {8{right_shift_event}};
/*
assign left_shifted[0]  = left_shift_bit;
assign right_shifted[BIT_DEPTH-1] = right_shift_bit;
genvar gi;
generate for (gi = 0; gi < BIT_DEPTH-2; gi = gi + 1)
begin: left_shifted_loop
	assign left_shifted[gi+1] = register[gi];
end
endgenerate
generate for (gi = 0; gi < BIT_DEPTH-2; gi = gi + 1)
begin: right_shifter_loop
	assign right_shifted[gi] = register[gi+1];
end
endgenerate
*/
always @(posedge clk)
  if (reset)
    register <= 0;
  else if (left_shift_event)
    register <= left_shifted;
  else if (right_shift_event)
    register <= right_shifted;
endmodule
