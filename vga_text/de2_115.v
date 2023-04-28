/*
 * Template file that can be used in many projects
 */

`include "../library.v"
`include "../font_vt323_8x16.v"

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
  output wire [6:0]  HEX7,
  output wire [7:0]  VGA_R,    // VGA
  output wire [7:0]  VGA_G,
  output wire [7:0]  VGA_B,
  output wire        VGA_HS,
  output wire        VGA_VS,
  output wire        VGA_BLANK_N,
  output wire        VGA_SYNC_N
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
  assign HEX0 = SEVSEG_OFF;
  assign HEX1 = SEVSEG_OFF;
  assign HEX2 = SEVSEG_OFF;
  assign HEX3 = SEVSEG_OFF;
  assign HEX4 = SEVSEG_OFF;
  assign HEX5 = SEVSEG_OFF;
  assign HEX6 = SEVSEG_OFF; 
  assign HEX7 = SEVSEG_OFF;


  localparam SYM_PER_LINE = 640 / 16;
  localparam LINE_PER_SCREEN = 480 / 8;

  wire [8 * SYM_PER_LINE * LINE_PER_SCREEN - 1:0] text;

  genvar gi;
  generate
    for (gi = 0; gi < SYM_PER_LINE * LINE_PER_SCREEN; gi = gi + 1)
    begin: text_loop
      assign text[(gi + 1) * 8 - 1: gi * 8] =  gi % 256;
    end
  endgenerate

  reg pixel_clock;
  always @(posedge CLOCK_50)
    if (key_pressed[0])
      pixel_clock <= 0;
    else
      pixel_clock <= ~pixel_clock;

  wire sym_x;
  wire sym_y;
  wire sym_pixel;
  wire sym_code;
  font_vt323_8x16 
  font
  (
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_pixel(sym_pixel),
    .sym_code(sym_code)
  );

  vga_text
  vga_text_inst 
  (
    .clk(pixel_clock), 
    .reset(key_pressed[0]),

    .text(text),

    .sym_pixel(sym_pixel),
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),

    .red(VGA_R),
    .green(VGA_G),
    .blue(VGA_B),
    .hsync(VGA_HS),
    .vsync(VGA_VS)
  );
endmodule
