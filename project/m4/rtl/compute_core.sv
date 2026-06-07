module compute_core (
    input  logic        clk,
    input  logic        rst,       
    input  logic        valid_in,  
    input  logic [7:0]  a_in,      
    input  logic [7:0]  b_in,      
    output logic        valid_out, 
    output logic [31:0] result     
);

    // --- 1. Architectural Parameters ---
    localparam int IMG_WIDTH = 28;
    
    // Flattened 3x3 kernel weights for iverilog compatibility
    localparam signed [7:0] W00 =  8'sd1; localparam signed [7:0] W01 =  8'sd2; localparam signed [7:0] W02 =  8'sd1;
    localparam signed [7:0] W10 =  8'sd0; localparam signed [7:0] W11 =  8'sd0; localparam signed [7:0] W12 =  8'sd0;
    localparam signed [7:0] W20 = -8'sd1; localparam signed [7:0] W21 = -8'sd2; localparam signed [7:0] W22 = -8'sd1;

    // --- 2. The Sliding Window & Line Buffers ---
    // To achieve exactly 28 cycles of delay per row:
    // 3 cycles in the window + 25 cycles in the buffer = 28 cycles.
    // 25 elements = indices 0 to 24 (IMG_WIDTH - 4).
    logic signed [7:0] window [0:2][0:2];
    logic signed [7:0] line_buf_1 [0:IMG_WIDTH-4];
    logic signed [7:0] line_buf_2 [0:IMG_WIDTH-4];

    // --- 3. Control Counters ---
    logic [4:0] col_cnt; // Counts 0 to 27
    logic [4:0] row_cnt; // Counts 0 to 27
    logic       window_valid;

    // --- 4. The Dataflow Shift Logic ---
    always_ff @(posedge clk) begin
        if (rst) begin
            col_cnt <= '0;
            row_cnt <= '0;
        end 
        else if (valid_in) begin
            // Shift the 3x3 Window
            window[0][0] <= window[0][1]; window[0][1] <= window[0][2];
            window[1][0] <= window[1][1]; window[1][1] <= window[1][2];
            window[2][0] <= window[2][1]; window[2][1] <= window[2][2];

            // Feed the right-most column of the window
            window[0][2] <= line_buf_2[IMG_WIDTH-4]; 
            window[1][2] <= line_buf_1[IMG_WIDTH-4]; 
            window[2][2] <= a_in;            

            // Shift the Line Buffers
            for (int i = IMG_WIDTH-4; i > 0; i--) begin
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
    assign window_valid = (row_cnt >= 2) && (col_cnt >= 2);

    // --- 6. Pipeline Synchronization ---
    logic valid_pipe_1, valid_pipe_2;

    always_ff @(posedge clk) begin
        if (rst) begin
            valid_pipe_1 <= 1'b0;
            valid_pipe_2 <= 1'b0;
        end else begin 
            valid_pipe_1 <= window_valid && valid_in;
            valid_pipe_2 <= valid_pipe_1;
        end
    end

    assign valid_out = valid_pipe_2;

    // --- 7. PIPELINE STAGE 1: Multiplication ---
    logic signed [15:0] prod [0:8]; 

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i=0; i<9; i++) prod[i] <= '0;
        end else if (valid_in && window_valid) begin
            prod[0] <= window[0][0] * W00;
            prod[1] <= window[0][1] * W01;
            prod[2] <= window[0][2] * W02;
            
            prod[3] <= window[1][0] * W10;
            prod[4] <= window[1][1] * W11;
            prod[5] <= window[1][2] * W12;
            
            prod[6] <= window[2][0] * W20;
            prod[7] <= window[2][1] * W21;
            prod[8] <= window[2][2] * W22;
        end
    end

    // --- 8. PIPELINE STAGE 2: Accumulation ---
    logic signed [31:0] sum;

    always_ff @(posedge clk) begin
        if (rst) begin
            sum <= '0;
        end else if (valid_pipe_1) begin
            sum <= prod[0] + prod[1] + prod[2] + 
                   prod[3] + prod[4] + prod[5] + 
                   prod[6] + prod[7] + prod[8];
        end
    end

    assign result = sum;

endmodule
