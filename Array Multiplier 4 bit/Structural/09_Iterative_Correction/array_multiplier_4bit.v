module and_gate( 
    input  a, 
    input  b, 
    output y 
); 
    and g1(y, a, b); 
endmodule 
 
module half_adder( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
    xor x1(sum, a, b); 
    and a1(carry, a, b); 
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
 
    half_adder ha1( 
        .a(a), 
        .b(b), 
        .sum(s1), 
        .carry(c1) 
    ); 
 
    half_adder ha2( 
        .a(s1), 
        .b(cin), 
        .sum(sum), 
        .carry(c2) 
    ); 
 
    or o1(cout, c1, c2); 
endmodule 
 
module array_multiplier_4bit( 

    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    /* Partial Products */ 
    wire pp_0_0, pp_0_1, pp_0_2, pp_0_3; 
    wire pp_1_0, pp_1_1, pp_1_2, pp_1_3; 
    wire pp_2_0, pp_2_1, pp_2_2, pp_2_3; 
    wire pp_3_0, pp_3_1, pp_3_2, pp_3_3; 
 
    /* Product wires */ 
    wire p0, p1, p2, p3, p4, p5, p6, p7; 
 
    /* Column 1 */ 
    wire c_col1; 
 
    /* Column 2 */ 
    wire s_col2_a; 
    wire c_col2_a; 
    wire c_col2_b; 
 
    /* Column 3 */ 
    wire s_col3_a; 
    wire c_col3_a; 
    wire s_col3_b; 

    wire c_col3_b; 
    wire c_col3_c; 
 
    /* Column 4 */ 
    wire s_col4_a; 
    wire c_col4_a; 
    wire s_col4_b; 
    wire c_col4_b; 
    wire s_col4_c; 
    wire c_col4_c; 
    wire c_col4_d; 
 
    /* Column 5 */ 
    wire s_col5_a; 
    wire c_col5_a; 
    wire s_col5_b; 
    wire c_col5_b; 
    wire s_col5_c; 
    wire c_col5_c; 
 
    /* Column 6 */ 
    wire s_col6_a; 
    wire c_col6_a; 
    wire s_col6_b; 
    wire c_col6_b; 
 

    /* Output buffer wires */ 
    wire product_0_wire; 
    wire product_1_wire; 
    wire product_2_wire; 
    wire product_3_wire; 
    wire product_4_wire; 
    wire product_5_wire; 
    wire product_6_wire; 
    wire product_7_wire; 
 
    /* 16 Partial Product AND Gates */ 
    and_gate pp_inst_0_0(.a(a[0]), .b(b[0]), .y(pp_0_0)); 
    and_gate pp_inst_0_1(.a(a[0]), .b(b[1]), .y(pp_0_1)); 
    and_gate pp_inst_0_2(.a(a[0]), .b(b[2]), .y(pp_0_2)); 
    and_gate pp_inst_0_3(.a(a[0]), .b(b[3]), .y(pp_0_3)); 
 
    and_gate pp_inst_1_0(.a(a[1]), .b(b[0]), .y(pp_1_0)); 
    and_gate pp_inst_1_1(.a(a[1]), .b(b[1]), .y(pp_1_1)); 
    and_gate pp_inst_1_2(.a(a[1]), .b(b[2]), .y(pp_1_2)); 
    and_gate pp_inst_1_3(.a(a[1]), .b(b[3]), .y(pp_1_3)); 
 
    and_gate pp_inst_2_0(.a(a[2]), .b(b[0]), .y(pp_2_0)); 
    and_gate pp_inst_2_1(.a(a[2]), .b(b[1]), .y(pp_2_1)); 
    and_gate pp_inst_2_2(.a(a[2]), .b(b[2]), .y(pp_2_2)); 
    and_gate pp_inst_2_3(.a(a[2]), .b(b[3]), .y(pp_2_3)); 
 

    and_gate pp_inst_3_0(.a(a[3]), .b(b[0]), .y(pp_3_0)); 
    and_gate pp_inst_3_1(.a(a[3]), .b(b[1]), .y(pp_3_1)); 
    and_gate pp_inst_3_2(.a(a[3]), .b(b[2]), .y(pp_3_2)); 
    and_gate pp_inst_3_3(.a(a[3]), .b(b[3]), .y(pp_3_3)); 
 
    /* Product[0] */ 
    buf product0_buf(product_0_wire, pp_0_0); 
 
    /* Column 1 -> Product[1] */ 
    half_adder ha_col1( 
        .a(pp_1_0), 
        .b(pp_0_1), 
        .sum(product_1_wire), 
        .carry(c_col1) 
    ); 
 
    /* Column 2 -> Product[2] */ 
    full_adder fa_col2_a( 
        .a(pp_2_0), 
        .b(pp_1_1), 
        .cin(pp_0_2), 
        .sum(s_col2_a), 
        .cout(c_col2_a) 
    ); 
 
    half_adder ha_col2_b( 

        .a(s_col2_a), 
        .b(c_col1), 
        .sum(product_2_wire), 
        .carry(c_col2_b) 
    ); 
 
    /* Column 3 -> Product[3] */ 
    full_adder fa_col3_a( 
        .a(pp_3_0), 
        .b(pp_2_1), 
        .cin(pp_1_2), 
        .sum(s_col3_a), 
        .cout(c_col3_a) 
    ); 
 
    full_adder fa_col3_b( 
        .a(s_col3_a), 
        .b(pp_0_3), 
        .cin(c_col2_a), 
        .sum(s_col3_b), 
        .cout(c_col3_b) 
    ); 
 
    half_adder ha_col3_c( 
        .a(s_col3_b), 
        .b(c_col2_b), 

        .sum(product_3_wire), 
        .carry(c_col3_c) 
    ); 
 
    /* Column 4 -> Product[4] */ 
    full_adder fa_col4_a( 
        .a(pp_3_1), 
        .b(pp_2_2), 
        .cin(pp_1_3), 
        .sum(s_col4_a), 
        .cout(c_col4_a) 
    ); 
 
    full_adder fa_col4_b( 
        .a(s_col4_a), 
        .b(c_col3_a), 
        .cin(c_col3_b), 
        .sum(s_col4_b), 
        .cout(c_col4_b) 
    ); 
 
    full_adder fa_col4_c( 
        .a(s_col4_b), 
        .b(c_col3_c), 
        .cin(1'b0), 
        .sum(s_col4_c), 

        .cout(c_col4_c) 
    ); 
 
    half_adder ha_col4_d( 
        .a(s_col4_c), 
        .b(1'b0), 
        .sum(product_4_wire), 
        .carry(c_col4_d) 
    ); 
 
    /* Column 5 -> Product[5] */ 
    full_adder fa_col5_a( 
        .a(pp_3_2), 
        .b(pp_2_3), 
        .cin(c_col4_a), 
        .sum(s_col5_a), 
        .cout(c_col5_a) 
    ); 
 
    full_adder fa_col5_b( 
        .a(s_col5_a), 
        .b(c_col4_b), 
        .cin(c_col4_c), 
        .sum(s_col5_b), 
        .cout(c_col5_b) 
    ); 

 
    full_adder fa_col5_c( 
        .a(s_col5_b), 
        .b(c_col4_d), 
        .cin(1'b0), 
        .sum(product_5_wire), 
        .cout(c_col5_c) 
    ); 
 
    /* Column 6 -> Product[6] */ 
    full_adder fa_col6_a( 
        .a(pp_3_3), 
        .b(c_col5_a), 
        .cin(c_col5_b), 
        .sum(s_col6_a), 
        .cout(c_col6_a) 
    ); 
 
    full_adder fa_col6_b( 
        .a(s_col6_a), 
        .b(c_col5_c), 
        .cin(1'b0), 
        .sum(product_6_wire), 
        .cout(c_col6_b) 
    ); 
 

    /* Column 7 -> Product[7] */ 
    half_adder ha_col7( 
        .a(c_col6_a), 
        .b(c_col6_b), 
        .sum(product_7_wire), 
        .carry(c_col6_a)   // unused extra carry in 4x4 multiplication range 
    ); 
 
    /* Output Connections (gate-level wire ties) */ 
    buf product_buf0(product[0], product_0_wire); 
    buf product_buf1(product[1], product_1_wire); 
    buf product_buf2(product[2], product_2_wire); 
    buf product_buf3(product[3], product_3_wire); 
    buf product_buf4(product[4], product_4_wire); 
    buf product_buf5(product[5], product_5_wire); 
    buf product_buf6(product[6], product_6_wire); 
    buf product_buf7(product[7], product_7_wire); 
 
endmodule