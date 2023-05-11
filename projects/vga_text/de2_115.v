/*
 *          Project demostrating vga_text module on real board
 *  Interface:
 *    * KEY0 - reset
 *    * KEY1 - increment line_offset, scroll picture up by 1 line
 *    * KEY2 - decrement line_offset, scroll picture down by 1 line
 */

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
  output wire        VGA_CLK,
  output wire        VGA_HS,
  output wire        VGA_VS,
  output wire        VGA_BLANK_N,
  output wire        VGA_SYNC_N
);
  localparam SEVSEG_OFF  = 7'b1111111;
  localparam FONT_WIDTH  = 14;
  localparam FONT_HEIGHT = 32;

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


  localparam TEXT_SYMS_PER_LINE = 640 / FONT_WIDTH;
  localparam TEXT_LINES_PER_SCREEN = 480 / FONT_HEIGHT;

  wire [8 * TEXT_SYMS_PER_LINE * TEXT_LINES_PER_SCREEN - 1:0] text;

  genvar gi;
  generate
    for (gi = 0; gi < TEXT_SYMS_PER_LINE * TEXT_LINES_PER_SCREEN; gi = gi + 1)
    begin: text_loop
      assign text[(gi + 1) * 8 - 1: gi * 8] = gi % 256;
    end
  endgenerate

  reg pixel_clock;
  always @(posedge CLOCK_50)
    if (key_pressed[0])
      pixel_clock <= 0;
    else
      pixel_clock <= ~pixel_clock;
  assign VGA_CLK = pixel_clock;

  wire [$clog2(FONT_WIDTH)-1:0]  sym_x;
  wire [$clog2(FONT_HEIGHT)-1:0] sym_y;
  wire [7:0] sym_code;
  wire sym_pixel;
  font_vt323_14x32
  font_rom
  (
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_pixel(sym_pixel),
    .sym_code(sym_code)
  );

  reg [7:0] line_offset;
  vga_text
  #(
    .FONT_WIDTH(FONT_WIDTH),
    .FONT_HEIGHT(FONT_HEIGHT)
  )
  vga_text_inst 
  (
    .clk(pixel_clock), 
    .reset(key_pressed[0]),

    .text(text),
    .line_offset(line_offset),

    .sym_pixel(sym_pixel),
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),

    .red(VGA_R),
    .green(VGA_G),
    .blue(VGA_B),
    .hsync(VGA_HS),
    .vsync(VGA_VS),
    .sync_n(VGA_SYNC_N),
    .blank_n(VGA_BLANK_N)
  );

  assign numbers[0] = line_offset[3:0];
  assign numbers[1] = line_offset[7:4];

  always @(posedge CLOCK_50)
  begin
    if (key_pressed[0])
      line_offset <= 8'b0;
    else if (key_pressed[1]) 
      line_offset <= (line_offset == TEXT_LINES_PER_SCREEN - 1) ? 0 : line_offset + 8'b1;
    else if (key_pressed[2])
      line_offset <= (line_offset == TEXT_LINES_PER_SCREEN - 1) ? 0 : line_offset - 8'b1;
  end
endmodule
