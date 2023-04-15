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
    task check_result;
        input [BIT_DEPTH-1:0] exp_quotient;
        input [BIT_DEPTH-1:0] exp_remainder;
        begin
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
        $dumpfile("testbench.vcd");
        $dumpvars(0, tb_division);
        $display("Running tests for module \"division\"...");
        clk = 0;
        reset = 1;
        start = 0;
        dividend = 0;
        divisor = 0;
        #10 reset = 0;

        // Test case 1: 100 / 4
        start = 1;
        dividend = 100;
        divisor = 4;
        @(posedge done);
        #10 check_result(25, 0);
        start = 0;
        
        // Test case 2: 256 / 16
        #10 start = 1;
        dividend = 256;
        divisor = 16;
        @(posedge done);
        #10 check_result(16, 0);
        start = 0;
        
        // Test case 3: 1234 / 56
        #10 start = 1;
        dividend = 1234;
        divisor = 56;
        @(posedge done);
        #10 check_result(22, 2);
        start = 0;

        // Test case 4: 65535 / 255
        #10 start = 1;
        dividend = 65535;
        divisor = 255;
        @(posedge done);
        #10 check_result(257, 0);
        start = 0;

        // Test case 5: 100 / 0
        #10 start = 1;
        dividend = 100;
        divisor = 0;
        @(posedge done);
        // In this case, the result check will depend on the behavior of your division module when dividing by zero.
        // Assuming that the quotient and remainder will be undefined zeros, use the following check:
        #10 check_result({BIT_DEPTH{1'b0}}, {BIT_DEPTH{1'b0}});
        start = 0;

        // Finish the simulation
        $display("All tests are passed!");
        #10 $finish;
    end
endmodule
