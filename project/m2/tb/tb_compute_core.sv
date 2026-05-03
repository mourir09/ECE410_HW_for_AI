`timescale 1ns/1ps

/*
 * Module: tb_compute_core
 * Description: Testbench for the MAC compute core.
 * Verifies accumulation over several cycles and asserts PASS/FAIL.
 */

module tb_compute_core;

    // Signals
    logic               clk;
    logic               rst;
    logic               valid_in;
    logic signed  [7:0] a_in;
    logic signed  [7:0] b_in;
    logic               valid_out;
    logic signed [31:0] result;

    // Expected reference variable
    logic signed [31:0] expected_acc;
    int                 error_count;

    // Instantiate the Device Under Test (DUT)
    compute_core dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .a_in(a_in),
        .b_in(b_in),
        .valid_out(valid_out),
        .result(result)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize VCD dumping for waveform visualization
        $dumpfile("project/m2/sim/compute_core.vcd");
        $dumpvars(0, tb_compute_core);

        // Initialize inputs
        rst = 1;
        valid_in = 0;
        a_in = 0;
        b_in = 0;
        expected_acc = 0;
        error_count = 0;

        // Hold reset for a couple of cycles
        @(negedge clk);
        @(negedge clk);
        rst = 0;

        // --- Test Vector 1 ---
        @(negedge clk);
        valid_in = 1;
        a_in = 8'd5;
        b_in = 8'd2;
        expected_acc = expected_acc + (5 * 2); // 10

        // --- Test Vector 2 (Negative Numbers) ---
        @(negedge clk);
        a_in = -8'sd3;
        b_in = 8'd4;
        expected_acc = expected_acc + (-3 * 4); // 10 - 12 = -2

        // --- Test Vector 3 ---
        @(negedge clk);
        a_in = 8'd10;
        b_in = 8'd10;
        expected_acc = expected_acc + (10 * 10); // -2 + 100 = 98

        // Stop driving inputs
        @(negedge clk);
        valid_in = 0;
        a_in = 0;
        b_in = 0;

        // Wait one cycle for the final valid_out to register
        @(posedge clk);
        #1; // Slight delay to ensure signals have updated

        // Check the final result
        if (result !== expected_acc) begin
            $display("ERROR: Final accumulation mismatch. Expected %0d, Got %0d", expected_acc, result);
            error_count++;
        end

        // Print final grading status
        $display("---------------------------------");
        if (error_count == 0) begin
            $display("SIMULATION RESULT: PASS");
        end else begin
            $display("SIMULATION RESULT: FAIL (%0d errors)", error_count);
        end
        $display("---------------------------------");

        $finish;
    end

endmodule
