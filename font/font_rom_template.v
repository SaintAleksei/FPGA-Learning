`define FONT_HEIGHT {{FONT_HEIGHT}}
`define FONT_WIDTH  {{FONT_WIDTH}}

module {{FONT_NAME}}
(
  input wire  [$clog2(`FONT_WIDTH)-1:0]  sym_x,
  input wire  [$clog2(`FONT_HEIGHT)-1:0] sym_y,
  input wire  [7:0]              sym_code,
  output wire                    sym_pixel
);

  wire [0:`FONT_WIDTH-1] font [`FONT_HEIGHT-1:0] [255:0];

// Here all font bits should be assigned
{{FONT_GENERATION}}

  assign sym_pixel = font[sym_y][sym_code][sym_x];
endmodule
