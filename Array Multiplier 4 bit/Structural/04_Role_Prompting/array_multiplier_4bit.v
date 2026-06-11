//==================================================== 
// 2-Input AND Gate 
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
    wire xor_ab; 
    wire and_ab; 
    wire and_xor_cin; 
 
    assign xor_ab      = a ^ b; 
    assign sum         = xor_ab ^ cin; 
    assign and_ab      = a & b; 
    assign and_xor_cin = xor_ab & cin; 
    assign cout        = and_ab | and_xor_cin; 
endmodule 
 
//==================================================== 

// 4-Bit Array Multiplier (Structural) 
//==================================================== 
module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    //================================================ 
    // Partial Products 
    //================================================ 
    wire pp_0_0, pp_0_1, pp_0_2, pp_0_3; 
    wire pp_1_0, pp_1_1, pp_1_2, pp_1_3; 
    wire pp_2_0, pp_2_1, pp_2_2, pp_2_3; 
    wire pp_3_0, pp_3_1, pp_3_2, pp_3_3; 
 
    and_gate and_00 (.a(a[0]), .b(b[0]), .y(pp_0_0)); 
    and_gate and_01 (.a(a[0]), .b(b[1]), .y(pp_0_1)); 
    and_gate and_02 (.a(a[0]), .b(b[2]), .y(pp_0_2)); 
    and_gate and_03 (.a(a[0]), .b(b[3]), .y(pp_0_3)); 
 
    and_gate and_10 (.a(a[1]), .b(b[0]), .y(pp_1_0)); 
    and_gate and_11 (.a(a[1]), .b(b[1]), .y(pp_1_1)); 
    and_gate and_12 (.a(a[1]), .b(b[2]), .y(pp_1_2)); 
    and_gate and_13 (.a(a[1]), .b(b[3]), .y(pp_1_3)); 
 

    and_gate and_20 (.a(a[2]), .b(b[0]), .y(pp_2_0)); 
    and_gate and_21 (.a(a[2]), .b(b[1]), .y(pp_2_1)); 
    and_gate and_22 (.a(a[2]), .b(b[2]), .y(pp_2_2)); 
    and_gate and_23 (.a(a[2]), .b(b[3]), .y(pp_2_3)); 
 
    and_gate and_30 (.a(a[3]), .b(b[0]), .y(pp_3_0)); 
    and_gate and_31 (.a(a[3]), .b(b[1]), .y(pp_3_1)); 
    and_gate and_32 (.a(a[3]), .b(b[2]), .y(pp_3_2)); 
    and_gate and_33 (.a(a[3]), .b(b[3]), .y(pp_3_3)); 
 
    //================================================ 
    // Row 1 Addition 
    //================================================ 
    wire sum_row1_col1; 
    wire carry_row1_col1; 
 
    wire sum_row1_col2; 
    wire carry_row1_col2; 
 
    wire sum_row1_col3; 
    wire carry_row1_col3; 
 
    wire sum_row1_col4; 
    wire carry_row1_col4; 
 
    half_adder ha_row1_col1 ( 

        .a(pp_0_1), 
        .b(pp_1_0), 
        .sum(sum_row1_col1), 
        .carry(carry_row1_col1) 
    ); 
 
    full_adder fa_row1_col2 ( 
        .a(pp_0_2), 
        .b(pp_1_1), 
        .cin(carry_row1_col1), 
        .sum(sum_row1_col2), 
        .cout(carry_row1_col2) 
    ); 
 
    full_adder fa_row1_col3 ( 
        .a(pp_0_3), 
        .b(pp_1_2), 
        .cin(carry_row1_col2), 
        .sum(sum_row1_col3), 
        .cout(carry_row1_col3) 
    ); 
 
    full_adder fa_row1_col4 ( 
        .a(1'b0), 
        .b(pp_1_3), 
        .cin(carry_row1_col3), 

        .sum(sum_row1_col4), 
        .cout(carry_row1_col4) 
    ); 
 
    //================================================ 
    // Row 2 Addition 
    //================================================ 
    wire sum_row2_col2; 
    wire carry_row2_col2; 
 
    wire sum_row2_col3; 
    wire carry_row2_col3; 
 
    wire sum_row2_col4; 
    wire carry_row2_col4; 
 
    wire sum_row2_col5; 
    wire carry_row2_col5; 
 
    half_adder ha_row2_col2 ( 
        .a(sum_row1_col2), 
        .b(pp_2_0), 
        .sum(sum_row2_col2), 
        .carry(carry_row2_col2) 
    ); 
 

    full_adder fa_row2_col3 ( 
        .a(sum_row1_col3), 
        .b(pp_2_1), 
        .cin(carry_row2_col2), 
        .sum(sum_row2_col3), 
        .cout(carry_row2_col3) 
    ); 
 
    full_adder fa_row2_col4 ( 
        .a(sum_row1_col4), 
        .b(pp_2_2), 
        .cin(carry_row2_col3), 
        .sum(sum_row2_col4), 
        .cout(carry_row2_col4) 
    ); 
 
    full_adder fa_row2_col5 ( 
        .a(carry_row1_col4), 
        .b(pp_2_3), 
        .cin(carry_row2_col4), 
        .sum(sum_row2_col5), 
        .cout(carry_row2_col5) 
    ); 
 
    //================================================ 
    // Row 3 Addition 

    //================================================ 
    wire sum_row3_col3; 
    wire carry_row3_col3; 
 
    wire sum_row3_col4; 
    wire carry_row3_col4; 
 
    wire sum_row3_col5; 
    wire carry_row3_col5; 
 
    wire sum_row3_col6; 
    wire carry_row3_col6; 
 
    half_adder ha_row3_col3 ( 
        .a(sum_row2_col3), 
        .b(pp_3_0), 
        .sum(sum_row3_col3), 
        .carry(carry_row3_col3) 
    ); 
 
    full_adder fa_row3_col4 ( 
        .a(sum_row2_col4), 
        .b(pp_3_1), 
        .cin(carry_row3_col3), 
        .sum(sum_row3_col4), 
        .cout(carry_row3_col4) 

    ); 
 
    full_adder fa_row3_col5 ( 
        .a(sum_row2_col5), 
        .b(pp_3_2), 
        .cin(carry_row3_col4), 
        .sum(sum_row3_col5), 
        .cout(carry_row3_col5) 
    ); 
 
    full_adder fa_row3_col6 ( 
        .a(carry_row2_col5), 
        .b(pp_3_3), 
        .cin(carry_row3_col5), 
        .sum(sum_row3_col6), 
        .cout(carry_row3_col6) 
    ); 
 
    //================================================ 
    // Product Assignment 
    //================================================ 
    assign product[0] = pp_0_0; 
    assign product[1] = sum_row1_col1; 
    assign product[2] = sum_row2_col2; 
    assign product[3] = sum_row3_col3; 
    assign product[4] = sum_row3_col4; 

    assign product[5] = sum_row3_col5; 
    assign product[6] = sum_row3_col6; 
    assign product[7] = carry_row3_col6; 
 
endmodule