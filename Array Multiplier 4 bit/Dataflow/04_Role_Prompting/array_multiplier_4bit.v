module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    //==================================================== 
    // Partial Products 

    //==================================================== 
    wire pp00, pp01, pp02, pp03; 
    wire pp10, pp11, pp12, pp13; 
    wire pp20, pp21, pp22, pp23; 
    wire pp30, pp31, pp32, pp33; 
 
    assign pp00 = a[0] & b[0]; 
    assign pp01 = a[0] & b[1]; 
    assign pp02 = a[0] & b[2]; 
    assign pp03 = a[0] & b[3]; 
 
    assign pp10 = a[1] & b[0]; 
    assign pp11 = a[1] & b[1]; 
    assign pp12 = a[1] & b[2]; 
    assign pp13 = a[1] & b[3]; 
 
    assign pp20 = a[2] & b[0]; 
    assign pp21 = a[2] & b[1]; 
    assign pp22 = a[2] & b[2]; 
    assign pp23 = a[2] & b[3]; 
 
    assign pp30 = a[3] & b[0]; 
    assign pp31 = a[3] & b[1]; 
    assign pp32 = a[3] & b[2]; 

    assign pp33 = a[3] & b[3]; 
 
    //==================================================== 
    // Product Bit 0 
    //==================================================== 
    assign product[0] = pp00; 
 
    //==================================================== 
    // Column 1 
    // pp01 + pp10 
    //==================================================== 
    wire sum_c1; 
    wire carry_c1; 
 
    assign sum_c1   = pp01 ^ pp10; 
    assign carry_c1 = pp01 & pp10; 
 
    assign product[1] = sum_c1; 
 
    //==================================================== 
    // Column 2 
    // pp02 + pp11 + pp20 + carry_c1 
    //==================================================== 
    wire sum_c2_a, carry_c2_a; 

    wire sum_c2_b, carry_c2_b; 
    wire sum_c2_c, carry_c2_c; 
 
    assign sum_c2_a   = pp02 ^ pp11; 
    assign carry_c2_a = pp02 & pp11; 
 
    assign sum_c2_b   = sum_c2_a ^ pp20; 
    assign carry_c2_b = sum_c2_a & pp20; 
 
    assign sum_c2_c   = sum_c2_b ^ carry_c1; 
    assign carry_c2_c = sum_c2_b & carry_c1; 
 
    assign product[2] = sum_c2_c; 
 
    wire carry_col2; 
    assign carry_col2 = carry_c2_a | carry_c2_b | carry_c2_c; 
 
    //==================================================== 
    // Column 3 
    // pp03 + pp12 + pp21 + pp30 + carry_col2 
    //==================================================== 
    wire sum_c3_a, carry_c3_a; 
    wire sum_c3_b, carry_c3_b; 
    wire sum_c3_c, carry_c3_c; 

    wire sum_c3_d, carry_c3_d; 
 
    assign sum_c3_a   = pp03 ^ pp12; 
    assign carry_c3_a = pp03 & pp12; 
 
    assign sum_c3_b   = sum_c3_a ^ pp21; 
    assign carry_c3_b = sum_c3_a & pp21; 
 
    assign sum_c3_c   = sum_c3_b ^ pp30; 
    assign carry_c3_c = sum_c3_b & pp30; 
 
    assign sum_c3_d   = sum_c3_c ^ carry_col2; 
    assign carry_c3_d = sum_c3_c & carry_col2; 
 
    assign product[3] = sum_c3_d; 
 
    wire carry_col3; 
    assign carry_col3 = 
            carry_c3_a | 
            carry_c3_b | 
            carry_c3_c | 
            carry_c3_d; 
 
    //==================================================== 

    // Column 4 
    // pp13 + pp22 + pp31 + carry_col3 
    //==================================================== 
    wire sum_c4_a, carry_c4_a; 
    wire sum_c4_b, carry_c4_b; 
    wire sum_c4_c, carry_c4_c; 
 
    assign sum_c4_a   = pp13 ^ pp22; 
    assign carry_c4_a = pp13 & pp22; 
 
    assign sum_c4_b   = sum_c4_a ^ pp31; 
    assign carry_c4_b = sum_c4_a & pp31; 
 
    assign sum_c4_c   = sum_c4_b ^ carry_col3; 
    assign carry_c4_c = sum_c4_b & carry_col3; 
 
    assign product[4] = sum_c4_c; 
 
    wire carry_col4; 
    assign carry_col4 = 
            carry_c4_a | 
            carry_c4_b | 
            carry_c4_c; 
 

    //==================================================== 
    // Column 5 
    // pp23 + pp32 + carry_col4 
    //==================================================== 
    wire sum_c5_a, carry_c5_a; 
    wire sum_c5_b, carry_c5_b; 
 
    assign sum_c5_a   = pp23 ^ pp32; 
    assign carry_c5_a = pp23 & pp32; 
 
    assign sum_c5_b   = sum_c5_a ^ carry_col4; 
    assign carry_c5_b = sum_c5_a & carry_col4; 
 
    assign product[5] = sum_c5_b; 
 
    wire carry_col5; 
    assign carry_col5 = carry_c5_a | carry_c5_b; 
 
    //==================================================== 
    // Column 6 
    // pp33 + carry_col5 
    //==================================================== 
    wire sum_c6; 
    wire carry_c6; 

 
    assign sum_c6   = pp33 ^ carry_col5; 
    assign carry_c6 = pp33 & carry_col5; 
 
    assign product[6] = sum_c6; 
    assign product[7] = carry_c6; 
 
endmodule