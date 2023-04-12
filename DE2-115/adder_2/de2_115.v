/*
 *  Task #6
 *  Goal is to create device, which can output 2 8-bit number to 7-segment
 *  displays and output their sum to 7-segment display when button is pressed
 */

`include "../library.v"

module de2_115
(
  input  wire        CLOCK_50, // Clock
  input  wire [17:0] SW,       // Switches
  input  wire [3:0]  KEY,      // Buttons, 1 when unpressed
  output wire [17:0] LEDR,     // Red leds
  output wire [8:0]  LEDG,     // Green leds
  output wire [6:0]  HEX0,     // 7-segment displays
  output wire [6:0]  HEX1,
  output wire [6:0]  HEX2,
  output wire [6:0]  HEX3,
  output wire [6:0]  HEX4,
  output wire [6:0]  HEX5,
  output wire [6:0]  HEX6,
  output wire [6:0]  HEX7
);
// 4 buttons sychronization
wire [3:0] key_sync;
genvar i;
generate
  for (i = 0; i < 4; i = i + 1)
  begin: buttons_loop
    button key_sync
    (
      .clk(CLOCK_50),
      .button_async(KEY[0]),
      .button_sybc(key_sync[0])
    );
  end
endgenerate

// 3 8-bit numbers output to 7-segment displays
wire [7:0] number [2:0];
assign number[0] = SW[7:0];
assign number[1] = SW[16:9];
wire [7:0] sum;
assign {LEDG[8], sum} = number[0] + number[1];
wire [6:0] digits [5:0];
assign digits[0] = HEX6;
assign digits[1] = HEX7;
assign digits[2] = HEX5;
assign digits[3] = HEX4;
assign digits[4] = HEX3;
assign digits[5] = HEX2;
generate
  for (i = 0; i < 3; i = i + 1)
  begin: ss_loop
    sevseg ss_hex_first
    (
      .number(number[i][3:0]),
      .digit(digits[i * 2])
    );
    sevseg ss_hex_second
    (
      .number(number[i][7:4]),
      .digit(digits[i * 2 + 1])
    );
  end
endgenerate

// Perfom addition when button is pressed
reg sum_reg;
assign number[2] = sum_reg;
always @(posedge CLOCK_50)
  if (key_sync[0])
    sum_reg <= 8'b00000000;
  else if (key_sync[1])
    sum_reg <= sum;
endmodule
