`timescale 1ns/1ps 
module ripple_carry_adder #( 
parameter WIDTH = 16 
)( 
input wire [WIDTH-1:0] a, 
input wire [WIDTH-1:0] b, 
input wire cin, 
 
output reg [WIDTH-1:0] sum, 
output reg cout 
); 
 
// Internal carry chain 
reg [WIDTH:0] carry; 
 
// Loop variable 
integer i; 
 

//================================================================== 
// Combinational Ripple Carry Logic 
//================================================================== 
always @(*) begin 
// Default assignments prevent latch inference 
sum = {WIDTH{1'b0}}; 
cout = 1'b0; 
carry = {(WIDTH+1){1'b0}}; 
 
// Initial carry 
carry[0] = cin; 
 
// Ripple carry chain 
for (i = 0; i < WIDTH; i = i + 1) begin 
// Full-adder sum 
sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
// Full-adder carry 
carry[i+1] = 
(a[i] & b[i]) | 
(a[i] & carry[i]) | 
(b[i] & carry[i]); 
end 
 
// Explicit final carry connection 
cout = carry[WIDTH]; 
end 
 
endmodule