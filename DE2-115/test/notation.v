`include "library.v"
`timescale 1ns / 1ps

module tb_notation();
  // Parameters for different instances
  localparam BIT_DEPTH1 = 8;
  localparam NUM_DIGITS1 = 3;
  localparam BASE1 = 10;

  localparam BIT_DEPTH2 = 4;
  localparam NUM_DIGITS2 = 4;
  localparam BASE2 = 2;

  // Test signals
  reg clk;
  reg reset;
  reg [BIT_DEPTH1-1:0] number1;
  wire [(NUM_DIGITS1 * BIT_DEPTH1)-1:0] digits1;
  wire conversion_done1;

  reg [BIT_DEPTH2-1:0] number2;
  wire [(NUM_DIGITS2 * BIT_DEPTH2)-1:0] digits2;
  wire conversion_done2;

  // Instantiate the notation modules
  notation #(.BIT_DEPTH(BIT_DEPTH1), .NUM_DIGITS(NUM_DIGITS1), .BASE(BASE1)) notation1 (
    .clk(clk),
    .reset(reset),
    .number(number1),
    .digits(digits1),
    .conversion_done(conversion_done1)
  );

  notation #(.BIT_DEPTH(BIT_DEPTH2), .NUM_DIGITS(NUM_DIGITS2), .BASE(BASE2)) notation2 (
    .clk(clk),
    .reset(reset),
    .number(number2),
    .digits(digits2),
    .conversion_done(conversion_done2)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Test case execution task
  integer test_case_number = 0;
  task run_test_case;
    input [BIT_DEPTH1-1:0] in_num1;
    input [(NUM_DIGITS1 * BIT_DEPTH1)-1:0] exp_out1;
    input [BIT_DEPTH2-1:0] in_num2;
    input [(NUM_DIGITS2 * BIT_DEPTH2)-1:0] exp_out2;

    begin
      test_case_number = test_case_number + 1;
      $display("Test case %0d", test_case_number);
      
      // Set input numbers
      number1 = in_num1;
      number2 = in_num2;
      
      // Start conversion
      reset = 1;
      #10;
      reset = 0;

      // Wait for conversion to complete
      while (!conversion_done1 || !conversion_done2) begin
        #10;
      end

      // Check results and display test case status
      if (digits1 == exp_out1 && conversion_done1) begin
        $display("\tInstance 1: PASSED | Input: %0d | Expected Output: %0h | Actual Output: %0h", in_num1, exp_out1, digits1);
      end else begin
        $display("\tInstance 1: FAILED | Input: %0d | Expected Output: %0h | Actual Output: %0h", in_num1, exp_out1, digits1);
      end

      if (digits2 == exp_out2 && conversion_done2) begin
        $display("\tInstance 2: PASSED | Input: %0b | Expected Output: %0b | Actual Output: %0b", in_num2, exp_out2, digits2);
      end else begin
        $display("\tInstance 2: FAILED | Input: %0b | Expected Output: %0b | Actual Output: %0b", in_num2, exp_out2, digits2);
      end
    end
  endtask

  // Test cases
  initial begin
    $dumpfile("tb_notation.vcd");
    $dumpvars(0, tb_notation);
    $display("Running tests for notation module");
    // Initialize signals
    clk = 0;
    number1 = 0;
    number2 = 0;

    // Test case 1
    run_test_case(8'd123, {8'd1, 8'd2, 8'd3}, 4'b1010, {4'b1, 4'b0, 4'b1, 4'b0});

    // Test case 2
    run_test_case(8'd250, {8'd2, 8'd5, 8'd0}, 4'b0110, {4'b0, 4'b1, 4'b1, 4'b0});

    // Add more test cases below by calling run_test_case() with appropriate arguments
    // ...

    // Finish the simulation
    $finish;
  end
endmodule

