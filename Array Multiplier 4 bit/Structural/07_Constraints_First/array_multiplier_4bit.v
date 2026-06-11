//==================================================== 
// Basic Gates 
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
    output carry 
); 
    assign sum   = a ^ b ^ cin; 
    assign carry = (a & b) | (a & cin) | (b & cin); 
endmodule 
 
 
//==================================================== 
// 4-bit Array Multiplier 
//==================================================== 
module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    //------------------------------------------------ 
    // Partial Products 
    //------------------------------------------------ 
    wire p00,p01,p02,p03; 
    wire p10,p11,p12,p13; 
    wire p20,p21,p22,p23; 
    wire p30,p31,p32,p33; 

 
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
    // Internal Signals 
    //------------------------------------------------ 
    wire s1,c1; 
    wire s2,c2a,c2b; 

    wire s3,c3a,c3b,c3c; 
    wire s4,c4a,c4b,c4c; 
    wire s5,c5a,c5b; 
    wire s6,c6; 
 
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
        .sum(s1), 
        .carry(c1) 
    ); 
 
    assign product[1] = s1; 
 
    //------------------------------------------------ 
    // Column 2 
    //------------------------------------------------ 
    full_adder FA2_1 ( 

        .a(p02), 
        .b(p11), 
        .cin(p20), 
        .sum(s2), 
        .carry(c2a) 
    ); 
 
    half_adder HA2 ( 
        .a(s2), 
        .b(c1), 
        .sum(product[2]), 
        .carry(c2b) 
    ); 
 
    //------------------------------------------------ 
    // Column 3 
    //------------------------------------------------ 
    full_adder FA3_1 ( 
        .a(p03), 
        .b(p12), 
        .cin(p21), 
        .sum(s3), 
        .carry(c3a) 
    ); 
 
    full_adder FA3_2 ( 

        .a(s3), 
        .b(p30), 
        .cin(c2a), 
        .sum(s4), 
        .carry(c3b) 
    ); 
 
    half_adder HA3 ( 
        .a(s4), 
        .b(c2b), 
        .sum(product[3]), 
        .carry(c3c) 
    ); 
 
    //------------------------------------------------ 
    // Column 4 
    //------------------------------------------------ 
    full_adder FA4_1 ( 
        .a(p13), 
        .b(p22), 
        .cin(p31), 
        .sum(s5), 
        .carry(c4a) 
    ); 
 
    full_adder FA4_2 ( 

        .a(s5), 
        .b(c3a), 
        .cin(c3b), 
        .sum(s6), 
        .carry(c4b) 
    ); 
 
    half_adder HA4 ( 
        .a(s6), 
        .b(c3c), 
        .sum(product[4]), 
        .carry(c4c) 
    ); 
 
    //------------------------------------------------ 
    // Column 5 
    //------------------------------------------------ 
    full_adder FA5_1 ( 
        .a(p23), 
        .b(p32), 
        .cin(c4a), 
        .sum(product[5]), 
        .carry(c5a) 
    ); 
 
    full_adder FA5_2 ( 

        .a(c4b), 
        .b(c4c), 
        .cin(c5a), 
        .sum(s3), 
        .carry(c5b) 
    ); 
 
    //------------------------------------------------ 
    // Column 6 
    //------------------------------------------------ 
    half_adder HA5 ( 
        .a(p33), 
        .b(s3), 
        .sum(product[6]), 
        .carry(c6) 
    ); 
 
    //------------------------------------------------ 
    // Column 7 
    //------------------------------------------------ 
    half_adder HA6 ( 
        .a(c6), 
        .b(c5b), 
        .sum(product[7]), 
        .carry() 
    ); 

 
endmodule