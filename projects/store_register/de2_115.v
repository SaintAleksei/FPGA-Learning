`include "../library.v"

module de2_115
(
  input  wire        CLOCK_50,
  input  wire [17:0] SW,
  input  wire [3:0]  KEY,
  output wire [17:0] LEDR,
  output wire [8:0]  LEDG,
  output wire [6:0]  HEX0,
  output wire [6:0]  HEX1,
  output wire [6:0]  HEX2,
  output wire [6:0]  HEX3,
  output wire [6:0]  HEX4,
  output wire [6:0]  HEX5,
  output wire [6:0]  HEX6
);
// Sync buttons
wire [3:0] key_sync;
button
key0_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[0]),
  .button_sync(key_sync[0])
);
button
key1_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[1]),
  .button_sync(key_sync[1])
);
button
key2_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[2]),
  .button_sync(key_sync[2])
);
button
key3_sync
(
  .clk(CLOCK_50),
  .button_async(KEY[3]),
  .button_sync(key_sync[3])
);

// Task logic
reg [7:0] red_value;
assign LEDR = red_value;
reg [7:0] green_value;
assign LEDG = green_value;
always @(posedge CLOCK_50)
  if (key_sync[0])
  begin
    red_value   <= 8'b00000000;
    green_value <= 8'b00000000;
  end
  else if (key_sync[1])
    red_value <= SW[7:0];
  else if (key_sync[2])
  begin
    green_value <= {red_value[0], green_value[7:1]};
    red_value   <= {SW[8], red_value[7:1]};
  end

// Connect 7-segment displays
sevseg
ss_hex0
(
  .number(red_value[3:0]), 
  .digit(HEX0)
);
sevseg
ss_hex1
(
  .number(red_value[7:4]),
  .digit(HEX1)
);
endmodule
