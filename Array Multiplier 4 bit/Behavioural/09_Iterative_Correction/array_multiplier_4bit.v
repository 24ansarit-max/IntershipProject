module array_multiplier_4bit ( 
    input  [3:0] A, 

    input  [3:0] B, 
    output reg [7:0] product 
); 
 
    always @(*) begin 
        product = A * B; 
    end 
 
endmodule