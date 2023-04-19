/*
 * Template file that can be used in many projects
 */

`include "../library.v"

module stopwatch
#(
  parameter MEM_ADDR_BIT_DEPTH = 2,
  parameter BIT_DEPTH          = 8,
  parameter MEM_SIZE           = 1 << MEM_ADDR_BIT_DEPTH
(
)
  input  wire clk,
  input  wire reset,
  input  wire start_stop,
  input  wire write,
  input  wire show,
  output wire [BIT_DEPTH-1:0] current;
  output wire [BIT_DEPTH-1:0] temporary;
);
  reg [BIT_DEPTH-1:0]          saved_time [MEM_SIZE:0];
  reg [BIT_DEPTH-1:0]          temporary_time;
  reg [MEM_ADDR_BIT_DEPTH-1:0] idx;
  reg start;
  assign current   = saved_time[idx];
  assign temporary = temporary_time;
  genvar i;
  always @(posedge clk)
  begin
    if (reset)
    begin
      generate 
        for (i = 0; i <= MEMORY_SIZE; i = i + 1)
        begin: stopwatch_reset_loop
          saved_time[i] <= 0;
        end
      endgenerate
      temporary <= 0;
      start     <= 0;
      idx       <= 0;
    end
    else if (start_stop)
    begin
      start <= ~start;
      idx   <= 0;
    end
    else if (write)
      if (start && idx < MEMORY_SIZE) // Save new time into memory
      begin
        temporary_time      = saved_time[0];
        saved_time[idx + 1] = saved_time[0];
        idx                 = idx + 1;
      end

      if (!start) // Clear memory
      begin
        generate
          for (i = 0; i < MEMORY_SIZE; i = i + 1)
          begin: stopwatch_clear_memory_loop
            saved_time[i + 1] <= 0;
          end
        endgenerate
      end
    else if (show && !start)
      // TODO
      idx <= idx + 1;

    if (timer_event)
      saved_time[0] = saved_time[0] + 1;
  end
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
  output wire [6:0]  HEX5,
  output wire [6:0]  HEX6,
  output wire [6:0]  HEX7
);
  parameter MEM_SIZE   = 4;
  parameter CLOCK_FREQ = 50000000; // 50 MHz
  
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
  parameter SEVSEG_OFF = 7'b1111111;
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
  assign HEX1 = digits[1];
  assign HEX2 = digits[2];
  assign HEX3 = digits[3];
  assign HEX4 = digits[4];
  assign HEX5 = digits[5];
  assign HEX6 = SEVSEG_OFF;
  assign HEX7 = SEVSEG_OFF;

  wire [15:0] current_time;
  wire [15:0] temporary_time;

  // Submodules instantiation
  notation_self_reset
  current_time_notation // Output current time
  #(
    .BIT_DEPTH(16),
    .NUM_DIGITS(4),
    .BASE(10)
  (
    .clk(CLOCK_50),
    .reset(key_sync[0]),
    .number(saved_time[saved_time_idx]),
    .digits({numbers[3], numbers[2], numbers[1], numbers[0]}),
  );

  notation_self_reset
  temporary_time_notation // Output temprary time
  #(
    .BIT_DEPTH(16),
    .NUM_DIGITS(2),
    .BASE(10)
  (
    .clk(CLOCK_50),
    .reset(key_sync[0]),
    .number(temporary_result),
    .digits({numbers[5], numbers[4]}),
  );

  wire timer_event;
  timer
  timer_inst
  (
    .clk(CLOCK_50),
    .reset(key_sync[0] | timer_event),
    // Generate timer event every 0.1 second
    .cmp_val(CLOCK_FREQ / 10 - 1),
    .cmp_flag(timer_event)
  );
endmodule
