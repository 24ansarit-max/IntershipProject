module shift_reg_16 ( 
    input  wire        clk,        // System clock 
    input  wire        rst,        // Synchronous active-high reset 
    input  wire [1:0]  mode,       // 00=hold, 01=right, 10=left, 11=par_load 
    input  wire        serial_in,  // Serial input 
    input  wire [15:0] data_in,    // Parallel load input 
    output reg  [15:0] q           // Register contents 
); 
 
    integer i; // Loop variable 
 
    // Expected Vivado inference: 
    // - 16 x FDRE flip-flops 
    // - Small mode-selection mux network 
    // - SRL16E unlikely because synchronous reset and parallel load are required 
 
    always @(posedge clk) begin 
 
        // TIMING: Reset feeds every FF D-input selection path. 
        if (rst) begin 
            q <= 16'b0; // Synchronous reset 

        end 
        else begin 
 
            case (mode) 
 
                //---------------------------------------------------------- 
                // HOLD MODE 
                //---------------------------------------------------------- 
                2'b00: begin 
                    // Hold current value. 
                    // No assignment required. 
                end 
 
                //---------------------------------------------------------- 
                // SHIFT RIGHT 
                //---------------------------------------------------------- 
                2'b01: begin 
 
                    // TIMING: q[i+1] -> mode mux -> FDRE(D) 
 
                    for (i = 0; i < 15; i = i + 1) begin 
                        q[i] <= q[i+1]; // TIMING: source FF -> mux -> destination FF 
                    end 
 
                    q[15] <= serial_in; // TIMING: serial_in -> mux -> FDRE 
                end 
 
                //---------------------------------------------------------- 

                // SHIFT LEFT 
                //---------------------------------------------------------- 
                2'b10: begin 
 
                    i = 15; 
 
                    while (i > 0) begin 
                        q[i] <= q[i-1]; // TIMING: source FF -> mux -> destination FF 
                        i = i - 1; 
                    end 
 
                    q[0] <= serial_in; // TIMING: serial_in -> mux -> FDRE 
                end 
 
                //---------------------------------------------------------- 
                // PARALLEL LOAD 
                //---------------------------------------------------------- 
                2'b11: begin 
 
                    // TIMING: data_in[i] -> mode mux -> FDRE(D) 
                    // This path is typically the longest because it 
                    // traverses the mode-selection mux network. 
 
                    q <= data_in; 
                end 
 
                //---------------------------------------------------------- 
                // DEFAULT 

                //---------------------------------------------------------- 
                default: begin 
                    q <= q; // Explicit hold 
                end 
 
            endcase 
        end 
    end 
 
endmodule