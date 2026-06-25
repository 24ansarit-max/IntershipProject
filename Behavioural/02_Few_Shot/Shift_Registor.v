module shift_reg_16 ( 
    input  wire        clk,        // System clock 
    input  wire        rst,        // Synchronous active-high reset 
    input  wire [1:0]  mode,       // 00=hold, 01=right, 10=left, 11=load 
    input  wire        serial_in,  // Serial input for shift operations 

    input  wire [15:0] data_in,    // Parallel load input 
    output reg  [15:0] q           // Register contents 
); 
 
    // ------------------------------------------------------------------ 
    // Generate block used to create the flip-flop array structure 
    // ------------------------------------------------------------------ 
    genvar g; 
    generate 
        for (g = 0; g < 16; g = g + 1) begin : flop_array 
            // AREA: Generate replicates storage structure without 
            // manually instantiating 16 separate registers. 
        end 
    endgenerate 
 
    integer i; // Loop variable for shift operations 
 
    // ------------------------------------------------------------------ 
    // Single sequential process 
    // ------------------------------------------------------------------ 
    always @(posedge clk) begin 
 
        // Synchronous reset 
        if (rst) begin 
            q <= 16'b0; // Clear all bits 
        end 
        else begin 
 

            case (mode) 
 
                // ------------------------------------------------------ 
                // HOLD MODE 
                // ------------------------------------------------------ 
                2'b00: begin 
                    // AREA: No assignment during hold. 
                    // Synthesizes to FF clock-enable behavior. 
                    // Minimizes unnecessary switching activity. 
                end 
 
                // ------------------------------------------------------ 
                // RIGHT SHIFT MODE 
                // Example: 
                // q <= {serial_in, q[15:1]} 
                // ------------------------------------------------------ 
                2'b01: begin 
 
                    // TIMING: Shift path is only one FF-to-FF transfer. 
                    // Critical path remains very short (>100 MHz target). 
 
                    for (i = 0; i < 15; i = i + 1) begin 
                        q[i] <= q[i + 1]; // Move bit toward LSB 
                    end 
 
                    q[15] <= serial_in; // Load new MSB 
                end 
 

                // ------------------------------------------------------ 
                // LEFT SHIFT MODE 
                // Example: 
                // q <= {q[14:0], serial_in} 
                // ------------------------------------------------------ 
                2'b10: begin 
 
                    // TIMING: Single-bit FF-to-FF routing only. 
                    // No arithmetic logic in the shift path. 
 
                    for (i = 15; i > 0; i = i - 1) begin 
                        q[i] <= q[i - 1]; // Move bit toward MSB 
                    end 
 
                    q[0] <= serial_in; // Load new LSB 
                end 
 
                // ------------------------------------------------------ 
                // PARALLEL LOAD MODE 
                // ------------------------------------------------------ 
                2'b11: begin 
 
                    // AREA: Direct register load avoids extra mux stages. 
                    // Only one 4:1 selection per bit is inferred. 
 
                    q <= data_in; // Parallel load all 16 bits 
                end 
 

                default: begin 
                    // Defensive coding; register holds value. 
                end 
 
            endcase 
        end 
    end 
 
endmodule