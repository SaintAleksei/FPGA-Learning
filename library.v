module timer
#(
  parameter BIT_DEPTH = 32,
)
(
  input  wire clk,
  input  wire reset,
  input  wire [BIT_DEPTH-1:0] cmp_val,
  output reg  [BIT_DEPTH-1:0] cnt_val,
  output wire cmp_flag
)
  assign cmp_flag = cnt_val >= cmp_val;
  always @(posedge clk)
    if (reset)
      cnt_val <= 0;
    else
      cnt_val = cnt_val + 1;
endmodule

// Convert 4-bit number to hexadecimal representation for 7-segment dispay
// TODO: In fact, it is Lookup Table, maybe it can be separate parameterizable module
module sevseg
(
  input  wire [3:0] number,
  output wire [6:0] digit
);
// FIXME: Maybe here can be used wires. What is more effective?
  wire [6:0] lut [0:15];
// Values gathered from DE2-115 user manual, p. 37
/*
    0
  5   1
    6
  4   2
    3
*/
// FIXME: How much time is needed for this initialization?
//                  6543210
  assign lut[0]  = 7'b0111111;
  assign lut[1]  = 7'b0000110;
  assign lut[2]  = 7'b1011011;
  assign lut[3]  = 7'b1001111;
  assign lut[4]  = 7'b1100110;
  assign lut[5]  = 7'b1101101;
  assign lut[6]  = 7'b1111101;
  assign lut[7]  = 7'b0000111;
  assign lut[8]  = 7'b1111111;
  assign lut[9]  = 7'b1101111;
  assign lut[10] = 7'b1110111;
  assign lut[11] = 7'b1111100;
  assign lut[12] = 7'b0111001;
  assign lut[13] = 7'b1011110;
  assign lut[14] = 7'b1111001;
  assign lut[15] = 7'b1110001;
  assign digit   = ~lut[number];
endmodule

module notation_self_reset
#(
  parameter BIT_DEPTH = 8,
  parameter NUM_DIGITS = 3,
  parameter BASE = 10
)
(
  input  wire clk,                  
  input  wire reset,                
  input  wire [BIT_DEPTH-1:0] number, 
  output wire [(NUM_DIGITS * BIT_DEPTH)-1:0] digits
);
  wire conversion_done;
  notation
  #(
    .BIT_DEPTH(BIT_DEPTH),
    .NUM_DIGITS(NUM_DIGITS),
    .BASE(BASE)
  )
  notation_inst
  (
    .clk(clk),
    .reset(reset | conversion_done),
    .number(number),
    .digits(digits),
    .conversion_done(conversion_done)
  );
endmodule

