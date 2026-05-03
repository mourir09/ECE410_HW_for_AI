/*
 * Module: compute_core
 * Description: Synthesizable compute core for HW4AI Milestone 2.
 * Implements a pipelined Multiply-Accumulate (MAC) datapath.
 *
 * Clock Domain:
 * - clk: Single clock domain for all clocked logic. No domain crossings.
 *
 * Reset Behavior:
 * - rst: Synchronous, active-high reset. Clears the accumulator and valid flag.
 *
 * Ports:
 * - clk       : input  : 1-bit  : System clock
 * - rst       : input  : 1-bit  : Synchronous active-high reset
 * - valid_in  : input  : 1-bit  : Control signal indicating inputs are valid
 * - a_in      : input  : 8-bit  : Signed 8-bit data input A
 * - b_in      : input  : 8-bit  : Signed 8-bit data input B (or weight)
 * - valid_out : output : 1-bit  : Control signal indicating output data is valid
 * - result    : output : 32-bit : Signed 32-bit accumulated output
 */

module compute_core (
    input  logic               clk,
    input  logic               rst,
    input  logic               valid_in,
    input  logic signed  [7:0] a_in,
    input  logic signed  [7:0] b_in,
    output logic               valid_out,
    output logic signed [31:0] result
);

    // Internal registers
    logic signed [31:0] accumulator;
    logic               out_flag;

    always_ff @(posedge clk) begin
        if (rst) begin
            accumulator <= 32'sd0;
            out_flag    <= 1'b0;
        end else if (valid_in) begin
            // Explicit 32-bit cast to prevent width mismatch warnings
            accumulator <= accumulator + 32'(a_in * b_in);
            out_flag    <= 1'b1;
        end else begin
            out_flag    <= 1'b0;
        end
    end

    // Continuous assignment to outputs
    assign result = accumulator;
    assign valid_out = out_flag;

endmodule
