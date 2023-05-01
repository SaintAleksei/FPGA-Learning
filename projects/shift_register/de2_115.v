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
reg [3:0] key_sync_repeat;
always @(posedge CLOCK_50)
begin
  key_sync_repeat[0] <= key_sync[0];  
  key_sync_repeat[1] <= key_sync[1];  
  key_sync_repeat[2] <= key_sync[2];  
  key_sync_repeat[3] <= key_sync[3];  
end
wire [3:0] key_sync_double = key_sync | key_sync_repeat;
shiftreg
#(
  .BIT_DEPTH(8)
)
sr
(
  .clk(CLOCK_50),
  .reset(key_sync[0]),
  .left_shift_bit(SW[0]),
  .left_shift_event(key_sync_double[2]),
  .right_shift_bit(SW[1]),
  .right_shift_event(key_sync_double[1]),
  .register(LEDR[7:0])
); 
endmodule
