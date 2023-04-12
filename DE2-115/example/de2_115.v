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
  output wire [6:0]  HEX6
);
// 4 buttons synchronization
wire [3:0] key_sync;
button
key0_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[0]),
  .button_sync(key_sync[0])
);
button
key1_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[1]),
  .button_sync(key_sync[1])
);
button
key2_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[2]),
  .button_sync(key_sync[2])
);
button
key3_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[3]),
  .button_sync(key_sync[3])
);
endmodule
