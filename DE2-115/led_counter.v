// DE2-115 task 2
/*
*   Goal is to create device, that can increment, decrement and reset value via
* buttons and output result to 3 leds
*/


// Top level module, should be connected to DE2-115 pins
// Recive inputs from buttons and output number to 7-segment display
module led_counter
(
  input  wire       clk,          
  input  wire       inc_button,
  input  wire       dec_button,
  input  wire       reset_button,
  output wire [7:0] leds
);
wire [2:0] cnt_wire;
wire rb_wire;
wire db_wire;
wire ib_wire;
button
rb_sync
(
  .clk(clk),
  .button_async(reset_button),
  .button_sync(rb_wire)
);
button
db_sync
(
  .clk(clk),
  .button_async(dec_button),
  .button_sync(db_wire)
);
button
ib_sync
(
  .clk(clk),
  .button_async(inc_button),
  .button_sync(ib_wire)
);
counter 
#(
  .BIT_DEPTH(3)
)
cnt 
(
  .clk(clk),
  .inc(ib_wire),
  .dec(db_wire),
  .reset(rb_wire),
  .value(cnt_wire)
);
genvar gi;
generate for (gi = 0; gi < 7; gi = gi + 1)
begin: loop_1
  assign leds[gi] = (gi < cnt_wire);
end
endgenerate
endmodule

/*
// Test for simulator
module test ();
// TODO:
endmodule
*/
