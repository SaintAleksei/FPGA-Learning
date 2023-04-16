`include "library.v"
`timescale 1ns/1ps

// (c) GPT-4
module tb_division();
  parameter BIT_DEPTH = 32;
  reg clk;
  reg reset;
  reg start;
  wire done;
  reg [BIT_DEPTH-1:0] dividend;
  reg [BIT_DEPTH-1:0] divisor;
  wire [BIT_DEPTH-1:0] quotient;
  wire [BIT_DEPTH-1:0] remainder;

  // Instantiate the division module
  division #(BIT_DEPTH) uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done),
    .dividend_in(dividend),
    .divisor_in(divisor),
    .quotient(quotient),
    .remainder(remainder)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Check result task
  reg [7:0] test_case_number = 0;
  task run_test_case;
    input [BIT_DEPTH-1:0] dividend_in;
    input [BIT_DEPTH-1:0] divisor_in;
    input [BIT_DEPTH-1:0] exp_quotient;
    input [BIT_DEPTH-1:0] exp_remainder;
    begin
      test_case_number = test_case_number + 1;
      $display("Test case #%d", test_case_number);

      dividend = dividend_in;
      divisor  = divisor_in;
      start    = 1;
      @(posedge done);
      #10;
      start    = 0;
      #10;
      if (quotient === exp_quotient && remainder === exp_remainder) begin
        $display("\tTest passed: %d / %d = %d, remainder = %d", dividend, divisor, quotient, remainder);
      end else begin
        $display("\tTest failed: %d / %d", dividend, divisor);
        $display("\t  Expected: quotient = %d, remainder = %d", exp_quotient, exp_remainder);
        $display("\t  Got: quotient = %d, remainder = %d", quotient, remainder);
        $finish;
      end
    end
  endtask

  // Testbench stimulus
  initial begin
    $dumpfile("tb_division.vcd");
    $dumpvars(0, tb_division);
    $display("Running tests for module \"division\"...");
    clk = 0;
    reset = 1;
    start = 0;
    dividend = 0;
    divisor = 0;
    #10 reset = 0;

    // Test case 1: 100 / 4
    run_test_case(100, 4, 25, 0);
    
    // Test case 2: 256 / 16
    run_test_case(256, 16, 16, 0);
    
    // Test case 3: 1234 / 56
    run_test_case(1234, 56, 22, 2);

    // Test case 4: 65535 / 255
    run_test_case(65535, 255, 257, 0);

    // Test case 5: 100 / 0
    run_test_case(100, 0, 0, 0);

    // Finish the simulation
    $display("All tests are passed!");
    #10 $finish;
  end
endmodule

