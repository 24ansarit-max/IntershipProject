module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output reg [7:0] product 
); 
 
    integer i; 
 
    always @(*) begin 
        // Initialize accumulator to zero before summing 
        // all partial products. 
        product = 8'b0; 
 
        // Generate and accumulate partial products. 
        // For each bit of multiplier b: 
        //   - If b[i] is 1, add a shifted version of a 
        //     corresponding to the partial product row. 
        //   - If b[i] is 0, add nothing. 

        for (i = 0; i < 4; i = i + 1) begin 
            if (b[i]) begin 
                // Partial product = a shifted left by i positions 
                product = product + ({4'b0000, a} << i); 
            end 
        end 
    end 
 
endmodule