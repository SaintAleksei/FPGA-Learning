`include "lib/library.v"
`include "font/font_rom_wrapper.v"
`timescale 1ns / 1ns

module tb_vga_text;
  reg clk;
  reg reset;
  wire [7:0] red;
  wire [7:0] green;
  wire [7:0] blue;
  wire hsync;
  wire vsync;

  wire [$clog2(`FONT_WIDTH)-1:0]  sym_x;
  wire [$clog2(`FONT_HEIGHT)-1:0] sym_y;
  wire [7:0] sym_code;
  wire sym_pixel;
  font_rom_wrapper
  font_rom
  (
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),
    .sym_pixel(sym_pixel)
  );

  parameter SYM_PER_LINE = 640 / `FONT_WIDTH;
  parameter LINE_PER_SCREEN = 480 / `FONT_HEIGHT;
  wire [8 * SYM_PER_LINE * LINE_PER_SCREEN - 1:0] text;

  genvar gi;
  generate
    for (gi = 0; gi < SYM_PER_LINE * LINE_PER_SCREEN; gi = gi + 1)
    begin: text_loop
      assign text[(gi + 1) * 8 - 1: gi * 8] =  gi % 256;
    end
  endgenerate

  vga_text
  #(
    .FONT_WIDTH(`FONT_WIDTH),
    .FONT_HEIGHT(`FONT_HEIGHT)
  )
  vga_text_dut
  (
    .clk(clk),
    .reset(reset),

    .text(text),
    .line_offset(4'b0000),

    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),
    .sym_pixel(sym_pixel),

    .red(red),
    .green(green),
    .blue(blue),
    .hsync(hsync),
    .vsync(vsync)
  );

  always
    #1 clk = ~clk;

  initial
  begin
    $vgasim(red, green, blue, hsync, vsync, clk);
    clk = 0;
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
  end
endmodule
