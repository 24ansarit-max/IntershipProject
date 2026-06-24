`timescale 1ns/1ps 
module ripple_carry_adder_16 
#( 
    parameter WIDTH = 16 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output reg  [WIDTH-1:0] sum, 
    output reg              cout 
); 
 
    // Internal carry chain. 
    // WIDTH+1 bits: 
    //   carry[0]     = cin 
    //   carry[WIDTH] = final carry-out 

    reg [WIDTH:0] carry; 
 
    // Loop variable. 
    integer i; 
 
    //================================================================== 
    // Pure combinational logic. 
    // 
    // Fully assigns carry, sum, and cout to avoid latch inference. 
    //================================================================== 
    always @(*) begin 
 
        // Full initialization satisfies the zero-latch constraint. 
        sum   = {WIDTH{1'b0}}; 
        cout  = 1'b0; 
        carry = {(WIDTH+1){1'b0}}; 
 
        // Initial carry input. 
        carry[0] = cin; 
 
        // Required for-loop. 
        // Synthesis expands this into WIDTH ripple stages. 
        for (i = 0; i < WIDTH; i = i + 1) begin 
 
            // Full-adder sum equation. 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            // Full-adder carry equation. 

            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
        // Explicit final carry assignment. 
        cout = carry[WIDTH]; 
 
    end 
 
endmodule