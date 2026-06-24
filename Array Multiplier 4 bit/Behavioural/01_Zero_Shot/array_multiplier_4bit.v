module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Behavioral description of a 4-bit unsigned multiplier 
    assign product = a * b; 

 
endmodule