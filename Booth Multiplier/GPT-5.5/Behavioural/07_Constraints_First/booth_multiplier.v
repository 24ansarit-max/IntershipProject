module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output reg signed [31:0] product 
); 
 
    integer i; 
 
    reg signed [15:0] A; 
    reg signed [15:0] Q; 
    reg signed [15:0] M; 
    reg               Q_1; 
 
    reg signed [32:0] booth_reg; 
 
    always @(*) begin 
        A   = 16'sd0; 

        Q   = multiplier; 
        M   = multiplicand; 
        Q_1 = 1'b0; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            case ({Q[0], Q_1}) 
                2'b01: A = A + M; 
                2'b10: A = A - M; 
                default: A = A; 
            endcase 
 
            booth_reg = {A, Q, Q_1}; 
            booth_reg = booth_reg >>> 1; 
 
            A   = booth_reg[32:17]; 
            Q   = booth_reg[16:1]; 
            Q_1 = booth_reg[0]; 
        end 
 
        product = {A, Q}; 
    end 
 
endmodule