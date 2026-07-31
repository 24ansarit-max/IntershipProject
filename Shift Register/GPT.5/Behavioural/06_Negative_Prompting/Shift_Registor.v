module shift_reg_16 #( 
    parameter WIDTH = 16                      // Register width parameter 
)( 
    input  wire              clk,            // System clock 
    input  wire              rst,            // Synchronous active-high reset 
    input  wire [1:0]        mode,           // 00=hold, 01=right, 10=left, 11=parallel-load 
    input  wire              serial_in,      // Serial input for shift operations 
    input  wire [WIDTH-1:0]  data_in,        // Parallel load input bus 
    output reg  [WIDTH-1:0]  q               // Shift register output 
); 
 
    integer i;                               // Loop variable for shift operations 
 
    always @(posedge clk) begin              // Single synchronous process 
 
        if (rst) begin                       // Highest priority: synchronous reset 
            q <= {WIDTH{1'b0}};              // Clear all register bits 
        end 
        else begin                           // Normal operation 
 
            case (mode)                      // Mode selection 
 
                2'b00: begin                 // HOLD mode 
                    q <= q;                  // Retain current value 
                                              // Power-friendly: Vivado may infer CE behavior 

                end 
 
                2'b01: begin                 // RIGHT-SHIFT mode 
 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[i] <= q[i+1];      // Shift data toward LSB 
                    end 
 
                    q[WIDTH-1] <= serial_in; // Load serial input into MSB 
                end 
 
                2'b10: begin                 // LEFT-SHIFT mode 
 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[WIDTH-1-i] <= q[WIDTH-2-i]; 
                                              // Shift data toward MSB 
                    end 
 
                    q[0] <= serial_in;       // Load serial input into LSB 
                end 
 
                2'b11: begin                 // PARALLEL-LOAD mode 
                    q <= data_in;            // Load all bits simultaneously 
                end 
 
                default: begin               // Safety fallback 
                    q <= q;                  // Hold current value 
                end 

 
            endcase                          // End mode selection 
 
        end                                  // End normal operation 
 
    end                                      // End synchronous process 
 
endmodule