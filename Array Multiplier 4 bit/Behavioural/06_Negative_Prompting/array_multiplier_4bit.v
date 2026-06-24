module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output reg [7:0] product 
); 
 
    integer i; 
    reg [7:0] partial_product; 
 
    always @(*) begin 
        // Initialize accumulator 
        product = 8'd0; 
 
        // Generate and accumulate partial products 
        for (i = 0; i < 4; i = i + 1) begin 
            partial_product = 8'd0; 
 
            if (a[i]) begin 
                // Shift multiplicand according to bit position 
                partial_product = {4'b0000, b} << i; 
            end 
 
            // Accumulate partial products 
            product = product + partial_product; 

        end 
    end 
 
endmodule