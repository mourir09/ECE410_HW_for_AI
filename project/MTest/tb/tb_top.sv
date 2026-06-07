`timescale 1ns/1ps

/*
 * Module: tb_top
 * Description: End-to-end co-simulation testbench for Milestone 3.
 * Verifies the integrated top module by acting as a host CPU,
 * driving the AXI4-Stream inputs and verifying the outputs.
 */

module tb_top;

    // Clock and Reset
    logic clk;
    logic rst;

    // AXI4-Stream Subordinate (Inbound to Top)
    logic        s_axis_tvalid;
    logic        s_axis_tready;
    logic [15:0] s_axis_tdata;

    // AXI4-Stream Manager (Outbound from Top)
    logic        m_axis_tvalid;
    logic        m_axis_tready;
    logic [31:0] m_axis_tdata;

    int error_count;

    // Instantiate the Integrated Top Module (DUT)
    top dut (
        .clk(clk),
        .rst(rst),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize VCD dumping for M3 waveform visualization
        $dumpfile("project/m3/sim/cosim.vcd");
        $dumpvars(0, tb_top);

        // Initialize signals
        rst = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        m_axis_tready = 0;
        error_count = 0;

        // Release reset
        @(negedge clk);
        @(negedge clk);
        rst = 0;

        // ---------------------------------------------------------
        // Test 1: Standard AXI-Stream Write & Read
        // Send a = 5, b = 3. Expected Result = 15.
        // ---------------------------------------------------------
        @(negedge clk);
        s_axis_tvalid = 1;
        s_axis_tdata  = {8'd3, 8'd5}; // {b_in, a_in}
        m_axis_tready = 1;            // Downstream is ready

        // Wait for interface to accept data
        wait(s_axis_tready == 1'b1);
        @(negedge clk);
        s_axis_tvalid = 0; // De-assert after acceptance

        // Wait for result to pop out
        wait(m_axis_tvalid == 1'b1);
        
        if (m_axis_tdata !== 32'd15) begin
            $display("ERROR (Test 1): Expected 15, Got %0d", m_axis_tdata);
            error_count++;
        end

        // Wait for the next clock edges so the interface registers 
        // that the handshake is complete and clears out the 15
        @(posedge clk);
        @(negedge clk);

        // ---------------------------------------------------------
        // Test 2: Backpressure (m_axis_tready is LOW)
        // Send a = -2, b = 4. Expected Accumulation = 15 + (-8) = 7
        // ---------------------------------------------------------
        s_axis_tvalid = 1;
        s_axis_tdata  = {8'd4, -8'sd2}; 
        m_axis_tready = 0; // Downstream is NOT ready yet

        wait(s_axis_tready == 1'b1);
        @(negedge clk);
        s_axis_tvalid = 0;

        // Wait for the new valid flag to pop up
        wait(m_axis_tvalid == 1'b1);
        
        // Wait two cycles to prove it holds the data while backpressured
        @(posedge clk);
        @(posedge clk);
        
        if (m_axis_tvalid !== 1'b1) begin
            $display("ERROR (Test 2): Interface dropped valid flag during backpressure.");
            error_count++;
        end

        // Now assert ready to consume the data
        @(negedge clk);
        m_axis_tready = 1;

        @(posedge clk);
        #1;
        if (m_axis_tdata !== 32'd7) begin
            $display("ERROR (Test 2): Expected 7, Got %0d", m_axis_tdata);
            error_count++;
        end

        // ---------------------------------------------------------
        // End of Simulation
        // ---------------------------------------------------------
        @(negedge clk);
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
