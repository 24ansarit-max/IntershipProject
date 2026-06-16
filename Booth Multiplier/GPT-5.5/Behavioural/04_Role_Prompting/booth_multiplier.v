module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output reg signed [31:0] product 
); 
 
    integer i; 
 
    reg signed [16:0] m_ext; 
    reg signed [33:0] booth_reg; 
 
    always @* begin 
        m_ext     = {multiplicand[15], multiplicand}; 
        booth_reg = {17'sd0, multiplier, 1'b0}; 

 
        for (i = 0; i < 16; i = i + 1) begin 
            case (booth_reg[1:0]) 
                2'b01: booth_reg[33:17] = booth_reg[33:17] + m_ext; 
                2'b10: booth_reg[33:17] = booth_reg[33:17] - m_ext; 
                default: ; 
            endcase 
 
            booth_reg = $signed(booth_reg) >>> 1; 
        end 
 
        product = booth_reg[32:1]; 
    end 
 
endmodule