// --------------------------------------------------------------------------------
// Module: notation
// Author: GPT-4
// Description:
//  The notation module converts an input number into an array of digits in the
// specified base. It uses a state machine to control the conversion process,
// employing a division module to obtain each digit. The result is presented as
// a single wire, where each digit occupies BIT_DEPTH bits.
//
// Algorithm Summary:
// 1. Initialize the state machine and set the current number to the input number.
// 2. Start the division process with the current number as the dividend and the 
// base as the divisor.
// 3. Wait for the division process to complete and store the remainder as a digit.
// 4. Update the current number with the quotient and repeat the division process.
// 5. Continue until all digits are processed, then set the conversion_done signal 
// to indicate completion.
// --------------------------------------------------------------------------------
module notation
#(
  parameter BIT_DEPTH = 8,          // Bit depth of the input number and output digits
  parameter NUM_DIGITS = 3,         // Number of digits in the output
  parameter BASE = 10               // Base of the output digits
)
(
  input  wire clk,                  // Clock signal input
  input  wire reset,                // Reset signal input
  input  wire [BIT_DEPTH-1:0] number, // Input number to be converted
  output wire [(NUM_DIGITS * BIT_DEPTH)-1:0] digits, // Output digits as a single wire
  output reg conversion_done        // Signal to indicate completion of the conversion
);
  // Internal registers and wires
  reg [BIT_DEPTH-1:0] current_number; // Stores the current number being processed
  wire [BIT_DEPTH-1:0] quotient;      // Quotient from the division module
  wire [BIT_DEPTH-1:0] remainder;     // Remainder from the division module
  reg [31:0] idx;                     // Index to keep track of the digit being processed
  reg [1:0] state;                    // State of the state machine
  reg start;                          // Start signal for the division module
  wire done;                          // Done signal from the division module

  // Internal array of registers for digits
  reg [BIT_DEPTH-1:0] internal_digits [NUM_DIGITS-1:0];

  // State machine states
  localparam INIT = 2'b00;
  localparam START_DIVISION = 2'b01;
  localparam WAIT = 2'b10;
  localparam DONE = 2'b11;

  // Instantiate the division module
  division #(.BIT_DEPTH(BIT_DEPTH)) div_inst (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done),
    .dividend_in(current_number),
    .divisor_in(BASE[BIT_DEPTH-1:0]),
    .quotient(quotient),
    .remainder(remainder)
  );

  // State machine logic
  always @(posedge clk) begin
    if (reset) begin
      current_number <= 0;
      idx <= 0;
      state <= INIT;
      start <= 0;
      conversion_done <= 0;
    end else begin
      case (state)
        INIT: begin
          current_number <= number;
          idx <= 0;
          state <= START_DIVISION;
          conversion_done <= 0;
        end
        START_DIVISION: begin
          start <= 1;
          if (done) begin
            internal_digits[idx] <= remainder;
            idx <= idx + 1;
            if (idx < NUM_DIGITS) begin
              current_number <= quotient;
              state <= START_DIVISION;
            end else begin
              state <= DONE;
            end
          end else begin
            state <= WAIT;
          end
        end
        WAIT: begin
          if (done) begin
            start <= 0;
            state <= START_DIVISION;
          end
        end
        DONE: begin
          // Indicate conversion completion
          start <= 0;
          conversion_done <= 1;
        end
      endcase
    end
  end

  // Wire the output 'digits' to the internal_digits array
  genvar i;
  generate
    for (i = 0; i < NUM_DIGITS; i = i + 1)
    begin: digits_wires_loop
      assign digits[i * BIT_DEPTH +: BIT_DEPTH] = internal_digits[i];
    end
  endgenerate
endmodule

/*
 *  Divison module provided by GPT-4 with my fixes. It seems that GPT-4 doens't
 * understand concept of '<=' operation, because C version of this algorithm he
 * provided is correct. You can find it in file division.c. Provided algorithm
 * is called "non-restoring division": it uses BIT_DEPTH pulses to perfom
 * division of BIT_DEPTH-bit unsigned numbers
*/

