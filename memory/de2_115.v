/*
 *  Task #10
 *  Simple memory.
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
  parameter SEVSEG_OFF = 7'b1111111;

  // 4 buttons sychronization
  wire [3:0] key_pressed;
  de2_115_buttons
  buttons
  (
    .clk(CLOCK_50),
    .buttons(KEY),
    .pressed(key_pressed)
  );

  // 7-segment displays connection
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
  assign HEX2 = SEVSEG_OFF;
  assign HEX3 = SEVSEG_OFF;
  assign HEX4 = SEVSEG_OFF;
  assign HEX5 = SEVSEG_OFF;
  assign HEX6 = SEVSEG_OFF; 
  assign HEX7 = SEVSEG_OFF;

  // memory module instance
  wire [7:0] mem_wire;
  assign numbers[0] = mem_wire[3:0];
  assign numbers[1] = mem_wire[7:4];
  memory
  #(
    .BIT_DEPTH(8),
    .ADDR_BIT_DEPTH(3)
  )
  mem
  (
    .clk(CLOCK_50),
    .reset(key_pressed[0]),
    .addr(SW[17:15]),
    .val2write(SW[7:0]),
    .val2read(mem_wire)
  );
endmodule
