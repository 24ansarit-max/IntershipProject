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
 

 
module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    /* Partial Products */ 
    wire pp00, pp01, pp02, pp03; 
    wire pp10, pp11, pp12, pp13; 
    wire pp20, pp21, pp22, pp23; 
    wire pp30, pp31, pp32, pp33; 
 
    /* Intermediate Sums */ 
    wire s1, s2, s3, s4, s5, s6, s7, s8; 
 
    /* Intermediate Carries */ 
    wire c1, c2, c3, c4, c5, c6, c7, c8; 
 
    /* Partial Product Generation */ 
    and_gate g00(a[0], b[0], pp00); 
    and_gate g01(a[0], b[1], pp01); 
    and_gate g02(a[0], b[2], pp02); 
    and_gate g03(a[0], b[3], pp03); 
 
    and_gate g10(a[1], b[0], pp10); 

    and_gate g11(a[1], b[1], pp11); 
    and_gate g12(a[1], b[2], pp12); 
    and_gate g13(a[1], b[3], pp13); 
 
    and_gate g20(a[2], b[0], pp20); 
    and_gate g21(a[2], b[1], pp21); 
    and_gate g22(a[2], b[2], pp22); 
    and_gate g23(a[2], b[3], pp23); 
 
    and_gate g30(a[3], b[0], pp30); 
    and_gate g31(a[3], b[1], pp31); 
    and_gate g32(a[3], b[2], pp32); 
    and_gate g33(a[3], b[3], pp33); 
 
    /* Product Bit 0 */ 
    assign product[0] = pp00; 
 
    /* Column 1 */ 
    half_adder HA1( 
        pp01, 
        pp10, 
        product[1], 
        c1 
    ); 
 
    /* Column 2 */ 

    full_adder FA1( 
        pp02, 
        pp11, 
        pp20, 
        s1, 
        c2 
    ); 
 
    half_adder HA2( 
        s1, 
        c1, 
        product[2], 
        c3 
    ); 
 
    /* Column 3 */ 
    full_adder FA2( 
        pp03, 
        pp12, 
        pp21, 
        s2, 
        c4 
    ); 
 
    full_adder FA3( 
        s2, 

        pp30, 
        c2, 
        s3, 
        c5 
    ); 
 
    full_adder FA4( 
        s3, 
        c3, 
        1'b0, 
        product[3], 
        c6 
    ); 
 
    /* Column 4 */ 
    full_adder FA5( 
        pp13, 
        pp22, 
        pp31, 
        s4, 
        c7 
    ); 
 
    full_adder FA6( 
        s4, 
        c4, 

        c5, 
        s5, 
        c8 
    ); 
 
    half_adder HA3( 
        s5, 
        c6, 
        product[4], 
        s6 
    ); 
 
    /* Column 5 */ 
    full_adder FA7( 
        pp23, 
        pp32, 
        c7, 
        s7, 
        s8 
    ); 
 
    full_adder FA8( 
        s7, 
        c8, 
        s6, 
        product[5], 

        c1 
    ); 
 
    /* Column 6 */ 
    half_adder HA4( 
        pp33, 
        s8, 
        product[6], 
        c2 
    ); 
 
    /* Product Bit 7 */ 
    assign product[7] = c2; 
 
endmodule