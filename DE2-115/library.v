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

// Divison module provided by GPT-4. I don't how it wotks
// (c) GPT-4
// Declare the division module with a parameter named BIT_DEPTH, which represents the bit width of the inputs and outputs.
module division #(parameter BIT_DEPTH = 32)(
    input wire clk,                  // Clock signal input
    input wire reset,                // Reset signal input
    input wire start,                // Start signal input
    output reg done,                 // Done signal output
    input wire [BIT_DEPTH-1:0] dividend, // Dividend input
    input wire [BIT_DEPTH-1:0] divisor,  // Divisor input
    output reg [BIT_DEPTH-1:0] quotient, // Quotient output
    output reg [BIT_DEPTH-1:0] remainder // Remainder output
);

// Declare the internal registers needed for the algorithm.
reg [BIT_DEPTH*2-1:0] temp;         // Temporary register to store the dividend and partial remainders.
reg [BIT_DEPTH-1:0] sub_res;        // Register to store the subtraction result.
reg [BIT_DEPTH:0] count;            // Counter to keep track of the division steps.

// The always block is sensitive to the rising edge of the clock and reset signals.
always @(posedge clk or posedge reset) begin
    // When the reset signal is high, initialize all internal registers and outputs to 0.
    if (reset) begin
        quotient <= 0;
        remainder <= 0;
        temp <= 0;
        count <= 0;
        done <= 0;
    end else if (start) begin // When the start signal is high, begin the division process.
        if (count == 0) begin // When the counter is 0, initialize the temp register and the counter.
            temp <= {dividend, dividend[BIT_DEPTH-1]};
            count <= BIT_DEPTH;
        end else begin // In other steps of the division process:
            temp <= temp << 1; // Left-shift the temp register.
            // Subtract the divisor from the upper half of the temp register and store the result in the sub_res register.
            sub_res <= temp[BIT_DEPTH*2-1:BIT_DEPTH] - divisor;

            // If the subtraction result is positive, update the temp register and set the current bit of the quotient to 1.
            if (sub_res[BIT_DEPTH-1] == 0) begin
                temp[BIT_DEPTH*2-1:BIT_DEPTH] <= sub_res;
                quotient <= quotient << 1 | 1'b1;
            end else begin // If the subtraction result is negative, set the current bit of the quotient to 0.
                quotient <= quotient << 1 | 1'b0;
            end
            // Decrement the counter.
            count <= count - 1;
            // When the counter reaches 1, the division process is complete. Set the done signal and update the remainder output.
            if (count == 1) begin
                done <= 1;
                remainder <= temp[BIT_DEPTH*2-1:BIT_DEPTH];
            end
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
(
  input  wire       clk,
  input  wire [3:0] buttons,
  output wire [3:0] sync,
  output wire [3:0] pressed,
  output wire [3:0] unpressed
);
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1)
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
