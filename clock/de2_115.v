/*
 *  Task #9
 * Just simple clock. 
 */

`include "../library.v"

module clock
#(
  parameter CLOCK_FREQ = 50000000 // 50 MHz
)
(
  input  wire clk,
  input  wire reset,
  input  wire change_mode,
  input  wire conf_next,
  input  wire conf_incr,
  output reg  [7:0] seconds,
  output reg  [7:0] minutes,
  output reg  [7:0] hours
);
  reg conf_mode;
  reg [1:0] conf_pos;
  wire timer_event;
  wire inc_seconds = ((conf_pos == 0) & conf_incr & conf_mode) | (timer_event & ~conf_mode);
  wire inc_minutes = ((conf_pos == 1) & conf_incr & conf_mode) | (timer_event & ~conf_mode & seconds == 59);
  wire inc_hours   = ((conf_pos == 2) & conf_incr & conf_mode) | (timer_event & ~conf_mode & seconds == 59 & minutes == 59);
  wire change_pos  = conf_next & conf_mode;

  always @(posedge clk)
  begin
    if (reset) // Do reset
    begin
      conf_mode <= 0;
      conf_pos  <= 0;
      seconds   <= 0;
      minutes   <= 0;
      hours     <= 0;
    end
    else if (change_mode) // Change mode
    begin
      conf_mode <= ~conf_mode;
      conf_pos  <= conf_pos;
    end
    else if (change_pos) // Change pos in conf mode
      conf_pos <= (conf_pos < 3) ? conf_pos + 1 : 0;
    else  
    begin // Increment time
      if (inc_seconds)
        seconds <= (seconds < 59) ? seconds + 1 : 0;

      if (inc_minutes)
        minutes <= (minutes < 59) ? minutes + 1 : 0;

      if (inc_hours)
        hours   <= (minutes < 23) ? hours + 1 : 0;
    end
  end

  timer
  #(
    .BIT_DEPTH(17) 
  )
  timer_inst
  (
    .clk(clk),
    .reset(reset | timer_event),
    // Generate event every second
    .cmp_val(CLOCK_FREQ - 1),
    .cmp_flag(timer_flag)
  );
endmodule

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
  parameter SEVSEG_OFF = 7'b1111111;
  parameter CLOCK_FREQ = 50000000;   // 50 MHz

  // 4 buttons sychronization
  wire [3:0] key_pressed;
  de2_115_buttons
  buttons
  (
    .clk(CLOCK_50),
    .buttons(KEY),
    .pressed(key_pressed)
  );

  // 7-segment displays connection
  wire [6:0] digits  [7:0];
  wire [3:0] numbers [7:0];
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1)
    begin: sevseg_loop
      sevseg ss
      (
        .number(numbers[i]),
        .digit(digits[i])
      );
    end
  endgenerate
  assign HEX0 = SEVSEG_OFF;
  assign HEX1 = SEVSEG_OFF;
  assign HEX2 = digits[0];
  assign HEX3 = digits[1];
  assign HEX4 = digits[2];
  assign HEX5 = digits[3]; 
  assign HEX6 = digits[4];
  assign HEX7 = digits[5];

  // Clock module
  wire [7:0] seconds;
  wire [7:0] minutes;
  wire [7:0] hours;
  clock
  #(
    .CLOCK_FREQ(CLOCK_FREQ)
  )
  (
    .clk(clk),
    .reset(key_pressed[0]),
    .change_mode(key_pressed[1]),
    .conf_next(key_pressed[2]),
    .conf_incr(key_pressed[3]),
    .seconds(seconds),
    .minutes(minutes),
    .hours(hours)
  );

  // Notation modules, flash means working without registers 
  notation_flash
  #(
    .BIT_DEPTH(8),
    .NUM_DIGITS(2),
    .BASE(10)
  )
  seconds_notation 
  (
    .number(seconds),
    .digits({numbers[1], numbers[0]})
  );

  notation_flash
  #(
    .BIT_DEPTH(8),
    .NUM_DIGITS(2),
    .BASE(10)
  )
  minutes_notation 
  (
    .number(minutes),
    .digits({numbers[3], numbers[2]})
  );

  notation_flash
  #(
    .BIT_DEPTH(8),
    .NUM_DIGITS(2),
    .BASE(10)
  )
  hours_notation 
  (
    .number(hours),
    .digits({numbers[5], numbers[4]})
  );
endmodule
