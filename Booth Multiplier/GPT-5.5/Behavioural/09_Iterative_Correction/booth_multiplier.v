module booth_multiplier_16 ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output reg    signed [31:0] product 
); 
 
    integer i; 
 
    reg signed [16:0] M; 
    reg signed [16:0] A; 

    reg signed [15:0] Q; 
    reg               Q_1; 
 
    always @(*) begin 
        M   = {multiplicand[15], multiplicand}; 
        A   = 17'sd0; 
        Q   = multiplier; 
        Q_1 = 1'b0; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            case ({Q[0], Q_1}) 
                2'b01: A = A + M; 
                2'b10: A = A - M; 
                default: A = A; 
            endcase 
 
            {A, Q, Q_1} = $signed({A, Q, Q_1}) >>> 1; 
        end 
 
        product = {A[15:0], Q}; 
    end 
 
endmodule