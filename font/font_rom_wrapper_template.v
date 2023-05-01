`include "font/{{FONT_NAME}}.v"

module font_rom_wrapper
#(
  parameter XY_BIT_DEPTH = 8
)
(
  input wire  [XY_BIT_DEPTH-1:0] sym_x,
  input wire  [XY_BIT_DEPTH-1:0] sym_y,
  input wire  [7:0]              sym_code,
  output wire                    sym_pixel
);
  {{FONT_NAME}}
  #(
    .XY_BIT_DEPTH(XY_BIT_DEPTH)
  )
  font_rom_wrapped
  (
    .sym_x(sym_x),
    .sym_y(sym_y),
    .sym_code(sym_code),
    .sym_pixel(sym_pixel)
  );
endmodule
