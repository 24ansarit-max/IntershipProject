module shift_reg_16 ( 
    input  wire        clk,           // System clock 
    input  wire        rst,           // Synchronous active-high reset 

    input  wire        shift_en,      // Shift enable 
    input  wire        dir,           // Shift direction: 0=left, 1=right 
    input  wire        serial_in,     // Serial data input 
    input  wire        parallel_load, // Parallel load control 
    input  wire [15:0] data_in,       // Parallel load data 
    output reg  [15:0] q             // Shift register output 
); 
 
    integer i; // Loop variable for shift operations 
 
    always @(posedge clk) begin 
        if (rst) begin 
            q <= 16'b0; // Synchronous reset clears all bits 
        end 
        else if (parallel_load) begin 
            q <= data_in; // Parallel load has highest priority after reset 
        end 
        else if (shift_en) begin 
            if (dir == 1'b0) begin 
                // Left shift operation 
                for (i = 0; i <= 14; i = i + 1) begin 
                    q[i] <= q[i + 1]; // Move higher-index bit toward LSB 
                end 
                q[15] <= serial_in; // Insert serial input at MSB 
            end 
            else begin 
                // Right shift operation 
                for (i = 0; i <= 14; i = i + 1) begin 

                    q[15 - i] <= q[14 - i]; // Move lower-index bit toward MSB 
                end 
                q[0] <= serial_in; // Insert serial input at LSB 
            end 
        end 
        // No assignment when idle: 
        // register retains value, minimizing unnecessary switching activity 
    end 
 
endmodule