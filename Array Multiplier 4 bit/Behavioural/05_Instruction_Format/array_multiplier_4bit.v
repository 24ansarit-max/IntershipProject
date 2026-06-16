module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output reg [7:0] product 

); 
 
    integer i; 
    reg [7:0] accumulator; 
 
    // Combinational shift-and-add implementation 
    // of a 4-bit unsigned array multiplier 
    always @(*) begin 
        // Initialize accumulator to zero 
        accumulator = 8'd0; 
 
        // For each bit of multiplicand 'a' 
        // add the appropriately shifted version 
        // of multiplier 'b' when the bit is set 
        for (i = 0; i < 4; i = i + 1) begin 
            if (a[i]) 
                accumulator = accumulator + ({4'b0000, b} << i); 
        end 
 
        // Assign final accumulated result 
        product = accumulator; 
    end 
 
endmodule