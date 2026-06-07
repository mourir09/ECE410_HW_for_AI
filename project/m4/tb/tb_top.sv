`timescale 1ns/1ps

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

    int output_count;

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

    // Input Driver Thread (Pumps 100 pixels in)
    initial begin
        $dumpfile("mtest_cosim.vcd");
        $dumpvars(0, tb_top);

        // Initialize signals
        rst = 1;
        s_axis_tvalid = 0;
        s_axis_tdata = 0;
        m_axis_tready = 0;
        output_count = 0;

        // Release reset
        @(negedge clk);
        @(negedge clk);
        rst = 0;
        m_axis_tready = 1; // Downstream is always ready to receive

        // Pump in 100 sequential pixels (simulating ~3.5 rows of an image)
        for (int i = 0; i < 100; i++) begin
            @(negedge clk);
            s_axis_tvalid = 1;
            // Pad the top 8 bits with 0, put the pixel data in the bottom 8 bits
            s_axis_tdata = {8'd0, i[7:0]}; 
            
            // Wait for handshake
            wait(s_axis_tready == 1'b1);
        end

        // Stop sending data
        @(negedge clk);
        s_axis_tvalid = 0;

        // Wait a few more clock cycles for the final pixels to drain out of the pipeline
        #500;
        
        $display("---------------------------------");
        $display("SIMULATION COMPLETE");
        $display("Total valid outputs generated: %0d", output_count);
        $display("---------------------------------");
        $finish;
    end

    // Output Monitor Thread (Watches for results)
    always @(posedge clk) begin
        if (m_axis_tvalid && m_axis_tready && !rst) begin
            $display("Time: %0t | Output #%0d | Result: %0d", $time, output_count, $signed(m_axis_tdata));
            output_count++;
        end
    end

endmodule
