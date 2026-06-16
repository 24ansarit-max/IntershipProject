module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Partial products 
    wire pp00, pp01, pp02, pp03; 
    wire pp10, pp11, pp12, pp13; 
    wire pp20, pp21, pp22, pp23; 
    wire pp30, pp31, pp32, pp33; 
 
    // Stage wires 
    wire s1, c1; 
 
    wire s2a, c2a; 
    wire s2,  c2; 
 
    wire s3a, c3a; 

    wire s3b, c3b; 
    wire s3,  c3; 
 
    wire s4a, c4a; 
    wire s4b, c4b; 
    wire s4,  c4; 
 
    wire s5a, c5a; 
    wire s5,  c5; 
 
    wire s6, c6; 
 
    // --------------------------------------------------------- 
    // Partial Product Generation (16 AND gates) 
    // --------------------------------------------------------- 
 
    and_gate g00(a[0], b[0], pp00); 
    and_gate g01(a[1], b[0], pp01); 
    and_gate g02(a[2], b[0], pp02); 
    and_gate g03(a[3], b[0], pp03); 
 
    and_gate g10(a[0], b[1], pp10); 
    and_gate g11(a[1], b[1], pp11); 
    and_gate g12(a[2], b[1], pp12); 
    and_gate g13(a[3], b[1], pp13); 
 

    and_gate g20(a[0], b[2], pp20); 
    and_gate g21(a[1], b[2], pp21); 
    and_gate g22(a[2], b[2], pp22); 
    and_gate g23(a[3], b[2], pp23); 
 
    and_gate g30(a[0], b[3], pp30); 
    and_gate g31(a[1], b[3], pp31); 
    and_gate g32(a[2], b[3], pp32); 
    and_gate g33(a[3], b[3], pp33); 
 
    // --------------------------------------------------------- 
    // Column 0 
    // --------------------------------------------------------- 
 
    assign product[0] = pp00; 
 
    // --------------------------------------------------------- 
    // Column 1 
    // --------------------------------------------------------- 
 
    half_adder HA1( 
        pp01, 
        pp10, 
        product[1], 
        c1 
    ); 

 
    // --------------------------------------------------------- 
    // Column 2 
    // --------------------------------------------------------- 
 
    full_adder FA2A( 
        pp02, 
        pp11, 
        pp20, 
        s2a, 
        c2a 
    ); 
 
    half_adder HA2( 
        s2a, 
        c1, 
        product[2], 
        c2 
    ); 
 
    // --------------------------------------------------------- 
    // Column 3 
    // --------------------------------------------------------- 
 
    full_adder FA3A( 
        pp03, 

        pp12, 
        pp21, 
        s3a, 
        c3a 
    ); 
 
    full_adder FA3B( 
        s3a, 
        pp30, 
        c2, 
        s3b, 
        c3b 
    ); 
 
    half_adder HA3( 
        s3b, 
        c2a, 
        product[3], 
        c3 
    ); 
 
    // --------------------------------------------------------- 
    // Column 4 
    // --------------------------------------------------------- 
 
    full_adder FA4A( 

        pp13, 
        pp22, 
        pp31, 
        s4a, 
        c4a 
    ); 
 
    full_adder FA4B( 
        s4a, 
        c3, 
        c3a, 
        s4b, 
        c4b 
    ); 
 
    half_adder HA4( 
        s4b, 
        c3b, 
        product[4], 
        c4 
    ); 
 
    // --------------------------------------------------------- 
    // Column 5 
    // --------------------------------------------------------- 
 

    full_adder FA5A( 
        pp23, 
        pp32, 
        c4, 
        s5a, 
        c5a 
    ); 
 
    half_adder HA5( 
        s5a, 
        c4a, 
        s5, 
        c5 
    ); 
 
    half_adder HA5B( 
        s5, 
        c4b, 
        product[5], 
        s6 
    ); 
 
    // --------------------------------------------------------- 
    // Column 6 
    // --------------------------------------------------------- 
 

    full_adder FA6( 
        pp33, 
        c5, 
        c5a, 
        product[6], 
        c6 
    ); 
 
    // --------------------------------------------------------- 
    // Column 7 
    // --------------------------------------------------------- 
 
    assign product[7] = c6; 
 
endmodule