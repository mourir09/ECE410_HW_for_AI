module compute_core (
    input  logic        clk,
    input  logic        reset_n,

    // AXI4-Stream Slave (Input from Host)
    input  logic [7:0]  s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,

    // AXI4-Stream Master (Output to Host)
    output logic [31:0] m_axis_tdata, 
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready
);

    // --- 1. Architectural Parameters ---
    localparam int IMG_WIDTH = 28;
    
    // REPLACE THESE with your actual 3x3 kernel weights!
    // Currently set to a simple edge-detection (Sobel-like) filter
    localparam signed [7:0] weight [0:2][0:2] = '{ 
        '{8'sd1,  8'sd2,  8'sd1},
        '{8'sd0,  8'sd0,  8'sd0},
        '{-8'sd1, -8'sd2, -8'sd1} 
    };
    
    // --- 2. The Sliding Window & Line Buffers ---
    logic signed [7:0] window [0:2][0:2];
    logic signed [7:0] line_buf_1 [0:IMG_WIDTH-1];
    logic signed [7:0] line_buf_2 [0:IMG_WIDTH-1];

    // --- 3. Control Counters ---
    logic [4:0] col_cnt; // Counts 0 to 27
    logic [4:0] row_cnt; // Counts 0 to 27
    logic       window_valid;

    // We are always ready to accept data as long as the output downstream isn't stalled
    assign s_axis_tready = m_axis_tready;

    // --- 4. The Dataflow Shift Logic ---
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            col_cnt <= '0;
            row_cnt <= '0;
        end 
        else if (s_axis_tvalid && s_axis_tready) begin
            // Shift the 3x3 Window
            window[0][0] <= window[0][1]; window[0][1] <= window[0][2];
            window[1][0] <= window[1][1]; window[1][1] <= window[1][2];
            window[2][0] <= window[2][1]; window[2][1] <= window[2][2];

            // Feed the right-most column of the window
            window[0][2] <= line_buf_2[IMG_WIDTH-1]; 
            window[1][2] <= line_buf_1[IMG_WIDTH-1]; 
            window[2][2] <= s_axis_tdata;            

            // Shift the Line Buffers
            for (int i = IMG_WIDTH-1; i > 0; i--) begin
                line_buf_1[i] <= line_buf_1[i-1];
                line_buf_2[i] <= line_buf_2[i-1];
            end
            
            // Push the pixels falling out of the window into the buffers
            line_buf_1[0] <= window[2][0]; 
            line_buf_2[0] <= window[1][0];

            // Update Image Position Counters
            if (col_cnt == IMG_WIDTH - 1) begin
                col_cnt <= '0;
                if (row_cnt != IMG_WIDTH - 1)
                    row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end
        end
    end

    // --- 5. Validity Control (The Edge Case Logic) ---
    // Valid only when we've cached 2 full rows and shifted in 3 pixels of current row
    // AND we are not wrapping around the edge (col_cnt >= 2)
    assign window_valid = (row_cnt >= 2) && (col_cnt >= 2);

    // --- 6. Pipeline Synchronization ---
    logic valid_pipe_1, valid_pipe_2;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid_pipe_1 <= 1'b0;
            valid_pipe_2 <= 1'b0;
        end else if (s_axis_tready) begin 
            valid_pipe_1 <= window_valid && s_axis_tvalid;
            valid_pipe_2 <= valid_pipe_1;
        end
    end

    assign m_axis_tvalid = valid_pipe_2;

    // --- 7. PIPELINE STAGE 1: Multiplication ---
    logic signed [15:0] prod [0:8]; 

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (int i=0; i<9; i++) prod[i] <= '0;
        end else if (s_axis_tready && window_valid && s_axis_tvalid) begin
            prod[0] <= window[0][0] * weight[0][0];
            prod[1] <= window[0][1] * weight[0][1];
            prod[2] <= window[0][2] * weight[0][2];
            
            prod[3] <= window[1][0] * weight[1][0];
            prod[4] <= window[1][1] * weight[1][1];
            prod[5] <= window[1][2] * weight[1][2];
            
            prod[6] <= window[2][0] * weight[2][0];
            prod[7] <= window[2][1] * weight[2][1];
            prod[8] <= window[2][2] * weight[2][2];
        end
    end

    // --- 8. PIPELINE STAGE 2: Accumulation ---
    logic signed [31:0] sum;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sum <= '0;
        end else if (s_axis_tready && valid_pipe_1) begin
            sum <= prod[0] + prod[1] + prod[2] + 
                   prod[3] + prod[4] + prod[5] + 
                   prod[6] + prod[7] + prod[8];
        end
    end

    assign m_axis_tdata = sum;

endmodule
