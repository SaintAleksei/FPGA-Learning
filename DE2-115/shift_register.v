// DE2-115 task 3
/*
*   Goal is to create device, that can increment, decrement and reset value via
* buttons and output result to 3 leds
*/

module shift_reg
(
  input  clk,
  input  reset,
  input  left_shift_bit,
  input  left_shift_event,
  input  right_shift_bit,
  input  right_shift_event,
  output [7:0] leds
);
wire left_event;
wire right_event;
wire reset_event;
button
rb_sync
(
  .clk(clk),
  .button_async(reset),
  .button_sync(reset_event)
);
button
db_sync
(
  .clk(clk),
  .button_async(left_shift_event),
  .button_sync(left_event)
);
button
ib_sync
(
  .clk(clk),
  .button_async(right_shift_event),
  .button_sync(right_event)
);
shiftreg
#(
  .BIT_DEPTH(8)
)
sr
(
  .clk(clk),
  .reset(reset_event),
  .left_shift_bit(left_shift_bit),
  .left_shift_event(left_event),
  .right_shift_bit(right_shift_bit),
  .right_shift_event(right_event),
  .register(leds)
); 
endmodule
