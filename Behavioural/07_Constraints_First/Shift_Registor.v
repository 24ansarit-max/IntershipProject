module shift_reg_16 #( 
    parameter WIDTH = 16                           // AREA: Single parameter controls register width 
)( 
    input  wire              clk,                  // TIMING: Global clock input 
    input  wire              rst,                  // TIMING: Synchronous active-high reset 
    input  wire [1:0]        mode,                 // MUX select: 00=hold, 01=right, 10=left, 11=load 
    input  wire              serial_in,            // SHIFT: Serial input bit 
    input  wire [WIDTH-1:0]  data_in,              // LOAD: Parallel input bus 
    output reg  [WIDTH-1:0]  q                     // STORAGE: Shift register state 
); 
 
    integer i;                                     // SHIFT: For-loop index 
    integer clr_idx;                               // RESET: While-loop index 
 
    // AREA: Generate block documents WIDTH storage elements 
    // AREA: Vivado expected to infer WIDTH FDRE primitives 
    genvar g;                                      // Generate-loop variable 
    generate 
        for (g = 0; g < WIDTH; g = g + 1) begin : gen_flops 
            // AREA: Storage bit g 
            // AREA: Expected primitive after synthesis = FDRE 
            // TIMING: One FF per register bit 

        end 
    endgenerate 
 
    // TIMING: Single clocked process 
    // POWER: No combinational shift network outside register update path 
    always @(posedge clk) begin 
 
        if (rst) begin                             // TIMING: Reset selected 
 
            clr_idx = 0;                           // RESET: Initialize while-loop counter 
 
            while (clr_idx < WIDTH) begin          // RESET: Demonstrate while-loop clear 
                q[clr_idx] <= 1'b0;                // TIMING: Clear one register bit 
                clr_idx = clr_idx + 1;             // RESET: Advance counter 
            end 
 
        end 
        else begin 
 
            case (mode) 
 
                2'b00: begin                       // HOLD mode 
 
                    q <= q;                        // POWER: Register retains value 
                                                   // POWER: Vivado may infer CE optimization 
                                                   // AREA: No additional datapath logic 
 
                end 

 
                2'b01: begin                       // RIGHT SHIFT mode 
 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[i] <= q[i+1];           // SHIFT: Move data toward LSB 
                                                   // TIMING: FF->MUX->FF path 
                    end 
 
                    q[WIDTH-1] <= serial_in;      // SHIFT: Insert serial bit into MSB 
                                                   // TIMING: Serial input path 
 
                end 
 
                2'b10: begin                       // LEFT SHIFT mode 
 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[WIDTH-1-i] <= q[WIDTH-2-i]; 
                                                   // SHIFT: Move data toward MSB 
                                                   // TIMING: FF->MUX->FF path 
                    end 
 
                    q[0] <= serial_in;            // SHIFT: Insert serial bit into LSB 
                                                   // TIMING: Serial input path 
 
                end 
 
                2'b11: begin                       // PARALLEL LOAD mode 
 

                    q <= data_in;                 // MUX: Load external data bus 
                                                   // TIMING: Input->MUX->FF path 
                                                   // AREA: Shared load path 
 
                end 
 
                default: begin                     // Safety default 
 
                    q <= q;                        // POWER: Hold state 
                                                   // LATCH: Prevents unintended behavior 
 
                end 
 
            endcase 
 
        end 
 
    end 
 
endmodule