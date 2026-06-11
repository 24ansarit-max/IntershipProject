// 2-input AND gate 
module and_gate( 
    input  a, 
    input  b, 
    output y 
); 
    assign y = a & b; 
endmodule 
 
// Half Adder 
module half_adder( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    assign sum   = a ^ b; 
    assign carry = a & b; 

endmodule 
 
// Full Adder 
module full_adder( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output cout 
); 
    wire s1; 
    wire c1; 
    wire c2; 
 
    assign s1   = a ^ b; 
    assign sum  = s1 ^ cin; 
    assign c1   = a & b; 
    assign c2   = s1 & cin; 
    assign cout = c1 | c2; 
endmodule 
 
// 4-bit Array Multiplier 
module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 

); 
 
    // Partial products 
    wire p00, p01, p02, p03; 
    wire p10, p11, p12, p13; 
    wire p20, p21, p22, p23; 
    wire p30, p31, p32, p33; 
 
    // Row 1 signals 
    wire s11, c11; 
    wire s12, c12; 
    wire s13, c13; 
 
    // Row 2 signals 
    wire s21, c21; 
    wire s22, c22; 
    wire s23, c23; 
    wire s24, c24; 
 
    // Row 3 signals 
    wire s31, c31; 
    wire s32, c32; 
    wire s33, c33; 
    wire s34, c34; 
    wire s35, c35; 
 

    // Product MSB carry chain 
    wire s41, c41; 
 
    // Partial product generation 
    and_gate pp00 (.a(a[0]), .b(b[0]), .y(p00)); 
    and_gate pp01 (.a(a[1]), .b(b[0]), .y(p01)); 
    and_gate pp02 (.a(a[2]), .b(b[0]), .y(p02)); 
    and_gate pp03 (.a(a[3]), .b(b[0]), .y(p03)); 
 
    and_gate pp10 (.a(a[0]), .b(b[1]), .y(p10)); 
    and_gate pp11 (.a(a[1]), .b(b[1]), .y(p11)); 
    and_gate pp12 (.a(a[2]), .b(b[1]), .y(p12)); 
    and_gate pp13 (.a(a[3]), .b(b[1]), .y(p13)); 
 
    and_gate pp20 (.a(a[0]), .b(b[2]), .y(p20)); 
    and_gate pp21 (.a(a[1]), .b(b[2]), .y(p21)); 
    and_gate pp22 (.a(a[2]), .b(b[2]), .y(p22)); 
    and_gate pp23 (.a(a[3]), .b(b[2]), .y(p23)); 
 
    and_gate pp30 (.a(a[0]), .b(b[3]), .y(p30)); 
    and_gate pp31 (.a(a[1]), .b(b[3]), .y(p31)); 
    and_gate pp32 (.a(a[2]), .b(b[3]), .y(p32)); 
    and_gate pp33 (.a(a[3]), .b(b[3]), .y(p33)); 
 
    // First reduction row 
    assign product[0] = p00; 

 
    half_adder ha11 ( 
        .a(p01), 
        .b(p10), 
        .sum(product[1]), 
        .carry(c11) 
    ); 
 
    full_adder fa12 ( 
        .a(p02), 
        .b(p11), 
        .cin(c11), 
        .sum(s12), 
        .cout(c12) 
    ); 
 
    full_adder fa13 ( 
        .a(p03), 
        .b(p12), 
        .cin(c12), 
        .sum(s13), 
        .cout(c13) 
    ); 
 
    half_adder ha14 ( 
        .a(p13), 

        .b(c13), 
        .sum(s11), 
        .carry(c21) 
    ); 
 
    // Second reduction row 
    half_adder ha21 ( 
        .a(s12), 
        .b(p20), 
        .sum(product[2]), 
        .carry(c22) 
    ); 
 
    full_adder fa22 ( 
        .a(s13), 
        .b(p21), 
        .cin(c22), 
        .sum(s22), 
        .cout(c23) 
    ); 
 
    full_adder fa23 ( 
        .a(s11), 
        .b(p22), 
        .cin(c23), 
        .sum(s23), 

        .cout(c24) 
    ); 
 
    full_adder fa24 ( 
        .a(c21), 
        .b(p23), 
        .cin(c24), 
        .sum(s24), 
        .cout(s21) 
    ); 
 
    // Third reduction row 
    half_adder ha31 ( 
        .a(s22), 
        .b(p30), 
        .sum(product[3]), 
        .carry(c31) 
    ); 
 
    full_adder fa32 ( 
        .a(s23), 
        .b(p31), 
        .cin(c31), 
        .sum(product[4]), 
        .cout(c32) 
    ); 

 
    full_adder fa33 ( 
        .a(s24), 
        .b(p32), 
        .cin(c32), 
        .sum(s33), 
        .cout(c33) 
    ); 
 
    full_adder fa34 ( 
        .a(s21), 
        .b(p33), 
        .cin(c33), 
        .sum(s34), 
        .cout(c34) 
    ); 
 
    // Final carry propagation row 
    half_adder ha41 ( 
        .a(s33), 
        .b(c34), 
        .sum(product[5]), 
        .carry(c41) 
    ); 
 
    full_adder fa42 ( 

        .a(s34), 
        .b(c41), 
        .cin(1'b0), 
        .sum(product[6]), 
        .cout(product[7]) 
    ); 
 
endmodule