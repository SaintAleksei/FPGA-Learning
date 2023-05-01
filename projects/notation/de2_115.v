/*
 * Template file that can be used in many projects
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
  de2_115_buttons
  buttons
  (
    .clk(CLOCK_50),
    .buttons(KEY),
    .pressed(key_sync)
  );

  // 7-segment displays connection
  parameter SEVSEG_OFF = 7'b1111111;
  wire [6:0] digits  [7:0];
  wire [3:0] numbers [7:0];
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1)
    begin: sevseg_loop
      sevseg ss
      (
        .number(numbers[i]),
        .digit(digits[i])
      );
    end
  endgenerate
  assign HEX0 = digits[0];
  assign HEX1 = digits[1];
  assign HEX2 = digits[2];
  assign HEX3 = SEVSEG_OFF;
  assign HEX4 = digits[4];
  assign HEX5 = digits[5];
  assign HEX6 = SEVSEG_OFF;
  assign HEX7 = SEVSEG_OFF;

  // Wires and registers required for device logic
  wire [23:0] dec_digits;
  wire        conversion_done;
  reg  [7:0]  stored_number;
  assign numbers[0] = dec_digits[7:0];
  assign numbers[1] = dec_digits[15:8];
  assign numbers[2] = dec_digits[23:16];
  assign numbers[4] = stored_number[3:0];
  assign numbers[5] = stored_number[7:4];
  assign LEDR[7:0]  = SW[7:0];
  assign LEDG[7:0]  = stored_number;

  // Device logic
  always @(posedge CLOCK_50)
    if (key_sync[0])
      stored_number <= 8'b00000000;
    else if (key_sync[1])
      stored_number <= SW[7:0];

  // Notation module instance
  notation 
  not_instance
  (
    .clk(CLOCK_50),
    .reset(key_sync[0] | key_sync[1]),
    .number(stored_number), 
    .digits(dec_digits),
    .conversion_done(conversion_done)
  );
endmodule
