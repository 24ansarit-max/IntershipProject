//==================================================== 
// Basic Gates / Adders 
//==================================================== 
 
module and_gate( 
    input  a, 
    input  b, 
    output y 
); 
    assign y = a & b; 
endmodule 
 
 
module half_adder( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    assign sum   = a ^ b; 
    assign carry = a & b; 
endmodule 
 
 
module full_adder( 

    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output cout 
); 
    wire s1, c1, c2; 
 
    half_adder HA1 ( 
        .a(a), 
        .b(b), 
        .sum(s1), 
        .carry(c1) 
    ); 
 
    half_adder HA2 ( 
        .a(s1), 
        .b(cin), 
        .sum(sum), 
        .carry(c2) 
    ); 
 
    assign cout = c1 | c2; 
endmodule 
 
 

//==================================================== 
// 4-Bit Array Multiplier 
//==================================================== 
 
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
 
    // Generate partial products 
    and_gate G00 (.a(a[0]), .b(b[0]), .y(p00)); 
    and_gate G01 (.a(a[1]), .b(b[0]), .y(p01)); 
    and_gate G02 (.a(a[2]), .b(b[0]), .y(p02)); 
    and_gate G03 (.a(a[3]), .b(b[0]), .y(p03)); 
 
    and_gate G10 (.a(a[0]), .b(b[1]), .y(p10)); 
    and_gate G11 (.a(a[1]), .b(b[1]), .y(p11)); 
    and_gate G12 (.a(a[2]), .b(b[1]), .y(p12)); 
    and_gate G13 (.a(a[3]), .b(b[1]), .y(p13)); 

 
    and_gate G20 (.a(a[0]), .b(b[2]), .y(p20)); 
    and_gate G21 (.a(a[1]), .b(b[2]), .y(p21)); 
    and_gate G22 (.a(a[2]), .b(b[2]), .y(p22)); 
    and_gate G23 (.a(a[3]), .b(b[2]), .y(p23)); 
 
    and_gate G30 (.a(a[0]), .b(b[3]), .y(p30)); 
    and_gate G31 (.a(a[1]), .b(b[3]), .y(p31)); 
    and_gate G32 (.a(a[2]), .b(b[3]), .y(p32)); 
    and_gate G33 (.a(a[3]), .b(b[3]), .y(p33)); 
 
    // Internal sums and carries 
    wire s11, c11; 
    wire s12, c12; 
    wire s13, c13; 
 
    wire s21, c21; 
    wire s22, c22; 
    wire s23, c23; 
    wire s24, c24; 
 
    wire s31, c31; 
    wire s32, c32; 
    wire s33, c33; 
    wire s34, c34; 
 

    wire s41, c41; 
    wire s42, c42; 
    wire s43, c43; 
 
    // Product bit 0 
    assign product[0] = p00; 
 
    //------------------------------------------------ 
    // Row 1 
    //------------------------------------------------ 
    half_adder HA1 ( 
        .a(p01), 
        .b(p10), 
        .sum(product[1]), 
        .carry(c11) 
    ); 
 
    full_adder FA1 ( 
        .a(p02), 
        .b(p11), 
        .cin(c11), 
        .sum(s12), 
        .cout(c12) 
    ); 
 
    full_adder FA2 ( 

        .a(p03), 
        .b(p12), 
        .cin(c12), 
        .sum(s13), 
        .cout(c13) 
    ); 
 
    half_adder HA2 ( 
        .a(p13), 
        .b(c13), 
        .sum(s21), 
        .carry(c21) 
    ); 
 
    //------------------------------------------------ 
    // Row 2 
    //------------------------------------------------ 
    half_adder HA3 ( 
        .a(s12), 
        .b(p20), 
        .sum(product[2]), 
        .carry(c22) 
    ); 
 
    full_adder FA3 ( 
        .a(s13), 

        .b(p21), 
        .cin(c22), 
        .sum(s22), 
        .cout(c23) 
    ); 
 
    full_adder FA4 ( 
        .a(s21), 
        .b(p22), 
        .cin(c23), 
        .sum(s23), 
        .cout(c24) 
    ); 
 
    full_adder FA5 ( 
        .a(c21), 
        .b(p23), 
        .cin(c24), 
        .sum(s24), 
        .cout(c31) 
    ); 
 
    //------------------------------------------------ 
    // Row 3 
    //------------------------------------------------ 
    half_adder HA4 ( 

        .a(s22), 
        .b(p30), 
        .sum(product[3]), 
        .carry(c32) 
    ); 
 
    full_adder FA6 ( 
        .a(s23), 
        .b(p31), 
        .cin(c32), 
        .sum(s31), 
        .cout(c33) 
    ); 
 
    full_adder FA7 ( 
        .a(s24), 
        .b(p32), 
        .cin(c33), 
        .sum(s32), 
        .cout(c34) 
    ); 
 
    full_adder FA8 ( 
        .a(c31), 
        .b(p33), 
        .cin(c34), 

        .sum(s33), 
        .cout(s34) 
    ); 
 
    //------------------------------------------------ 
    // Final Product Bits 
    //------------------------------------------------ 
    assign product[4] = s31; 
    assign product[5] = s32; 
    assign product[6] = s33; 
    assign product[7] = s34; 
 
endmodule