// Declare the division module with a parameter named BIT_DEPTH, which represents the bit width of the inputs and outputs.
module division #(parameter BIT_DEPTH = 32)(
  input wire clk,          // Clock signal input
  input wire reset,        // Reset signal input
  input wire start,        // Start signal input, indicate start of division, should be high during divison process
  output reg done,         // Done signal output, high when division process is completed. Can be reset by reseting start
  input wire  [BIT_DEPTH-1:0] dividend_in, // Dividend input
  input wire  [BIT_DEPTH-1:0] divisor_in,  // Divisor input
  output reg  [BIT_DEPTH-1:0] quotient,  // Quotient output
  output wire [BIT_DEPTH-1:0] remainder  // Remainder output
);
  // Declare the internal registers needed for the algorithm.
  reg [BIT_DEPTH*2-1:0] temp;   // Temporary register to store the dividend and partial remainders.
  reg [BIT_DEPTH-1:0]   count;  // Counter to keep track of the division steps.
  reg [BIT_DEPTH-1:0]   divisor;  // Stored divisor, needed to get rid of troubles when divisor_in is changed during algorithm

  assign remainder = temp[BIT_DEPTH*2-1:BIT_DEPTH]; 

  // Some helpfull wires to make always block more clear
  wire [BIT_DEPTH*2-1:0] temp_shifted      = temp << 1;
  wire [BIT_DEPTH-1:0]   remainder_shifted   = temp_shifted[BIT_DEPTH*2-1:BIT_DEPTH];
  wire [BIT_DEPTH-1:0]   remainder_new_step  = (remainder_shifted[BIT_DEPTH-1]) ? remainder_shifted + divisor :
                                          remainder_shifted - divisor;
  wire [BIT_DEPTH-1:0]   remainder_last_step = (remainder_new_step[BIT_DEPTH-1]) ? remainder_new_step + divisor :
                                           remainder_new_step;
  wire [BIT_DEPTH*2-1:0] temp_init   = {{BIT_DEPTH{1'b0}}, dividend_in};
  wire [BIT_DEPTH*2-1:0] temp_new    = {remainder_new_step,  temp_shifted[BIT_DEPTH-1:0]};
  wire [BIT_DEPTH*2-1:0] temp_last   = {remainder_last_step, temp_shifted[BIT_DEPTH-1:0]};
  wire [BIT_DEPTH-1:0]   quotient_new  = {quotient[BIT_DEPTH-2:0], ~remainder_new_step[BIT_DEPTH-1]};

  // The always block is sensitive to the rising edge of the clock and reset signals.
  always @(posedge clk) begin
    // When the reset signal is high, initialize all internal registers and outputs to 0.
    if (reset) begin
      quotient <= 0;
      temp <= 0;
      count <= 0;
      done <= 0;
      divisor <= 0;
    end else if (start) begin // When the start signal is high, begin the division process.
      if (count == 0 && !done) begin // When the counter is 0, initialize registers with started values
        temp <= temp_init;
        if (divisor_in == 0) begin
          quotient <= 0;
          done   <= 1;
        end else begin
          count  <= BIT_DEPTH;
          divisor  <= divisor_in;
        end
      end else if (!done) begin // In other steps of the division process:
        if (count == 1) begin
          // Last iteration
          done <= 1;
          temp <= temp_last;
        end else
          // Not last iteration
          temp <= temp_new;

        // Update quotient
        quotient <= quotient_new;
        // Decrement the counter.
        count <= count - 1;
      end
    end else begin // If the start signal is low, set the done signal to 0.
      done <= 0;
    end
  end
endmodule

// simple sync button, legacy. 
module button
(
  input  wire clk,
  input  wire button_async,
  output wire button_sync
);
  reg first, second;
  always @(posedge clk) 
  begin
    first <= button_async;
    second <= first;
  end
  assign button_sync = ~second & first;
endmodule

// Convert asynchronous edge to single cycle pulse
module sync
(
  input  wire clk,
  input  wire async,
  output reg  sync,
  output wire posedge_sync, 
  output wire negedge_sync
);
  reg late_sync;
  always @(posedge clk)
  begin
    sync <= async;
    late_sync <= sync;
  end
  assign posedge_sync = sync & ~late_sync;
  assign negedge_sync = ~sync & late_sync;
endmodule

module de2_115_buttons
#(
  parameter BUTTONS_AMOUNT = 4
)
(
  input  wire       clk,
  input  wire [BUTTONS_AMOUNT-1:0] buttons,
  output wire [BUTTONS_AMOUNT-1:0] sync,
  output wire [BUTTONS_AMOUNT-1:0] pressed,
  output wire [BUTTONS_AMOUNT-1:0] unpressed
);
  genvar i;
  generate
    for (i = 0; i < BUTTONS_AMOUNT; i = i + 1)
    begin: de2_115_buttons_loop
      sync
      sync_button
      (
        .clk(clk),
        .async(buttons[i]),
        .sync(sync[i]),
        .posedge_sync(unpressed[i]),
        .negedge_sync(pressed[i])
      );
    end
  endgenerate
endmodule

// Simple counter
module counter
#(
  parameter BIT_DEPTH = 8
)
(
  input  wire       clk,
  input  wire       inc,
  input  wire       dec,
  input  wire       reset,
  output reg  [BIT_DEPTH-1:0] value
);
  always @(posedge clk)
    if (reset)
      value <= 0;
    else if (inc)
      value <= value + 1;
    else if (dec)
      value <= value - 1;
endmodule

// Shift register
module shiftreg
#(
  parameter BIT_DEPTH = 8
)
(
  input  clk,
  input  reset,
  input  left_shift_bit,
  input  left_shift_event,
  input  right_shift_bit,
  input  right_shift_event,
  output reg [BIT_DEPTH-1:0] register 
);
  always @(posedge clk)
    if (reset)
      register <= 0;
    else if (left_shift_event)
      register <= {register[BIT_DEPTH-2:0], left_shift_bit};
    else if (right_shift_event)
      register <= {right_shift_bit, register[BIT_DEPTH-1:1]};
endmodule