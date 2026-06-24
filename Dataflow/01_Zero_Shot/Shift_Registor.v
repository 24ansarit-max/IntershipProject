module shift_reg_16 #( 
    parameter WIDTH = 16                                  // AREA: Parameterized width 
)( 
    input  wire              clk,                         // System clock 
    input  wire              rst,                         // Synchronous active-high reset 
    input  wire [1:0]        mode,                        // 00=hold 01=right 10=left 11=parallel-load 
    input  wire              serial_in,                   // Serial input 
    input  wire [WIDTH-1:0]  data_in,                     // Parallel input bus 

    output reg  [WIDTH-1:0]  q                            // Registered output 
); 
 
    // AREA: Per-bit replicated wiring generated automatically 
    wire [WIDTH-1:0] hold_path;                           // Hold path 
    wire [WIDTH-1:0] right_path;                          // Right-shift path 
    wire [WIDTH-1:0] left_path;                           // Left-shift path 
    wire [WIDTH-1:0] load_path;                           // Parallel-load path 
    wire [WIDTH-1:0] next_q;                              // Selected next-state value 
 
    // AREA: Generate repeated assign structure 
    genvar g;                                             // Generate index 
    generate 
        for (g = 0; g < WIDTH; g = g + 1) begin : gen_paths 
            assign hold_path[g]  = q[g];                 // Hold current state 
            assign load_path[g]  = data_in[g];           // Parallel-load path 
        end 
    endgenerate 
 
    // AREA: Shift operators map efficiently into LUT fabric 
    assign right_path = {serial_in, q[WIDTH-1:1]};       // Right shift with serial MSB insertion 
 
    // AREA: Concatenation-based left shift 
    assign left_path  = {q[WIDTH-2:0], serial_in};       // Left shift with serial LSB insertion 
 
    // TIMING: Critical path = q/data_in -> mode mux -> next_q -> FDRE D input 
    assign next_q = 
           (mode == 2'b00) ? hold_path  :               // POWER: Hold mode minimizes activity 

           (mode == 2'b01) ? right_path :               // Right shift 
           (mode == 2'b10) ? left_path  :               // Left shift 
                             load_path;                 // Parallel load 
 
    // TIMING: Single register stage 
    // POWER: Hold mode allows Vivado CE-style optimization opportunities 
    always @(posedge clk) begin 
        if (rst) 
            q <= {WIDTH{1'b0}};                         // Synchronous reset 
        else 
            q <= next_q;                               // Register selected next state 
    end 
endmodule