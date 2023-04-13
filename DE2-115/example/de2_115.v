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
genvar i;
generate
  for (i = 0; i < 4; i = i + 1)
  begin: buttons_loop
    button key_sync_button
    (
      .clk(CLOCK_50),
      .button_async(KEY[i]),
      .button_sync(key_sync[i])
    );
  end
endgenerate
endmodule
