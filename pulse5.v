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

module pulse5
(
  input wire clk,
  input wire reset,
  output wire out
);
wire cmp_flag;
wire reset_counter = reset | cmp_flag;
wire [7:0] counter;
assign out = cmp_flag;
counter
cnt
(
  .clk(clk),
  .reset(reset_counter),
  .cmp_val(8'h4),
  .cnt_val(counter),
  .cmp_flag(cmp_flag)
);
endmodule

module test;
reg clk;
reg reset;
wire pulse;
pulse5
pulse5
(
  .clk(clk),
  .reset(reset),
  .out(pulse)
);
initial
begin
  clk = 0;
  reset = 1;
  #2;
  reset = 0;
  #50;
  $stop;
end
always
begin
  #1 clk = ~clk;
end
endmodule