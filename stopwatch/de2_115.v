/*
 *  Task #7
 *  Goal is to create stopwatch device. It counts time with 0.1 second accuracy and 
 * have memory for storing results. Additionaly it have output of temporary result.
 */

`include "../library.v"

module stopwatch
#(
  parameter MEM_ADDR_BIT_DEPTH = 2,
  parameter BIT_DEPTH          = 8,
  parameter CLOCK_FREQ         = 50000000 // 50 MHz
)
(
  input  wire clk,
  input  wire reset,
  input  wire start_stop,
  input  wire write,
  input  wire show,
  output wire [BIT_DEPTH-1:0] current,
  output reg  [BIT_DEPTH-1:0] temporary
);
  parameter MEM_SIZE = 1 << MEM_ADDR_BIT_DEPTH;

  // Memory registers
  reg [BIT_DEPTH-1:0] saved_time [MEM_SIZE:0];
  // Memory read/write idx
  reg [MEM_ADDR_BIT_DEPTH-1:0] mem_idx;
  // Memory show idx
  reg [MEM_ADDR_BIT_DEPTH-1:0] show_idx;
  reg start;

  // Assign current value
  assign current = saved_time[show_idx];

  // Device logic
  integer i;
  always @(posedge clk)
  begin
    if (reset)
    begin
      for (i = 0; i <= MEM_SIZE; i = i + 1)
        saved_time[i] <= 0;
      temporary  <= 0;
      start      <= 0;
      mem_idx    <= 0;
      show_idx   <= 0;
    end
    else if (start_stop)
    begin
      start     <= ~start;
      mem_idx   <= 0;
      show_idx  <= 0;
    end
    else if (write)
      if (start && mem_idx < MEM_SIZE) // Save new time into memory if running 
      begin
        saved_time[mem_idx + 1] <= saved_time[0];
        mem_idx                 <= mem_idx + 1;
      end

      temporary <= saved_time[0]; // Update temporary time

      if (!start) // Clear memory if not running
        for (i = 1; i <= MEM_SIZE; i = i + 1)
          saved_time[i] <= 0;
    else if (show && !start) // Show memory if not running
      show_idx <= (show_idx < MEM_SIZE) ? show_idx + 1 : 0;

    if (timer_event)
      saved_time[0] <= saved_time[0] + 1;
  end

  // Timer module instance
  wire timer_event;
  timer
  #(
    .BIT_DEPTH(23)
  )
  timer_inst
  (
    .clk(clk),
    .reset(reset | timer_event),
    .cmp_val(CLOCK_FREQ / 10 - 1),
    .cmp_flag(timer_event)
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
  output wire [6:0]  HEX5,
  output wire [6:0]  HEX4,
  output wire [6:0]  HEX6,
  output wire [6:0]  HEX7
);
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
  parameter SEVSEG_OFF = 7'b1111111;
  assign HEX0 = SEVSEG_OFF;
  assign HEX1 = digits[1];
  assign HEX2 = digits[2];
  assign HEX3 = digits[3];
  assign HEX4 = digits[4];
  assign HEX5 = digits[5]; 
  assign HEX6 = SEVSEG_OFF; 
  assign HEX7 = SEVSEG_OFF;

  // Stopwatch module instantiation
  wire [15:0] current_time;
  wire [15:0] temporary_time;
  stopwatch
  #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BIT_DEPTH(16)
  )
  stopwatch_inst
  (
    .clk(CLOCK_50),
    .reset(key_pressed[0]),
    .start_stop(key_pressed[1]),
    .write(key_pressed[2]),
    .show(key_pressed[3]),
    .current(current_time),
    .temporary(temporary_time)
  );

  // Notation modules instantiation
  notation_flash
  #(
    .BIT_DEPTH(16),
    .NUM_DIGITS(4),
    .BASE(10)
  )
  current_time_notation // Output current time
  (
    .number(current_time),
    .digits({numbers[3], numbers[2], numbers[1], numbers[0]})
  );

  wire temporary_time_div_10;
  division_flash
  #(
    .BIT_DEPTH(16)
  )
  div_temporary_time
  (
    .dividend(temporary_time),
    .divisor(16'd10),
    .quotient(temporary_time_div_10),
  );

  notation_flash
  #(
    .BIT_DEPTH(16),
    .NUM_DIGITS(2),
    .BASE(10)
  )
  temporary_time_notation // Output temprary time
  (
    .number(temporary_time_div_10),
    .digits({numbers[5], numbers[4]})
  );
endmodule
