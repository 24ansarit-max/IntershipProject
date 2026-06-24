`timescale 1ns/1ps 
 
module ripple_carry_adder 
#( 
    parameter WIDTH = 16 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output wire [WIDTH-1:0] sum, 
    output wire             cout 
); 
 
    // Internal carry chain 

    // carry[0]     = cin 
    // carry[WIDTH] = final carry-out 
    wire [WIDTH:0] carry; 
 
    // Boundary condition 
    assign carry[0] = cin; 
 
    // Generate WIDTH ripple-carry stages 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : stage 
 
            // Sum equation 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // Carry equation (majority function) 
            assign carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    // Final carry-out 
    assign cout = carry[WIDTH]; 

 
endmodule