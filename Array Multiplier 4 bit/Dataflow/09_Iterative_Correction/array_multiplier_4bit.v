module half_adder ( 
    input  a, 
    input  b, 
    output sum, 
    output carry 
); 
 
assign sum   = a ^ b; 
assign carry = a & b; 
 
endmodule 
 
 

module full_adder ( 
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
assign c1   = a & b; 
 
assign sum  = s1 ^ cin; 
assign c2   = s1 & cin; 
 
assign cout = c1 | c2; 
 
endmodule 
 
 
module array_multiplier_4bit ( 

    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Partial products 
    wire pp_0_0, pp_0_1, pp_0_2, pp_0_3; 
    wire pp_1_0, pp_1_1, pp_1_2, pp_1_3; 
    wire pp_2_0, pp_2_1, pp_2_2, pp_2_3; 
    wire pp_3_0, pp_3_1, pp_3_2, pp_3_3; 
 
    assign pp_0_0 = a[0] & b[0]; 
    assign pp_0_1 = a[0] & b[1]; 
    assign pp_0_2 = a[0] & b[2]; 
    assign pp_0_3 = a[0] & b[3]; 
 
    assign pp_1_0 = a[1] & b[0]; 
    assign pp_1_1 = a[1] & b[1]; 
    assign pp_1_2 = a[1] & b[2]; 
    assign pp_1_3 = a[1] & b[3]; 
 
    assign pp_2_0 = a[2] & b[0]; 
    assign pp_2_1 = a[2] & b[1]; 
    assign pp_2_2 = a[2] & b[2]; 

    assign pp_2_3 = a[2] & b[3]; 
 
    assign pp_3_0 = a[3] & b[0]; 
    assign pp_3_1 = a[3] & b[1]; 
    assign pp_3_2 = a[3] & b[2]; 
    assign pp_3_3 = a[3] & b[3]; 
 
    // Intermediate sums and carries 
    wire s_row1_col1; 
    wire c_row1_col1; 
 
    wire s_row1_col2; 
    wire c_row1_col2; 
    wire s_row1_col2_b; 
    wire c_row1_col2_b; 
 
    wire s_row1_col3; 
    wire c_row1_col3; 
    wire s_row1_col3_b; 
    wire c_row1_col3_b; 
 
    wire s_row1_col4; 
    wire c_row1_col4; 
 

    wire s_row2_col2; 
    wire c_row2_col2; 
 
    wire s_row2_col3; 
    wire c_row2_col3; 
    wire s_row2_col3_b; 
    wire c_row2_col3_b; 
 
    wire s_row2_col4; 
    wire c_row2_col4; 
    wire s_row2_col4_b; 
    wire c_row2_col4_b; 
 
    wire s_row2_col5; 
    wire c_row2_col5; 
 
    wire s_row3_col3; 
    wire c_row3_col3; 
 
    wire s_row3_col4; 
    wire c_row3_col4; 
    wire s_row3_col4_b; 
    wire c_row3_col4_b; 
 

    wire s_row3_col5; 
    wire c_row3_col5; 
    wire s_row3_col5_b; 
    wire c_row3_col5_b; 
 
    wire s_row3_col6; 
    wire c_row3_col6; 
 
    // Product bit 0 
    assign product[0] = pp_0_0; 
 
    // Column 1 
    half_adder HA1 ( 
        .a(pp_0_1), 
        .b(pp_1_0), 
        .sum(s_row1_col1), 
        .carry(c_row1_col1) 
    ); 
 
    assign product[1] = s_row1_col1; 
 
    // Column 2 
    full_adder FA1 ( 
        .a(pp_0_2), 

        .b(pp_1_1), 
        .cin(pp_2_0), 
        .sum(s_row1_col2), 
        .cout(c_row1_col2) 
    ); 
 
    half_adder HA2 ( 
        .a(s_row1_col2), 
        .b(c_row1_col1), 
        .sum(s_row2_col2), 
        .carry(c_row2_col2) 
    ); 
 
    assign product[2] = s_row2_col2; 
 
    // Column 3 
    full_adder FA2 ( 
        .a(pp_0_3), 
        .b(pp_1_2), 
        .cin(pp_2_1), 
        .sum(s_row1_col3), 
        .cout(c_row1_col3) 
    ); 
 

    half_adder HA3 ( 
        .a(s_row1_col3), 
        .b(pp_3_0), 
        .sum(s_row1_col3_b), 
        .carry(c_row1_col3_b) 
    ); 
 
    full_adder FA3 ( 
        .a(s_row1_col3_b), 
        .b(c_row1_col2), 
        .cin(c_row2_col2), 
        .sum(s_row3_col3), 
        .cout(c_row3_col3) 
    ); 
 
    assign product[3] = s_row3_col3; 
 
    // Column 4 
    full_adder FA4 ( 
        .a(pp_1_3), 
        .b(pp_2_2), 
        .cin(pp_3_1), 
        .sum(s_row1_col4), 
        .cout(c_row1_col4) 

    ); 
 
    full_adder FA5 ( 
        .a(s_row1_col4), 
        .b(c_row1_col3), 
        .cin(c_row1_col3_b), 
        .sum(s_row2_col4), 
        .cout(c_row2_col4) 
    ); 
 
    half_adder HA4 ( 
        .a(s_row2_col4), 
        .b(c_row3_col3), 
        .sum(s_row3_col4), 
        .carry(c_row3_col4) 
    ); 
 
    assign product[4] = s_row3_col4; 
 
    // Column 5 
    full_adder FA6 ( 
        .a(pp_2_3), 
        .b(pp_3_2), 
        .cin(c_row1_col4), 

        .sum(s_row2_col5), 
        .cout(c_row2_col5) 
    ); 
 
    full_adder FA7 ( 
        .a(s_row2_col5), 
        .b(c_row2_col4), 
        .cin(c_row3_col4), 
        .sum(s_row3_col5), 
        .cout(c_row3_col5) 
    ); 
 
    assign product[5] = s_row3_col5; 
 
    // Column 6 
    full_adder FA8 ( 
        .a(pp_3_3), 
        .b(c_row2_col5), 
        .cin(c_row3_col5), 
        .sum(s_row3_col6), 
        .cout(c_row3_col6) 
    ); 
 
    assign product[6] = s_row3_col6; 

    assign product[7] = c_row3_col6; 
 
endmodule