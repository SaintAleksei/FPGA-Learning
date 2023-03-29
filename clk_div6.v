`timescale 1ns/1ps

module counter
(
  input wire clk,
  input wire reset,
  input wire [7:0] cmp_val,
  output reg [7:0] cnt_val,
  output wire      cmp_flag
);
assign cmp_flag = (cnt_val >= cmp_val) ? 1 : 0;
always @(posedge clk)
  if (reset)
    cnt_val <= 0;
  else 
    cnt_val <= cnt_val + 1;
endmodule

module clk_divider
(
  input  wire       clk,
  input  wire       reset,
  input  wire [7:0] factor, // Must be >= 2
  output reg        clk_divided
);
wire counter_flag;
wire reset_counter = reset | counter_flag;
wire [7:0] counter;
counter
cnt
(
  .clk(clk),
  .reset(reset_counter),
  .cmp_val((factor >> 1) - 8'b1),
  .cnt_val(counter),
  .cmp_flag(counter_flag)
);
always @(posedge clk)
  if (reset)
    clk_divided <= 0;
  else
    clk_divided <= (counter_flag) ? ~clk_divided : clk_divided;
endmodule 

module test;
reg clk;
reg reset;
wire clk_divided;
clk_divider
clk_div6
(
  .clk(clk),
  .reset(reset),
  .factor(8'h06),
  .clk_divided(clk_divided)
);
initial
begin
  $dumpfile("/home/sa/fpga/dump.vcd");
  $dumpvars(0, test.clk_div6);
  reset = 1;
  #2;
  reset = 0;
  #100;
  $stop;
end
always
begin
  clk = 0;
  #1;
  clk = 1;
  #1;
end
endmodule
