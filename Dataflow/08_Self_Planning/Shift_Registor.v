module shift_reg_16 #( 
    parameter WIDTH = 16                                  // IMPL-1: Parameterized width 
)( 
    input  wire              clk,                         // System clock 
    input  wire              rst,                         // Synchronous active-high reset 
    input  wire [1:0]        mode,                        // 00=hold 01=right 10=left 11=load 
    input  wire              serial_in,                   // Serial shift input 
    input  wire [WIDTH-1:0]  data_in,                     // Parallel load input 
    output reg  [WIDTH-1:0]  q                            // Registered output 
); 
 
    wire [WIDTH-1:0] r_taps;                              // IMPL-3: Right-shift tap wires 

    wire [WIDTH-1:0] l_taps;                              // IMPL-3: Left-shift tap wires 
    wire [WIDTH-1:0] next_q;                              // IMPL-4: Mux output 
 
    genvar i;                                             // IMPL-3: Ascending generate index 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right 
            assign r_taps[i] = q[i+1];                    // AREA: Wire-only path, 0 LUTs 
        end 
    endgenerate 
 
    assign r_taps[WIDTH-1] = serial_in;                   // AREA: Wire-only path, 0 LUTs 
 
    genvar j;                                             // IMPL-3: Descending generate index 
 
    generate 
        for (j = WIDTH-1; j > 0; j = j - 1) begin : gen_left 
            assign l_taps[j] = q[j-1];                    // AREA: Wire-only path, 0 LUTs 
        end 
    endgenerate 
 
    assign l_taps[0] = serial_in;                         // AREA: Wire-only path, 0 LUTs 
 
    assign next_q =                                       // IMPL-4: 4-way mode mux 
                    (mode == 2'b01) ? r_taps  :           // TIMING: Mux level 1 
                    (mode == 2'b10) ? l_taps  :           // TIMING: Mux level 1 
                    (mode == 2'b11) ? data_in :           // TIMING: Mux level 1 
                                      q;                  // TIMING: Hold path 

 
    always @(posedge clk) begin                           // IMPL-7: Single sequential block 
        if (rst)                                          // Synchronous reset only 
            q <= {WIDTH{1'b0}};                           // IMPL-5: Defined reset state 
        else 
            q <= next_q;                                  // TIMING: FDRE D-input capture 
    end 
 
endmodule