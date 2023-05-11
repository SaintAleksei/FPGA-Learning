/*
 *          #2 Task: Led Counter
 *    Goal is to create device that will increase and decrease number of 
 * lightning leds using buttons
 *    Interface:
 *      * KEY0 - reset
 *      * KEY1 - increase number of leds
 *      * KEY2 - decrease number of leds
 */
 
// TODO: Test on real board

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
  output wire [6:0]  HEX6,
  output wire [6:0]  HEX7
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
  wire [2:0] cnt_wire;
  counter 
  #(
    .BIT_DEPTH(3)
  )
  cnt 
  (
    .clk(CLOCK_50),
    .inc(key_sync[1]),
    .dec(key_sync[2]),
    .reset(key_sync[0]),
    .value(cnt_wire)
  );
  genvar gi;
  generate for (gi = 0; gi < 7; gi = gi + 1)
  begin: loop_1
    assign LEDR[gi] = (gi < cnt_wire);
  end
  endgenerate
endmodule
