/*
 * Module: axi_interface
 * Description: Synthesizable AXI4-Stream interface for HW4AI Milestone 2.
 * Receives packed 8-bit inputs (A and B) and transmits 32-bit results.
 *
 * Protocol: AXI4-Stream
 * - Honors TVALID/TREADY contract on both Subordinate (receive) and Manager (transmit) interfaces.
 *
 * Transaction Format:
 * - s_axis_tdata [15:0] : Lower 8 bits = a_in, Upper 8 bits = b_in
 * - m_axis_tdata [31:0] : 32-bit accumulated result
 *
 * Clock Domain:
 * - clk: Single clock domain for all clocked logic.
 *
 * Reset Behavior:
 * - rst: Synchronous, active-high reset. Clears all valid signals and state.
 *
 * Ports:
 * - clk            : input  : 1-bit  : System clock
 * - rst            : input  : 1-bit  : Synchronous active-high reset
 * * -- AXI4-Stream Subordinate Interface (Receiving Data) --
 * - s_axis_tvalid  : input  : 1-bit  : Manager indicates data is valid
 * - s_axis_tready  : output : 1-bit  : Subordinate is ready to accept data
 * - s_axis_tdata   : input  : 16-bit : Packed input data {b_in[7:0], a_in[7:0]}
 *
 * -- AXI4-Stream Manager Interface (Transmitting Data) --
 * - m_axis_tvalid  : output : 1-bit  : Manager indicates result is valid
 * - m_axis_tready  : input  : 1-bit  : Subordinate is ready to accept result
 * - m_axis_tdata   : output : 32-bit : Output result data
 *
 * -- Internal Compute Core Interface --
 * - core_valid_in  : output : 1-bit  : Drive compute core valid
 * - core_a_in      : output : 8-bit  : Unpacked A input
 * - core_b_in      : output : 8-bit  : Unpacked B input
 * - core_valid_out : input  : 1-bit  : Compute core valid flag
 * - core_result    : input  : 32-bit : Compute core result
 */

module axi_interface (
    input  logic               clk,
    input  logic               rst,

    // AXI4-Stream Subordinate (Inbound)
    input  logic               s_axis_tvalid,
    output logic               s_axis_tready,
    input  logic [15:0]        s_axis_tdata,

    // AXI4-Stream Manager (Outbound)
    output logic               m_axis_tvalid,
    input  logic               m_axis_tready,
    output logic [31:0]        m_axis_tdata,

    // Signals mapped to compute_core.sv
    output logic               core_valid_in,
    output logic signed [7:0]  core_a_in,
    output logic signed [7:0]  core_b_in,
    input  logic               core_valid_out,
    input  logic signed [31:0] core_result
);

    // The interface is ready to accept new data when the downstream sink is ready,
    // or if no valid output is currently pending.
    assign s_axis_tready = m_axis_tready || !m_axis_tvalid;

    // Unpack AXI-Stream data into the compute core format
    assign core_a_in     = s_axis_tdata[7:0];
    assign core_b_in     = s_axis_tdata[15:8];
    
    // Only trigger the core if we have valid input AND we are ready to accept it
    assign core_valid_in = s_axis_tvalid && s_axis_tready;

    // Buffer to hold output valid state to satisfy AXI-Stream handshake
    always_ff @(posedge clk) begin
        if (rst) begin
            m_axis_tvalid <= 1'b0;
            m_axis_tdata  <= 32'd0;
        end else begin
            // Capture core output when valid
            if (core_valid_out) begin
                m_axis_tvalid <= 1'b1;
                m_axis_tdata  <= core_result;
            end 
            // Clear valid flag once the downstream subordinate accepts the data
            else if (m_axis_tready && m_axis_tvalid) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end

endmodule
