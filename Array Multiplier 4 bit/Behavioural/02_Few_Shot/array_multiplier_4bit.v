module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output reg [7:0] product 
); 
 
    integer i; 
    reg [7:0] partial_product; 
 
    always @(*) begin 
        product = 8'b0; 
 
        // Generate and accumulate partial products 
        for (i = 0; i < 4; i = i + 1) begin 

            if (b[i]) begin 
                partial_product = ({4'b0000, a} << i); 
                product = product + partial_product; 
            end 
        end 
    end 
 
endmodule