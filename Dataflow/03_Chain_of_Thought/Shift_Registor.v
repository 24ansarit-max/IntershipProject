module shift_reg_16 #( 
    parameter WIDTH = 16                                                // Register width parameter 
)( 
    input  wire              clk,                                       // System clock 
    input  wire              rst,                                       // Synchronous active-high reset 
    input  wire [1:0]        mode,                                      // 00=hold 01=right 10=left 11=load 
    input  wire              serial_in,                                 // Serial input 
    input  wire [WIDTH-1:0]  data_in,                                   // Parallel load input 
    output reg  [WIDTH-1:0]  q                                          // Registered output 
); 
    wire [WIDTH-1:0] right_taps;                                        // Generated right-shift wiring 
    wire [WIDTH-1:0] right_path;                                        // Operator-based right shift path 
    wire [WIDTH-1:0] left_path;                                         // Operator-based left shift path 
    wire [WIDTH-1:0] next_q;                                            // Next-state mux output 
 
    //================================================================== 
    // Generate/for Per-Bit Right-Shift Tap Wires 
    //================================================================== 

 
    genvar i;                                                           // Generate index 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right_taps 
            assign right_taps[i] = q[i+1];                              // TIMING: direct wire, ~0 logic depth 
        end 
    endgenerate 
 
    assign right_taps[WIDTH-1] = serial_in;                             // TIMING: direct wire insertion 
 
    //================================================================== 
    // Dataflow Shift Operators 
    //================================================================== 
 
    assign right_path = (q >> 1) |                                      // TIMING: shift routing 
                        ({ { (WIDTH-1){1'b0} }, serial_in }             // TIMING: serial insertion mask 
                         << (WIDTH-1));                                 // TIMING: single mux level after synthesis 
 
    assign left_path  = (q << 1) |                                      // TIMING: shift routing 
                        {{(WIDTH-1){1'b0}}, serial_in};                 // TIMING: serial insertion at LSB 
 
    //================================================================== 
    // Dataflow Mode Multiplexer 
    //================================================================== 
 
    assign next_q = 
           (mode == 2'b01) ? right_path :                               // TIMING: MUXF7/LUT mux stage 

           (mode == 2'b10) ? left_path  :                               // TIMING: MUXF7/LUT mux stage 
           (mode == 2'b11) ? data_in    :                               // TIMING: MUXF7/LUT mux stage 
                             q;                                          // TIMING: hold path 
 
    //================================================================== 
    // Registered Output 
    //================================================================== 
 
    // Expected Vivado primitive: FDRE per bit 
    always @(posedge clk) begin                                         // Single sequential process 
        if (rst)                                                        // Synchronous reset 
            q <= {WIDTH{1'b0}};                                         // Clear register 
        else 
            q <= next_q;                                                // Register next state 
    end 
endmodule