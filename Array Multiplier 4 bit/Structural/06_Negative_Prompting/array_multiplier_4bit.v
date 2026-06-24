//------------------------- 
// 2-Input AND Gate 
//------------------------- 
module and_gate( 
    input  a, 
    input  b, 
    output y 
); 
    assign y = a & b; 
endmodule 
 
//------------------------- 
// Half Adder 
//------------------------- 
module half_adder( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    assign sum   = a ^ b; 
    assign carry = a & b; 
endmodule 
 
//------------------------- 
// Full Adder 

//------------------------- 
module full_adder( 
    input  a, 
    input  b, 
    input  cin, 
    output sum, 
    output carry 
); 
    wire s1; 
    wire c1; 
    wire c2; 
 
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
 

    assign carry = c1 | c2; 
endmodule 
 
//------------------------- 
// 4-Bit Array Multiplier 
//------------------------- 
module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Partial Products 
    wire pp00, pp01, pp02, pp03; 
    wire pp10, pp11, pp12, pp13; 
    wire pp20, pp21, pp22, pp23; 
    wire pp30, pp31, pp32, pp33; 
 
    // Internal Sum Wires 
    wire s11, s12, s13; 
    wire s21, s22, s23, s24; 
    wire s31, s32, s33, s34; 
 
    // Internal Carry Wires 
    wire c11, c12, c13; 
    wire c21, c22, c23, c24; 

    wire c31, c32, c33, c34; 
 
    //------------------------- 
    // Partial Product Generation 
    //------------------------- 
    and_gate G00 (.a(a[0]), .b(b[0]), .y(pp00)); 
    and_gate G01 (.a(a[1]), .b(b[0]), .y(pp01)); 
    and_gate G02 (.a(a[2]), .b(b[0]), .y(pp02)); 
    and_gate G03 (.a(a[3]), .b(b[0]), .y(pp03)); 
 
    and_gate G10 (.a(a[0]), .b(b[1]), .y(pp10)); 
    and_gate G11 (.a(a[1]), .b(b[1]), .y(pp11)); 
    and_gate G12 (.a(a[2]), .b(b[1]), .y(pp12)); 
    and_gate G13 (.a(a[3]), .b(b[1]), .y(pp13)); 
 
    and_gate G20 (.a(a[0]), .b(b[2]), .y(pp20)); 
    and_gate G21 (.a(a[1]), .b(b[2]), .y(pp21)); 
    and_gate G22 (.a(a[2]), .b(b[2]), .y(pp22)); 
    and_gate G23 (.a(a[3]), .b(b[2]), .y(pp23)); 
 
    and_gate G30 (.a(a[0]), .b(b[3]), .y(pp30)); 
    and_gate G31 (.a(a[1]), .b(b[3]), .y(pp31)); 
    and_gate G32 (.a(a[2]), .b(b[3]), .y(pp32)); 
    and_gate G33 (.a(a[3]), .b(b[3]), .y(pp33)); 
 
    //------------------------- 

    // Product[0] 
    //------------------------- 
    assign product[0] = pp00; 
 
    //------------------------- 
    // Column 1 
    //------------------------- 
    half_adder HA1 ( 
        .a(pp01), 
        .b(pp10), 
        .sum(product[1]), 
        .carry(c11) 
    ); 
 
    //------------------------- 
    // Column 2 
    //------------------------- 
    full_adder FA21 ( 
        .a(pp02), 
        .b(pp11), 
        .cin(pp20), 
        .sum(s11), 
        .carry(c12) 
    ); 
 
    half_adder HA2 ( 

        .a(s11), 
        .b(c11), 
        .sum(product[2]), 
        .carry(c13) 
    ); 
 
    //------------------------- 
    // Column 3 
    //------------------------- 
    full_adder FA31 ( 
        .a(pp03), 
        .b(pp12), 
        .cin(pp21), 
        .sum(s21), 
        .carry(c21) 
    ); 
 
    full_adder FA32 ( 
        .a(s21), 
        .b(pp30), 
        .cin(c12), 
        .sum(s22), 
        .carry(c22) 
    ); 
 
    half_adder HA3 ( 

        .a(s22), 
        .b(c13), 
        .sum(product[3]), 
        .carry(c23) 
    ); 
 
    //------------------------- 
    // Column 4 
    //------------------------- 
    full_adder FA41 ( 
        .a(pp13), 
        .b(pp22), 
        .cin(pp31), 
        .sum(s31), 
        .carry(c31) 
    ); 
 
    full_adder FA42 ( 
        .a(s31), 
        .b(c21), 
        .cin(c22), 
        .sum(s32), 
        .carry(c32) 
    ); 
 
    full_adder FA43 ( 

        .a(s32), 
        .b(c23), 
        .cin(pp23), 
        .sum(product[4]), 
        .carry(c33) 
    ); 
 
    //------------------------- 
    // Column 5 
    //------------------------- 
    full_adder FA51 ( 
        .a(pp32), 
        .b(c31), 
        .cin(c32), 
        .sum(s33), 
        .carry(c34) 
    ); 
 
    full_adder FA52 ( 
        .a(s33), 
        .b(c33), 
        .cin(pp33), 
        .sum(product[5]), 
        .carry(s34) 
    ); 
 

    //------------------------- 
    // Column 6 
    //------------------------- 
    half_adder HA4 ( 
        .a(c34), 
        .b(s34), 
        .sum(product[6]), 
        .carry(product[7]) 
    ); 
 
endmodule