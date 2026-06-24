Design module- 
 
Structural Full Adder - 
module full_adder ( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output cout 
); 
 
    wire x1; 
    wire a1, a2, a3; 
 
    xor (x1,  a,   b); 
    xor (sum, x1,  cin); 
 
    and (a1,  a,   b); 
    and (a2,  a,   cin); 
    and (a3,  b,   cin); 
 
    or  (cout, a1, a2, a3); 
 
endmodule 
 
16-bit Signed Adder (STRICTLY STRUCTURAL) - 
module signed_adder_16_structural ( 
    input  signed [15:0] A, 
    input  signed [15:0] B, 
    output signed [16:0] sum 
); 
 
    wire c1, c2, c3, c4, c5, c6, c7, c8; 
    wire c9, c10, c11, c12, c13, c14, c15, c16; 
 
    full_adder FA0 ( 
        .a   (A[0]), 
        .b   (B[0]), 
        .cin (1'b0), 
        .sum (sum[0]), 
        .cout(c1) 
    ); 
 
    full_adder FA1 ( 
        .a   (A[1]), 
        .b   (B[1]), 
        .cin (c1), 
        .sum (sum[1]), 
        .cout(c2) 
    ); 
 
    full_adder FA2 ( 
        .a   (A[2]), 
        .b   (B[2]), 
        .cin (c2), 
        .sum (sum[2]), 
        .cout(c3) 
    ); 
 
    full_adder FA3 ( 
        .a   (A[3]), 
        .b   (B[3]), 
        .cin (c3), 
        .sum (sum[3]), 
        .cout(c4) 
    ); 
 
    full_adder FA4 ( 
        .a   (A[4]), 
        .b   (B[4]), 
        .cin (c4), 
        .sum (sum[4]), 
        .cout(c5) 
    ); 
 
    full_adder FA5 ( 
        .a   (A[5]), 
        .b   (B[5]), 
        .cin (c5), 
        .sum (sum[5]), 
        .cout(c6) 
    ); 
 
    full_adder FA6 ( 
        .a   (A[6]), 
        .b   (B[6]), 
        .cin (c6), 
        .sum (sum[6]), 
        .cout(c7) 
    ); 
 
    full_adder FA7 ( 
        .a   (A[7]), 
        .b   (B[7]), 
        .cin (c7), 
        .sum (sum[7]), 
        .cout(c8) 
    ); 
 
    full_adder FA8 ( 
        .a   (A[8]), 
        .b   (B[8]), 
        .cin (c8), 
        .sum (sum[8]), 
        .cout(c9) 
    ); 
 
    full_adder FA9 ( 
        .a   (A[9]), 
        .b   (B[9]), 
        .cin (c9), 
        .sum (sum[9]), 
        .cout(c10) 
    ); 
 
    full_adder FA10 ( 
        .a   (A[10]), 
        .b   (B[10]), 
        .cin (c10), 
        .sum (sum[10]), 
        .cout(c11) 
    ); 
 
    full_adder FA11 ( 
        .a   (A[11]), 
        .b   (B[11]), 
        .cin (c11), 
        .sum (sum[11]), 
        .cout(c12) 
    ); 
 
    full_adder FA12 ( 
        .a   (A[12]), 
        .b   (B[12]), 
        .cin (c12), 
        .sum (sum[12]), 
        .cout(c13) 
    ); 
 
    full_adder FA13 ( 
        .a   (A[13]), 
        .b   (B[13]), 
        .cin (c13), 
        .sum (sum[13]), 
        .cout(c14) 
    ); 
 
    full_adder FA14 ( 
        .a   (A[14]), 
        .b   (B[14]), 
        .cin (c14), 
        .sum (sum[14]), 
        .cout(c15) 
    ); 
 
    full_adder FA15 ( 
        .a   (A[15]), 
        .b   (B[15]), 
        .cin (c15), 
        .sum (sum[15]), 
        .cout(c16) 
    ); 
 
    buf (sum[16], c16); 
 
endmodule