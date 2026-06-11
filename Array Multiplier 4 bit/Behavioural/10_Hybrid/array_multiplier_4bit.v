module array_multiplier_4bit ( 
    input  [3:0] a, 

    input  [3:0] b, 
    output reg [7:0] product 
); 
 
    // Loop variable used to process each bit of 'a' 
    integer i; 
 
    // Combinational shift-and-add multiplier 
    always @(*) begin 
 
        // Initialize accumulator to prevent latches 
        product = 8'd0; 
 
        // Examine each bit of multiplier 'a' 
        for (i = 0; i < 4; i = i + 1) begin 
 
            // Add shifted partial product when a[i] is asserted 
            if (a[i]) 
                product = product + ({4'b0000, b} << i); 
 
        end 
    end 
 
endmodule