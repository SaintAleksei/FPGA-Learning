`include "library.b"

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

  parameter COLOR_BIT_DEPTH = 8,
  parameter HOR_BIT_DEPTH   = 12,
  parameter VER_BIT_DEPTH   = 12,

  parameter FONT_WIDTH      = 16,
  parameter FONT_HEIGH      = 16,

  parameter TEXT_SYMS_PER_LINE    = HOR_RES / FONT_WIDTH,
  parameter TEXT_LINES_PER_SCREEN = VER_RES / FONT_HEIGH
)
(
  // Clock and reset
  input  wire clk,
  input  wire reset,

  // Text buffer
  input  wire [7:0] text [TEXT_SYMS_PER_LINE * TEXT_LINES_PER_SCREEN - 1:0],
  
  // This wires should be connected to font module
  input  wire sym_pixel,
  output wire [7:0] sym_code,
  output wire [HOR_BIT_DEPTH-1:0] sym_x,
  output wire [VER_BIT_DEPTH-1:0] sym_y

  // This wire should be connected to VGA (through COLOT_BIT_DEPTH-bit DAC)
  output wire [COLOR_BIT_DEPTH-1:0] red,
  output wire [COLOR_BIT_DEPTH-1:0] green,
  output wire [COLOR_BIT_DEPTH-1:0] blue,
  output wire hsync,
  output wire vsync
)
  localparam HOR_BACK_PORCH_START = HOR_SYNC_PULSE;
  localparam HOR_DATA_START = HOR_BACK_PORCH_START + HOR_BACK_PORCH;
  localparam HOR_FONT_PORCH_START = HOR_DATA_START + HOR_RES;
  localparam VER_BACK_PORCH_START = VER_SYNC_PULSE;
  localparam VER_DATA_START = VER_BACK_PORCH_START + VER_BACK_PORCH;
  localparam VER_FONT_PORCH_START = VER_DATA_START + VER_RES;

  reg [HOR_BIT_DEPTH-1:0] hcnt;
  reg [VER_BIT_DEPTH-1:0] vcnt;

  assign hsync = (hcnt >= HOR_BACK_PORCH_START);
  assign vsync = (vcnt >= VER_BACK_PORCH_START);
  assign show_pixel = (hcnt >= HOR_DATA_START && hcnt < HOR_FRONT_PORCH) &
                      (vcnt >= VER_DATA_START && vcnt < VER_FRONT_PORCH); 
  assign red   = {COLOR_BIT_DEPTH{show_pixel}};
  assign green = red;
  assign blue  = red;

  wire [HOR_BIT_DEPTH-1:0] hor_sym_cnt;
  wire [HOR_BIT_DEPTH-1:0] ver_sym_cnt;
  division_flash
  hcnt_div
  #(
    .BIT_DEPTH(HOR_BIT_DEPTH)
  )
  (
    .dividend(hcnt),
    .divisor(FONT_WIDTH),
    .quotient(hor_sym_cnt),
    .remainder(sym_x)
  );

  division_flash
  vcnt_div
  #(
    .BIT_DEPTH(VER_BIT_DEPTH) 
  )
  (
    .dividend(vcnt),
    .divisor(FONT_HEIGH),
    .quotient(ver_sym_cnt),
    .remainder(sym_y)
  );

  assign sym_code = text[hor_sym_cnt + ver_sym_cnt * TEXT_SYMS_PER_LINE];
  
  always @(posedge clk)
    if (reset)
    begin
      hcnt <= 0;
      vcnt <= 0;
      ver_sym_cnt <= 0;
      hot_sym_cnt <= 0;
    end
    else
    begin
      hcnt <= (hcnt == HOR_RES - 1) ? 0 : hcnt + 1;
      vcnt <= (hcnt != HOR_RES - 1) ? vcnt :
              (vcnt == VER_RES - 1) ? 0 : vcnt + 1;
  end
endmodule 
