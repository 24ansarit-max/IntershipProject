module and_gate( 
    input  a, 
    input  b, 
    output y 
); 

    and (y, a, b); 
endmodule 
 
 
module half_adder( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    xor (sum, a, b); 
    and (carry, a, b); 
endmodule 
 
 
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
 

    xor (s1, a, b); 
    xor (sum, s1, cin); 
 
    and (c1, a, b); 
    and (c2, s1, cin); 
    or  (cout, c1, c2); 
endmodule 
 
 
module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    /* Partial products */ 
    wire pp00, pp01, pp02, pp03; 
    wire pp10, pp11, pp12, pp13; 
    wire pp20, pp21, pp22, pp23; 
    wire pp30, pp31, pp32, pp33; 
 
    /* Column reduction wires */ 
    wire c1; 
 
    wire s2a; 
    wire c2a; 

    wire c2b; 
 
    wire s3a; 
    wire c3a; 
    wire s3b; 
    wire c3b; 
    wire c3c; 
 
    wire s4a; 
    wire c4a; 
    wire s4b; 
    wire c4b; 
    wire s4c; 
    wire c4c; 
 
    wire s5a; 
    wire c5a; 
    wire s5b; 
    wire c5b; 
    wire c5c; 
 
    wire s6a; 
    wire c6a;​
    wire c6b; 
 
    /* Row 0 partial products (b[0]) */ 
    and_gate pp_00 (.a(a[0]), .b(b[0]), .y(pp00)); 

    and_gate pp_10 (.a(a[1]), .b(b[0]), .y(pp10)); 
    and_gate pp_20 (.a(a[2]), .b(b[0]), .y(pp20)); 
    and_gate pp_30 (.a(a[3]), .b(b[0]), .y(pp30)); 
 
    /* Row 1 partial products (b[1]) */ 
    and_gate pp_01 (.a(a[0]), .b(b[1]), .y(pp01)); 
    and_gate pp_11 (.a(a[1]), .b(b[1]), .y(pp11)); 
    and_gate pp_21 (.a(a[2]), .b(b[1]), .y(pp21)); 
    and_gate pp_31 (.a(a[3]), .b(b[1]), .y(pp31)); 
 
    /* Row 2 partial products (b[2]) */ 
    and_gate pp_02 (.a(a[0]), .b(b[2]), .y(pp02)); 
    and_gate pp_12 (.a(a[1]), .b(b[2]), .y(pp12)); 
    and_gate pp_22 (.a(a[2]), .b(b[2]), .y(pp22)); 
    and_gate pp_32 (.a(a[3]), .b(b[2]), .y(pp32)); 
 
    /* Row 3 partial products (b[3]) */ 
    and_gate pp_03 (.a(a[0]), .b(b[3]), .y(pp03)); 
    and_gate pp_13 (.a(a[1]), .b(b[3]), .y(pp13)); 
    and_gate pp_23 (.a(a[2]), .b(b[3]), .y(pp23)); 
    and_gate pp_33 (.a(a[3]), .b(b[3]), .y(pp33)); 
 
    /* Product bit 0 */ 
    buf (product[0], pp00); 
 
    /* Column 1 */ 

    half_adder HA_COL1 ( 
        .a(pp10), 
        .b(pp01), 
        .sum(product[1]), 
        .carry(c1) 
    ); 
 
    /* Column 2 */ 
    full_adder FA_COL2_A ( 
        .a(pp20), 
        .b(pp11), 
        .cin(pp02), 
        .sum(s2a), 
        .cout(c2a) 
    ); 
 
    half_adder HA_COL2_B ( 
        .a(s2a), 
        .b(c1), 
        .sum(product[2]), 
        .carry(c2b) 
    ); 
 
    /* Column 3 */ 
    full_adder FA_COL3_A ( 
        .a(pp30), 

        .b(pp21), 
        .cin(pp12), 
        .sum(s3a), 
        .cout(c3a) 
    ); 
 
    full_adder FA_COL3_B ( 
        .a(s3a), 
        .b(pp03), 
        .cin(c2a), 
        .sum(s3b), 
        .cout(c3b) 
    ); 
 
    half_adder HA_COL3_C ( 
        .a(s3b), 
        .b(c2b), 
        .sum(product[3]), 
        .carry(c3c) 
    ); 
 
    /* Column 4 */ 
    full_adder FA_COL4_A ( 
        .a(pp31), 
        .b(pp22), 
        .cin(pp13), 

        .sum(s4a), 
        .cout(c4a) 
    ); 
 
    full_adder FA_COL4_B ( 
        .a(s4a), 
        .b(c3a), 
        .cin(c3b), 
        .sum(s4b), 
        .cout(c4b) 
    ); 
 
    half_adder HA_COL4_C ( 
        .a(s4b), 
        .b(c3c), 
        .sum(product[4]), 
        .carry(c4c) 
    ); 
 
    /* Column 5 */ 
    full_adder FA_COL5_A ( 
        .a(pp32), 
        .b(pp23), 
        .cin(c4a), 
        .sum(s5a), 
        .cout(c5a) 

    ); 
 
    full_adder FA_COL5_B ( 
        .a(s5a), 
        .b(c4b), 
        .cin(c4c), 
        .sum(s5b), 
        .cout(c5b) 
    ); 
 
    half_adder HA_COL5_C ( 
        .a(s5b), 
        .b(1'b0), 
        .sum(product[5]), 
        .carry(c5c) 
    ); 
 
    /* Column 6 */ 
    full_adder FA_COL6_A ( 
        .a(pp33), 
        .b(c5a), 
        .cin(c5b), 
        .sum(s6a), 
        .cout(c6a) 
    ); 
 

    half_adder HA_COL6_B ( 
        .a(s6a), 
        .b(c5c), 
        .sum(product[6]), 
        .carry(c6b) 
    ); 
 
    /* Product bit 7 */ 
    or (product[7], c6a, c6b); 
 
endmodule