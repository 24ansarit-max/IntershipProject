module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    //==================================================== 
    // Partial Products 
    //==================================================== 
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
 
    //==================================================== 

    // Column 1 
    //==================================================== 
    wire s11, c11; 
 
    assign s11 = pp_0_1 ^ pp_1_0; 
    assign c11 = pp_0_1 & pp_1_0; 
 
    //==================================================== 
    // Column 2 
    //==================================================== 
    wire s21, c21; 
    wire s22, c22; 
 
    assign s21 = pp_0_2 ^ pp_1_1; 
    assign c21 = pp_0_2 & pp_1_1; 
 
    assign s22 = s21 ^ pp_2_0; 
    assign c22 = s21 & pp_2_0; 
 
    //==================================================== 
    // Column 3 
    //==================================================== 
    wire s31, c31; 
    wire s32, c32; 

    wire s33, c33; 
 
    assign s31 = pp_0_3 ^ pp_1_2; 
    assign c31 = pp_0_3 & pp_1_2; 
 
    assign s32 = s31 ^ pp_2_1; 
    assign c32 = s31 & pp_2_1; 
 
    assign s33 = s32 ^ pp_3_0; 
    assign c33 = s32 & pp_3_0; 
 
    //==================================================== 
    // Column 4 
    //==================================================== 
    wire s41, c41; 
    wire s42, c42; 
    wire s43, c43; 
 
    assign s41 = pp_1_3 ^ pp_2_2; 
    assign c41 = pp_1_3 & pp_2_2; 
 
    assign s42 = s41 ^ pp_3_1; 
    assign c42 = s41 & pp_3_1; 
 

    assign s43 = s42 ^ c21; 
    assign c43 = s42 & c21; 
 
    //==================================================== 
    // Column 5 
    //==================================================== 
    wire s51, c51; 
    wire s52, c52; 
    wire s53, c53; 
 
    assign s51 = pp_2_3 ^ pp_3_2; 
    assign c51 = pp_2_3 & pp_3_2; 
 
    assign s52 = s51 ^ c31; 
    assign c52 = s51 & c31; 
 
    assign s53 = s52 ^ c41; 
    assign c53 = s52 & c41; 
 
    //==================================================== 
    // Column 6 
    //==================================================== 
    wire s61, c61; 
    wire s62, c62; 

 
    assign s61 = pp_3_3 ^ c51; 
    assign c61 = pp_3_3 & c51; 
 
    assign s62 = s61 ^ c52; 
    assign c62 = s61 & c52; 
 
    //==================================================== 
    // Final Carry Propagation 
    //==================================================== 
    wire k2, k3, k4, k5, k6; 
 
    assign k2 = c11; 
 
    assign product[0] = pp_0_0; 
    assign product[1] = s11; 
 
    assign product[2] = s22 ^ k2; 
    assign k3         = (s22 & k2) | c22; 
 
    assign product[3] = s33 ^ k3; 
    assign k4         = (s33 & k3) | c32 | c33; 
 
    assign product[4] = s43 ^ k4; 

    assign k5         = (s43 & k4) | c42 | c43 | c22; 
 
    assign product[5] = s53 ^ k5; 
    assign k6         = (s53 & k5) | c53; 
 
    assign product[6] = s62 ^ k6; 
    assign product[7] = c61 | c62 | (s62 & k6); 
 
endmodule