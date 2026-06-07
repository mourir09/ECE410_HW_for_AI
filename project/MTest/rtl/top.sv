`timescale 1ns / 1ps

// `include "interface.sv"
// `include "compute_core.sv"

/* =========================================================================
 * Module: top
 * Description: Integrated top-level module connecting the AXI4-Stream interface
 * to the 2D convolution compute core.
 *
 * External Port List:
 * clk           - Input  - 1-bit  - Main system clock
 * rst           - Input  - 1-bit  - Active-high synchronous reset
 * s_axis_tvalid - Input  - 1-bit  - Subordinate AXI stream valid signal (host to core)
 * s_axis_tready - Output - 1-bit  - Subordinate AXI stream ready signal (core to host)
 * s_axis_tdata  - Input  - 16-bit - Subordinate AXI stream data (packed A and B operands)
 * m_axis_tvalid - Output - 1-bit  - Manager AXI stream valid signal (core to host)
 * m_axis_tready - Input  - 1-bit  - Manager AXI stream ready signal (host to core)
 * m_axis_tdata  - Output - 32-bit - Manager AXI stream data (convolution result)
 * ========================================================================= */

module top (
    input  logic               clk,
    input  logic               rst,

    // AXI4-Stream Subordinate (Inbound)
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic [15:0]        s_axis_tdata,

    // AXI4-Stream Manager (Outbound)
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic [31:0]        m_axis_tdata
);

    // =========================================================================
    // Glue Logic / Internal Connections
    // Explanation: The 'axi_interface' module internally handles the width conversion 
    // (splitting the 16-bit tdata into two 8-bit operands) and handshake adaptation. 
    // Therefore, the top-level glue logic consists purely of direct wire connections 
    // routing the synchronized valid/data signals directly into the compute core, 
    // and routing the 32-bit result back. No external FIFOs were required.
    // =========================================================================
    logic               core_valid_in;
    logic signed [7:0]  core_a_in;
    logic signed [7:0]  core_b_in;
    logic               core_valid_out;
    logic signed [31:0] core_result;

    // Instantiate the AXI Interface
    axi_interface intf_inst (
        .clk(clk),
        .rst(rst),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .core_valid_in(core_valid_in),
        .core_a_in(core_a_in),
        .core_b_in(core_b_in),
        .core_valid_out(core_valid_out),
        .core_result(core_result)
    );

    // Instantiate the Compute Core
    compute_core core_inst (
        .clk(clk),
        .rst(rst),
        .valid_in(core_valid_in),
        .a_in(core_a_in),
        .b_in(core_b_in),
        .valid_out(core_valid_out),
        .result(core_result)
    );

endmodule