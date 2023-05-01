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

  wire [0:`FONT_WIDTH-1] font [`FONT_HEIGHT-1:0] [255:0];

// Here all font bits should be assigned
{{FONT_GENERATION}}

  assign sym_pixel = font[sym_y][sym_code][sym_x];
endmodule
