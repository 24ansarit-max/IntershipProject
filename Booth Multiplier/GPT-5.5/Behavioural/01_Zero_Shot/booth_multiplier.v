module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output reg signed [31:0] product 

); 
 
    integer i; 
    reg signed [31:0] A; 
    reg signed [16:0] Q; 
    reg signed [31:0] M; 
 
    always @* begin 
        A = 32'sd0; 
        M = {{16{multiplicand[15]}}, multiplicand}; 
        Q = {multiplier, 1'b0}; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            case (Q[1:0]) 
                2'b01: A = A + M; 
                2'b10: A = A - M; 
                default: A = A; 
            endcase 
 
            Q = {A[0], Q[16:1]}; 
            A = A >>> 1; 
        end 
 
        product = {A[15:0], Q[16:1]}; 
    end 
 

endmodule