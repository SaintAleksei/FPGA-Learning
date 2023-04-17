/*
 * Template file that can be used in many projects
 */

`include "../library.v"

module stopwatch
#(
  // TODO
)
(
  // TODO
);
  genvar i;

  // Registers required by device logic
  reg [13:0] saved_time [MEM_SIZE:0];
  reg [13:0] temporary_result;
  reg [7:0] saved_time_idx;
  reg start;

  generate
    for (i = 0; i < MAIN_DIGITS; i = i + 1)
      assign main_result[i]
  endgenerate

  // Device logic
  always @(posedge clk)
  begin
    if (key_sync[0]) // Reset
    begin
      generate
        for (i = 0; i <= MEM_SIZE; i++)
        begin: saved_time_reset_loop
          saved_time[i] <= 14'd0;
        end
      endgenerate
      saved_time_idx <= 0;
      start <= 0;
    end
    else if (key_sync[1]) // Start / Stop
    begin
      start <= ~start;
      saved_time_idx <= {8{~start}} & saved_time_idx;
    end
    else if (key_sync[2]) // Write
    begin
      if (start)
      begin
        if (saved_time_idx < MEM_SIZE)
        begin
          saved_time[saved_time_idx + 1] <= saved_time[0];
          saved_time_idx <= saved_time_idx + 1;
        end 

        temporary_result <= saved_time[0];
      end
      else if (!start)
      begin
        generate
          for (i = 0; i < MEM_SIZE; i++)
          begin: saved_time_write_loop
            saved_time[i+1] = 14'd0;
          end
        endgenerate
      end
    end
    else if (key_sync[3] && !start) // Show
      saved_time_idx <= saved_time_idx + 1;

    if (timer_event && start)
      saved_time[0] = saved_time[0] + 1;
  end
      
  // Submodules instantiation
  notation_self_reset
  current_time_notation
  #(
    .BIT_DEPTH(14),
    .NUM_DIGITS(4),
    .BASE(10)
  (
    .clk(CLOCK_50),
    .reset(key_sync[0]),
    .number(saved_time[saved_time_idx]),
    .digits({numbers[3], numbers[2], numbers[1], numbers[0]}),
  );

  notation_self_reset
  temporary_result_notation
  #(
    .BIT_DEPTH(14),
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
  
)

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

  // Registers required by device logic
  reg [13:0] saved_time [MEM_SIZE:0];
  reg [13:0] temporary_result;
  reg [7:0] saved_time_idx;
  reg start;

  genvar i;

  // Device logic
  always @(posedge clk)
  begin
    if (key_sync[0]) // Reset
    begin
      generate
        for (i = 0; i <= MEM_SIZE; i++)
        begin: saved_time_reset_loop
          saved_time[i] <= 14'd0;
        end
      endgenerate
      saved_time_idx <= 0;
      start <= 0;
    end
    else if (key_sync[1]) // Start / Stop
    begin
      start <= ~start;
      saved_time_idx <= {8{~start}} & saved_time_idx;
    end
    else if (key_sync[2]) // Write
    begin
      if (start)
      begin
        if (saved_time_idx < MEM_SIZE)
        begin
          saved_time[saved_time_idx + 1] <= saved_time[0];
          saved_time_idx <= saved_time_idx + 1;
        end 

        temporary_result <= saved_time[0];
      end
      else if (!start)
      begin
        generate
          for (i = 0; i < MEM_SIZE; i++)
          begin: saved_time_write_loop
            saved_time[i+1] = 14'd0;
          end
        endgenerate
      end
    end
    else if (key_sync[3] && !start) // Show
      saved_time_idx <= saved_time_idx + 1;

    if (timer_event && start)
      saved_time[0] = saved_time[0] + 1;
  end
      
  // Submodules instantiation
  notation_self_reset
  current_time_notation
  #(
    .BIT_DEPTH(14),
    .NUM_DIGITS(4),
    .BASE(10)
  (
    .clk(CLOCK_50),
    .reset(key_sync[0]),
    .number(saved_time[saved_time_idx]),
    .digits({numbers[3], numbers[2], numbers[1], numbers[0]}),
  );

  notation_self_reset
  temporary_result_notation
  #(
    .BIT_DEPTH(14),
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
