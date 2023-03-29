module pwm
(
  input  wire       clk,
  input  wire       reset,
  input  wire [0:7] comp_val,
  output reg        out,
);
