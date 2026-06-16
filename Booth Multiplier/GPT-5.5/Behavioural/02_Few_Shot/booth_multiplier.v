module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output logic signed [31:0] product 
); 
 
    integer i; 
 
    logic signed [32:0] A; 
    logic signed [32:0] M; 
    logic signed [32:0] Q; 
 
    always_comb begin 
        M = {multiplicand, 17'b0}; 
        Q = {{16{1'b0}}, multiplier, 1'b0}; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            case (Q[1:0]) 
                2'b01: Q = Q + M; 
                2'b10: Q = Q - M; 
                default: ; 

            endcase 
 
            Q = $signed(Q) >>> 1; 
        end 
 
        product = Q[32:1]; 
    end 
 
endmodule