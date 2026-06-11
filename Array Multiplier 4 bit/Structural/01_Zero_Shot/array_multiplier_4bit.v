//==================================================== 
// 2-input AND Gate 
//==================================================== 
module and_gate ( 
    input  a, 
    input  b, 
    output y 
); 

    assign y = a & b; 
endmodule 
 
//==================================================== 
// Half Adder 
//==================================================== 
module half_adder ( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    assign sum   = a ^ b; 
    assign carry = a & b; 
endmodule 
 
//==================================================== 
// Full Adder 
//==================================================== 
module full_adder ( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output cout 
); 

    wire s1, c1, c2; 
 
    assign s1   = a ^ b; 
    assign c1   = a & b; 
    assign sum  = s1 ^ cin; 
    assign c2   = s1 & cin; 
    assign cout = c1 | c2; 
endmodule 
 
//==================================================== 
// 4-bit Array Multiplier (Structural) 
//==================================================== 
module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Partial products 
    wire p00, p01, p02, p03; 
    wire p10, p11, p12, p13; 
    wire p20, p21, p22, p23; 
    wire p30, p31, p32, p33; 
 
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
 
    //------------------------------------------------ 
    // Partial Product Generation 
    //------------------------------------------------ 
    and_gate g00 (.a(a[0]), .b(b[0]), .y(p00)); 
    and_gate g01 (.a(a[1]), .b(b[0]), .y(p01)); 
    and_gate g02 (.a(a[2]), .b(b[0]), .y(p02)); 
    and_gate g03 (.a(a[3]), .b(b[0]), .y(p03)); 
 
    and_gate g10 (.a(a[0]), .b(b[1]), .y(p10)); 

    and_gate g11 (.a(a[1]), .b(b[1]), .y(p11)); 
    and_gate g12 (.a(a[2]), .b(b[1]), .y(p12)); 
    and_gate g13 (.a(a[3]), .b(b[1]), .y(p13)); 
 
    and_gate g20 (.a(a[0]), .b(b[2]), .y(p20)); 
    and_gate g21 (.a(a[1]), .b(b[2]), .y(p21)); 
    and_gate g22 (.a(a[2]), .b(b[2]), .y(p22)); 
    and_gate g23 (.a(a[3]), .b(b[2]), .y(p23)); 
 
    and_gate g30 (.a(a[0]), .b(b[3]), .y(p30)); 
    and_gate g31 (.a(a[1]), .b(b[3]), .y(p31)); 
    and_gate g32 (.a(a[2]), .b(b[3]), .y(p32)); 
    and_gate g33 (.a(a[3]), .b(b[3]), .y(p33)); 
 
    //------------------------------------------------ 
    // Product[0] 
    //------------------------------------------------ 
    assign product[0] = p00; 
 
    //------------------------------------------------ 
    // Column 1 
    //------------------------------------------------ 
    half_adder HA1 ( 
        .a(p01), 
        .b(p10), 
        .sum(product[1]), 

        .carry(c11) 
    ); 
 
    //------------------------------------------------ 
    // Column 2 
    //------------------------------------------------ 
    full_adder FA21 ( 
        .a(p02), 
        .b(p11), 
        .cin(p20), 
        .sum(s21), 
        .cout(c21) 
    ); 
 
    half_adder HA21 ( 
        .a(s21), 
        .b(c11), 
        .sum(product[2]), 
        .carry(c22) 
    ); 
 
    //------------------------------------------------ 
    // Column 3 
    //------------------------------------------------ 
    full_adder FA31 ( 
        .a(p03), 

        .b(p12), 
        .cin(p21), 
        .sum(s31), 
        .cout(c31) 
    ); 
 
    full_adder FA32 ( 
        .a(s31), 
        .b(p30), 
        .cin(c21), 
        .sum(s32), 
        .cout(c32) 
    ); 
 
    full_adder FA33 ( 
        .a(s32), 
        .b(c22), 
        .cin(1'b0), 
        .sum(product[3]), 
        .cout(c33) 
    ); 
 
    //------------------------------------------------ 
    // Column 4 
    //------------------------------------------------ 
    full_adder FA41 ( 

        .a(p13), 
        .b(p22), 
        .cin(p31), 
        .sum(s41), 
        .cout(c41) 
    ); 
 
    full_adder FA42 ( 
        .a(s41), 
        .b(c31), 
        .cin(c32), 
        .sum(s42), 
        .cout(c42) 
    ); 
 
    full_adder FA43 ( 
        .a(s42), 
        .b(c33), 
        .cin(1'b0), 
        .sum(product[4]), 
        .cout(c43) 
    ); 
 
    //------------------------------------------------ 
    // Column 5 
    //------------------------------------------------ 

    full_adder FA51 ( 
        .a(p23), 
        .b(p32), 
        .cin(c41), 
        .sum(s43), 
        .cout(s34) 
    ); 
 
    full_adder FA52 ( 
        .a(s43), 
        .b(c42), 
        .cin(c43), 
        .sum(product[5]), 
        .cout(c34) 
    ); 
 
    //------------------------------------------------ 
    // Column 6 
    //------------------------------------------------ 
    full_adder FA61 ( 
        .a(p33), 
        .b(s34), 
        .cin(c34), 
        .sum(product[6]), 
        .cout(product[7]) 
    ); 

 
endmodule