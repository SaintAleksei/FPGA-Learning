/*
 * Template file that can be used in many projects
 */

`include "../library.v"

module de2_115
(
  input  wire        CLOCK_50, // Clock
  input  wire [17:0] SW,       // Switches
  input  wire [3:0]  KEY,      // Buttons, 1 when unpressed
  output wire [17:0] LEDR,     // Red leds
  output wire [8:0]  LEDG,     // Green leds
  output wire [6:0]  HEX0,     // 7-segment displays
  output wire [6:0]  HEX1,
  output wire [6:0]  HEX2,
  output wire [6:0]  HEX3,
  output wire [6:0]  HEX4,
  output wire [6:0]  HEX5,
  output wire [6:0]  HEX6,
  output wire [6:0]  HEX7
);
// 4 buttons sychronization
wire [3:0] key_sync;
genvar i;
generate
  for (i = 0; i < 4; i = i + 1)
  begin: buttons_loop
    button key_sync_button
    (
      .clk(CLOCK_50),
      .button_async(KEY[i]),
      .button_sync(key_sync[i])
    );
  end
endgenerate

// 7-segment displays connection
wire [6:0] digits  [4:0];
reg  [3:0] numbers [4:0];
generate
  for (i = 0; i < 5; i = i + 1)
  begin: dec_loop
    sevseg ss_dec
    (
      .number(numbers[i]),
      .digit(digits[i])
    );
  end
endgenerate
assign HEX0 = digits[0];
assign HEX1 = digits[1];
assign HEX2 = digits[2];
assign HEX4 = digits[3];
assign HEX5 = digits[4];

// Register conatining value
reg [7:0] value;


// Output dec to 7-segment displays
reg  [7:0] div_value     [1:0];
reg        div_load      [1:0];
wire [7:0] div_result    [1:0];
wire [7:0] div_remainder [1:0];
wire       div_ready     [1:0];
div divider_by10
(
  .reset(key_sync[0]),
  .clk(CLOCK_50),
  .load(div_load[0]),
  .value(div_value[0]),
  .ready(div_ready[0]),
  .result(div_result[0]),
  .remainder(div_remainder[0])
);
div 
#(
  .DIVIDER(100)
)
divider_by100
(
  .reset(key_sync[0]),
  .clk(CLOCK_50),
  .load(div_load[1]),
  .value(div_value[1]),
  .ready(div_ready[1]),
  .result(div_result[1]),
  .remainder(div_remainder[1])
);
always @(posedge CLOCK_50)
  if (key_sync[0])
  begin
    numbers[0] <= 8'b00000000;
    numbers[1] <= 8'b00000000;
    numbers[2] <= 8'b00000000;
    numbers[3] <= 8'b00000000;
    numbers[4] <= 8'b00000000;
    div_load[0] <= 1'b0;
    div_load[1] <= 1'b0;
  end
  else if (key_sync[1])
  begin
    div_value[0] <= SW[7:0];
    div_value[1] <= SW[7:0];
    div_load[1] <= 1'b1;
    div_load[1] <= 1'b1;
    numbers[3] <= SW[3:0];
    numbers[4] <= SW[7:4];
  end
  else if (div_ready[0])
    numbers[2] <= div_result[1];
  else if (div_ready[1])
  begin
    numbers[0] <= div_remainder[0];
    numbers[1] <= div_result[0];
  end
endmodule
