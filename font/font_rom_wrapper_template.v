`include "font/{{FONT_NAME}}.v"

module font_rom_wrapper
(
  input wire  [$clog2(`FONT_WIDTH)-1:0] sym_x,
  input wire  [$clog2(`FONT_HEIGHT)-1:0] sym_y,
  input wire  [7:0]              sym_code,
  output wire                    sym_pixel
);
  {{FONT_NAME}}
  font_rom_wrapped
  (
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),
    .sym_pixel(sym_pixel)
  );
endmodule
