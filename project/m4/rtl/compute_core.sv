`timescale 1ns / 1ps

module compute_core (
    input  logic               clk,
    input  logic               rst,
    input  logic               valid_in,
    input  logic signed  [7:0] a_in,
    input  logic signed  [7:0] b_in,
    output logic               valid_out,
    output logic signed [31:0] result
);

    // =========================================================================
    // PIPELINE STAGE 1: Input Registration
    // Prevents Yosys from absorbing the AXI inputs into the multiplier
    // =========================================================================
    (* dont_touch = "true" *) logic               valid_s1;
    (* dont_touch = "true" *) logic signed  [7:0] a_s1;
    (* dont_touch = "true" *) logic signed  [7:0] b_s1;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_s1 <= 1'b0;
            a_s1     <= 8'd0;
            b_s1     <= 8'd0;
        end else begin
            valid_s1 <= valid_in;
            if (valid_in) begin
                a_s1 <= a_in;
                b_s1 <= b_in;
            end
        end
    end

    // =========================================================================
    // PIPELINE STAGE 2: Multiplication Registration
    // Breaks the path between the multiplier and the 32-bit adder
    // =========================================================================
    (* dont_touch = "true" *) logic               valid_s2;
    (* dont_touch = "true" *) logic signed [15:0] mult_s2;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_s2 <= 1'b0;
            mult_s2  <= 16'd0;
        end else begin
            valid_s2 <= valid_s1;
            if (valid_s1) begin
                mult_s2 <= a_s1 * b_s1;
            end
        end
    end

    // =========================================================================
    // PIPELINE STAGE 3: Accumulation
    // Final registered output
    // =========================================================================
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            result    <= 32'd0;
        end else begin
            valid_out <= valid_s2;
            if (valid_s2) begin
                result <= result + mult_s2;
            end
        end
    end

endmodule
