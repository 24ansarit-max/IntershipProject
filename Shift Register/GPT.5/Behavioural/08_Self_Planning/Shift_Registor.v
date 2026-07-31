module shift_reg_16 #( 
    parameter WIDTH = 16                           // IMPL: Parameterized width; no hardcoded 
register size 
)( 
    input  wire              clk,                  // IMPL: System clock 
    input  wire              rst,                  // IMPL: Synchronous active-high reset 
    input  wire [1:0]        mode,                 // IMPL: Mode select (hold/right/left/load) 
    input  wire              serial_in,            // IMPL: Serial input for shift operations 
    input  wire [WIDTH-1:0]  data_in,              // IMPL: Parallel load input bus 
    output reg  [WIDTH-1:0]  q                     // IMPL: Register state/output 
); 
 
    // IMPL: Loop variable for shift operations 
    integer i; 
 
    // IMPL: Local enable expression. 

    // POWER: Allows Vivado to potentially map to FDRE CE logic. 
    wire ce; 
    assign ce = (mode != 2'b00); 
 
    // IMPL: Generate block representing WIDTH storage elements. 
    // AREA: Documents WIDTH FF structure without manual replication. 
    // AREA: Vivado expected to infer WIDTH FDRE primitives. 
    genvar g; 
    generate 
        for (g = 0; g < WIDTH; g = g + 1) begin : gen_ff_array 
            // IMPL: Storage bit g. 
            // AREA: Expected primitive after synthesis = FDRE. 
            // TIMING: One register stage per bit. 
        end 
    endgenerate 
 
    // IMPL: Single synchronous process. 
    // TIMING: Critical path is source -> mode mux -> FDRE D input. 
    // POWER: No combinational next-state network outside this block. 
    always @(posedge clk) begin 
 
        // IMPL: Highest-priority synchronous reset. 
        if (rst) begin 
 
            // IMPL: Clear all bits. 
            q <= {WIDTH{1'b0}}; 
 
        end 
 
        // IMPL: Clock-enable style update. 
        // POWER: Register bank remains unchanged during hold mode. 
        else if (ce) begin 
 
            case (mode) 
 
                //===================================================== 
                // RIGHT SHIFT 
                //===================================================== 
                2'b01: begin 
 
                    // IMPL: Shift toward LSB. 

                    // TIMING: Each assignment becomes FF-to-FF routing. 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[i] <= q[i+1]; 
                    end 
 
                    // IMPL: Insert serial input into MSB. 
                    q[WIDTH-1] <= serial_in; 
                end 
 
                //===================================================== 
                // LEFT SHIFT 
                //===================================================== 
                2'b10: begin 
 
                    // IMPL: Shift toward MSB using same for-loop style. 
                    // TIMING: No combinational ripple path created. 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[WIDTH-1-i] <= q[WIDTH-2-i]; 
                    end 
 
                    // IMPL: Insert serial input into LSB. 
                    q[0] <= serial_in; 
                end 
 
                //===================================================== 
                // PARALLEL LOAD 
                //===================================================== 
                2'b11: begin 
 
                    // IMPL: Direct parallel load. 
                    // AREA: Shared datapath minimizes extra logic. 
                    q <= data_in; 
                end 
 
                //===================================================== 
                // DEFAULT 
                //===================================================== 
                default: begin 
 
                    // IMPL: Defensive hold. 
                    // LATCH AVOIDANCE: Explicit register retention. 

                    q <= q; 
                end 
 
            endcase 
        end 
 
        else begin 
 
            // IMPL: Hold mode. 
            // POWER: No state change, enabling CE-style optimization. 
            q <= q; 
 
        end 
    end 
 
endmodule