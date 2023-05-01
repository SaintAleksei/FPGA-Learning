`define FONT_HEIGHT {{FONT_HEIGHT}}
`define FONT_WIDTH  {{FONT_WIDTH}}

module {{FONT_NAME}}
#(
  parameter XY_BIT_DEPTH = 8
)
(
  input wire  [XY_BIT_DEPTH-1:0] sym_x,
  input wire  [XY_BIT_DEPTH-1:0] sym_y,
  input wire  [7:0]              sym_code,
  output wire                    sym_pixel
);

  wire [`FONT_WIDTH-1:0] font [`FONT_HEIGHT-1:0] [255:0];

// Here all font bits should be assigned
{{FONT_GENERATION}}

  assign pixel = font[sym_y][sym_code][sym_x];
endmodule
