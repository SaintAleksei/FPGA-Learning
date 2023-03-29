// DE2-115 task 1
/*
*   Goal is to create device, that can increment, decrement and reset value via
* buttons and output result to 7-segment display
*/

// Convert 4-bit number to hexadecimal representation for 7-segment dispay
// TODO: In fact, it is Lookup Table, maybe it can be separate parameterizable module
module sevseg
(
  input  wire [3:0] number,
  output wire [6:0] digit
);
// FIXME: Maybe here can be used wires. What is more effective?
reg [6:0] lut [0:15];
initial 
begin
  // Values gathered from DE2-115 user manual, p. 37
  /*
      0
    5   1
      6
    4   2
      3
  */
  // FIXME: How much time is needed for this initialization?
  //           6543210
  lut[0]  = 7'b0111111;
  lut[1]  = 7'b0000110;
  lut[2]  = 7'b1011011;
  lut[3]  = 7'b1001111;
  lut[4]  = 7'b1100110;
  lut[5]  = 7'b1101101;
  lut[6]  = 7'b1111101;
  lut[7]  = 7'b0000111;
  lut[8]  = 7'b1111111;
  lut[9]  = 7'b1101111;
  lut[10] = 7'b1110111;
  lut[11] = 7'b1111100;
  lut[12] = 7'b0111001;
  lut[13] = 7'b1011110;
  lut[14] = 7'b1111001;
  lut[15] = 7'b1110001;
end
assign digit = lut[number];
endmodule

// Simple 4-bit counter
module counter
(
  input  wire       inc_button,
  input  wire       dec_button,
  input  wire       reset_button,
  output reg  [3:0] value
);
initial 
  value = 4'b0000;
always @(posedge reset)
  value <= 0;
always @(posedge inc_button)
  value <= value + 1;
always @(posedge dec_button)
  value <= value - 1;
endmodule

// Top level module, should be connected to DE2-115 pins
// Recive inputs from buttons and output number to 7-segment display
module top
(
  input  wire       inc_button,   // KEY1
  input  wire       dec_button,   // KEY2
  input  wire       reset_button, // KEY0
  output wire [6:0] sev_seg       // HEX0
);
wire counter2sevseg;
counter 
cnt 
(
  .inc_button(inc_button),
  .dec_button(dec_button),
  .reset_button(reset_button),
  .value(counter2sevseg)
);
sevseg
sseg
(
  .number(counter2sevseg),
  .digit(sev_seg)
);
endmodule

// Test for simulator
module test ();
// TODO:
endmodule
