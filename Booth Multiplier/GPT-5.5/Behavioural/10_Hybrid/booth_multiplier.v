module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output reg signed [31:0] product 
); 
 
    integer i; 
    reg signed [32:0] booth_reg; 
    reg signed [16:0] multiplicand_ext; 
 
    always @* begin 
        multiplicand_ext = {multiplicand[15], multiplicand}; 
 

        // {A[16:0], Q[15:0], Q-1} 
        booth_reg = {17'd0, multiplier, 1'b0}; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            case (booth_reg[1:0]) 
                2'b01: booth_reg[32:16] = booth_reg[32:16] + multiplicand_ext; 
                2'b10: booth_reg[32:16] = booth_reg[32:16] - multiplicand_ext; 
                default: ; 
            endcase 
 
            // Arithmetic right shift of {A,Q,Q-1} 
            booth_reg = $signed(booth_reg) >>> 1; 
        end 
 
        // Final product = {A,Q} 
        product = booth_reg[32:1]; 
    end 
 
endmodule