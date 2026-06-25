module shift_reg_16 #( 
    parameter WIDTH = 16                                   // Register width 
)( 
    input  wire              clk,                          // System clock 
    input  wire              rst,                          // Synchronous active-high reset 
    input  wire [1:0]        mode,                         // 00=hold 01=right 10=left 11=load 
    input  wire              serial_in,                    // Serial input 
    input  wire [WIDTH-1:0]  data_in,                      // Parallel load input 
    output reg  [WIDTH-1:0]  q                             // Registered output 
); 
 
    wire [WIDTH-1:0] r_shifted;                            // Right-shift datapath 
    wire [WIDTH-1:0] l_shifted;                            // Left-shift datapath 
    wire [WIDTH-1:0] next_q;                               // Selected next-state value 
 
    genvar i;                                              // Generate index for right shift 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : rshift 

            assign r_shifted[i] = q[i+1];                 // AREA: direct wire connection, no LUT 
        end 
    endgenerate 
 
    assign r_shifted[WIDTH-1] = serial_in;                // AREA: direct wire insertion, no LUT 
 
    genvar j;                                              // Generate index for left shift 
    generate 
        for (j = WIDTH-1; j > 0; j = j - 1) begin : lshift 
            assign l_shifted[j] = q[j-1];                 // AREA: direct wire connection, no LUT 
        end 
    endgenerate 
 
    assign l_shifted[0] = serial_in;                       // AREA: direct wire insertion, no LUT 
 
    assign next_q =                                         // TIMING: mode-select mux feeds FF inputs 
                    (mode == 2'b01) ? r_shifted :          // Right shift path 
                    (mode == 2'b10) ? l_shifted :          // Left shift path 
                    (mode == 2'b11) ? data_in   :          // Parallel load path 
                                      q;                   // Hold path 
 
    always @(posedge clk) begin                             // Single sequential process 
        if (rst)                                            // Synchronous reset 
            q <= {WIDTH{1'b0}};                             // Clear all bits 
        else 
            q <= next_q;                                    // Register selected next state 
    end 
 

endmodule