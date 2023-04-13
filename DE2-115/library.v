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
module division #(parameter DIVIDER = 32)(
    input wire clk,
    input wire reset,
    input wire start,
    output reg done,
    input wire [DIVIDER-1:0] dividend,
    input wire [DIVIDER-1:0] divisor,
    output reg [DIVIDER-1:0] quotient,
    output reg [DIVIDER-1:0] remainder
);

reg [DIVIDER*2-1:0] temp;
reg [DIVIDER-1:0] sub_res;
reg [DIVIDER:0] count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        quotient <= 0;
        remainder <= 0;
        temp <= 0;
        count <= 0;
        done <= 0;
    end else if (start) begin
        if (count == 0) begin
            temp <= {dividend, dividend[DIVIDER-1]};
            count <= DIVIDER;
        end else begin
            temp <= temp << 1;
            sub_res <= temp[DIVIDER*2-1:DIVIDER] - divisor;
            if (sub_res[DIVIDER-1] == 0) begin
                temp[DIVIDER*2-1:DIVIDER] <= sub_res;
                quotient <= quotient << 1 | 1'b1;
            end else begin
                quotient <= quotient << 1 | 1'b0;
            end
            count <= count - 1;
            if (count == 1) begin
                done <= 1;
                remainder <= temp[DIVIDER*2-1:DIVIDER];
            end
        end
    end else begin
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
  reg first, second;
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
        .posedge_sync(unpressed),
        .negedge_sync(pressed)
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
