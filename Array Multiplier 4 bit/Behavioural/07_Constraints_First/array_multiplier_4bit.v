module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output reg [7:0] product 
); 
 
    integer i; 
 
    always @(*) begin 
        // Initialize accumulator 
        product = 8'b0; 
 
        // Shift-and-add multiplication 
        for (i = 0; i < 4; i = i + 1) begin 
            if (a[i]) 
                product = product + ({4'b0000, b} << i); 
        end 
    end 
 
endmodule