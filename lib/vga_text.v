`ifndef VGA_TEXT_INCLUDED
`define VGA_TEXT_INCLUDED

`ifdef ICARUS_VERILOG
`include "lib/library.v"
`endif

module vga_text
#(
  // VGA timings 
  parameter HOR_FRONT_PORCH = 16,
  parameter HOR_SYNC_PULSE  = 96,
  parameter HOR_BACK_PORCH  = 48,
  parameter HOR_RES         = 640,
  parameter VER_FRONT_PORCH = 10,
  parameter VER_SYNC_PULSE  = 2,
  parameter VER_BACK_PORCH  = 33,
  parameter VER_RES         = 480,
  
  // Color bit-depth
  parameter COLOR_BIT_DEPTH = 8,

  // font parameters
  parameter FONT_WIDTH      = 16,
  parameter FONT_HEIGHT     = 8
)
(
  // Clock and reset
  input  wire clk,
  input  wire reset,

  // Text buffer
  input  wire [TEXT_SIZE-1:0] text,
  input  wire [$clog2(TEXT_LINES_PER_SCREEN)-1:0] line_offset,
  
  // This wires should be connected to font module
  input  wire sym_pixel,
  output wire [7:0] sym_code,
  output wire [$clog2(FONT_WIDTH)-1:0] sym_x,
  output wire [$clog2(FONT_HEIGHT)-1:0] sym_y,

  // This wires should be connected to VGA (through COLOT_BIT_DEPTH-bit DAC)
  output wire [COLOR_BIT_DEPTH-1:0] red,
  output wire [COLOR_BIT_DEPTH-1:0] green,
  output wire [COLOR_BIT_DEPTH-1:0] blue,
  output wire hsync,
  output wire vsync,

  output wire blank_n,
  output wire sync_n
);
  localparam TEXT_SYMS_PER_LINE    = HOR_RES / FONT_WIDTH;
  localparam TEXT_LINES_PER_SCREEN = VER_RES / FONT_HEIGHT;
  localparam HOR_BACK_PORCH_START  = HOR_SYNC_PULSE;
  localparam HOR_DATA_START        = HOR_BACK_PORCH_START + HOR_BACK_PORCH;
  localparam HOR_FRONT_PORCH_START = HOR_DATA_START + HOR_RES;
  localparam HOR_MAX               = HOR_FRONT_PORCH_START + HOR_FRONT_PORCH;
  localparam VER_BACK_PORCH_START  = VER_SYNC_PULSE;
  localparam VER_DATA_START        = VER_BACK_PORCH_START + VER_BACK_PORCH;
  localparam VER_FRONT_PORCH_START = VER_DATA_START + VER_RES;
  localparam VER_MAX               = VER_FRONT_PORCH_START + VER_FRONT_PORCH;

  localparam HOR_BIT_DEPTH = $clog2(HOR_MAX);
  localparam VER_BIT_DEPTH = $clog2(VER_MAX);

  localparam TEXT_SIZE = TEXT_SYMS_PER_LINE * TEXT_LINES_PER_SCREEN * 8;

  reg [HOR_BIT_DEPTH-1:0] hcnt;
  reg [VER_BIT_DEPTH-1:0] vcnt;

  assign sync_n = 1'b1;
  assign blank_n = (hcnt >= HOR_DATA_START) &
                   (hcnt < HOR_FRONT_PORCH_START) &
                   (vcnt >= VER_DATA_START) &
                   (vcnt < VER_FRONT_PORCH_START);
  wire show_pixel = (hcnt >= HOR_DATA_START && hcnt < HOR_FRONT_PORCH_START) &
                    (vcnt >= VER_DATA_START && vcnt < VER_FRONT_PORCH_START) & 
                    (hor_sym_cnt < TEXT_SYMS_PER_LINE) &
                    (ver_sym_cnt < TEXT_SYMS_PER_LINE) &
                     sym_pixel;
  assign hsync = (hcnt >= HOR_BACK_PORCH_START);
  assign vsync = (vcnt >= VER_BACK_PORCH_START);
  assign red   = {COLOR_BIT_DEPTH{show_pixel}};
  assign green = red;
  assign blue  = red;
  wire [$clog2(TEXT_SYMS_PER_LINE)-1:0] hor_sym_cnt;
  wire [$clog2(TEXT_LINES_PER_SCREEN)-1:0] ver_sym_cnt;
  wire hor_data_cnt_flag = (hcnt >= HOR_DATA_START) & (hcnt < HOR_FRONT_PORCH_START);
  wire [HOR_BIT_DEPTH-1:0] hor_data_cnt = {HOR_BIT_DEPTH{hor_data_cnt_flag}} & 
                                          (hcnt - HOR_DATA_START);
  wire ver_data_cnt_flag = (vcnt >= VER_DATA_START) & (vcnt < VER_FRONT_PORCH_START);
  wire [VER_BIT_DEPTH-1:0] ver_data_cnt = {VER_BIT_DEPTH{ver_data_cnt_flag}} & 
                                          (vcnt - VER_DATA_START);

  wire [$clog2(TEXT_LINES_PER_SCREEN)-1:0] line_idx_norm; 
  wire [$clog2(TEXT_LINES_PER_SCREEN):0] line_idx_dividend = ver_sym_cnt + line_offset;
  division_tickless
  #(
    // FIXME: Why is +2 ??? ( +1 and less doesn't work -_-)
    .BIT_DEPTH($clog2(TEXT_LINES_PER_SCREEN)+2)
  )
  line_idx_div
  (
    .dividend(line_idx_dividend),
    .divisor(TEXT_LINES_PER_SCREEN),
    .remainder(line_idx_norm)
  );

  division_tickless
  #(
    .BIT_DEPTH(HOR_BIT_DEPTH)
  )
  hcnt_div
  (
    .dividend(hor_data_cnt),
    .divisor(FONT_WIDTH[HOR_BIT_DEPTH-1:0]),
    .quotient(hor_sym_cnt),
    .remainder(sym_x)
  );

  division_tickless
  #(
    .BIT_DEPTH(VER_BIT_DEPTH) 
  )
  vcnt_div
  (
    .dividend(ver_data_cnt),
    .divisor(FONT_HEIGHT[VER_BIT_DEPTH-1:0]),
    .quotient(ver_sym_cnt),
    .remainder(sym_y)
  );
  
  // FIXME: What if sym_idx > size of text?
  wire [$clog2(TEXT_SIZE)-1:0] sym_idx = hor_sym_cnt + line_idx_norm * TEXT_SYMS_PER_LINE;
  genvar gi;
  generate
    for (gi = 0; gi < 8; gi = gi + 1)
    begin: sym_code_loop
      assign sym_code[gi] = text[(sym_idx) * 8 + gi];
    end
  endgenerate

  always @(posedge clk)
  begin
    if (reset)
    begin
      hcnt <= 0;
      vcnt <= 0;
    end
    else
    begin
      hcnt <= (hcnt == HOR_MAX - 1) ? 0 : hcnt + 1;
      vcnt <= (hcnt != HOR_MAX - 1) ? vcnt :
              (vcnt == VER_MAX - 1) ? 0 : vcnt + 1;
    end
  end
endmodule 

`endif // VGA_TEXT_INCLUDED
