module array_multiplier_4bit ( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    //======================================================== 
    // Section 1: All 16 partial product wire declarations 
    //======================================================== 
 
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
 
    //======================================================== 
    // Section 2: Row 1 adder expressions 
    //======================================================== 
 
    wire s_1_1, c_1_1; 
    wire s_1_2, c_1_2; 
    wire s_1_3, c_1_3; 
    wire s_1_4, c_1_4; 
 
    assign s_1_1 = pp_0_1 ^ pp_1_0; 
    assign c_1_1 = pp_0_1 & pp_1_0; 
 
    assign s_1_2 = pp_0_2 ^ pp_1_1; 

    assign c_1_2 = pp_0_2 & pp_1_1; 
 
    assign s_1_3 = pp_0_3 ^ pp_1_2; 
    assign c_1_3 = pp_0_3 & pp_1_2; 
 
    assign s_1_4 = pp_1_3; 
    assign c_1_4 = 1'b0; 
 
    //======================================================== 
    // Section 3: Row 2 adder expressions 
    //======================================================== 
 
    wire s_2_2, c_2_2; 
    wire s_2_3, c_2_3; 
    wire s_2_4, c_2_4; 
    wire s_2_5, c_2_5; 
 
    assign s_2_2 = s_1_2 ^ pp_2_0 ^ c_1_1; 
    assign c_2_2 = (s_1_2 & pp_2_0) | 
                   (s_1_2 & c_1_1) | 
                   (pp_2_0 & c_1_1); 
 
    assign s_2_3 = s_1_3 ^ pp_2_1 ^ c_1_2; 
    assign c_2_3 = (s_1_3 & pp_2_1) | 

                   (s_1_3 & c_1_2) | 
                   (pp_2_1 & c_1_2); 
 
    assign s_2_4 = s_1_4 ^ pp_2_2 ^ c_1_3; 
    assign c_2_4 = (s_1_4 & pp_2_2) | 
                   (s_1_4 & c_1_3) | 
                   (pp_2_2 & c_1_3); 
 
    assign s_2_5 = pp_2_3 ^ c_1_4; 
    assign c_2_5 = pp_2_3 & c_1_4; 
 
    //======================================================== 
    // Section 4: Row 3 adder expressions 
    //======================================================== 
 
    wire s_3_3, c_3_3; 
    wire s_3_4, c_3_4; 
    wire s_3_5, c_3_5; 
    wire s_3_6, c_3_6; 
 
    assign s_3_3 = s_2_3 ^ pp_3_0 ^ c_2_2; 
    assign c_3_3 = (s_2_3 & pp_3_0) | 
                   (s_2_3 & c_2_2) | 
                   (pp_3_0 & c_2_2); 

 
    assign s_3_4 = s_2_4 ^ pp_3_1 ^ c_2_3; 
    assign c_3_4 = (s_2_4 & pp_3_1) | 
                   (s_2_4 & c_2_3) | 
                   (pp_3_1 & c_2_3); 
 
    assign s_3_5 = s_2_5 ^ pp_3_2 ^ c_2_4; 
    assign c_3_5 = (s_2_5 & pp_3_2) | 
                   (s_2_5 & c_2_4) | 
                   (pp_3_2 & c_2_4); 
 
    assign s_3_6 = pp_3_3 ^ c_2_5; 
    assign c_3_6 = pp_3_3 & c_2_5; 
 
    //======================================================== 
    // Section 5: Final product bit assignments 
    //======================================================== 
 
    wire c_final_4; 
    wire c_final_5; 
    wire c_final_6; 
 
    assign c_final_4 = c_3_4; 
    assign c_final_5 = c_3_5; 

    assign c_final_6 = c_3_6; 
 
    assign product[0] = pp_0_0; 
    assign product[1] = s_1_1; 
    assign product[2] = s_2_2; 
    assign product[3] = s_3_3; 
 
    assign product[4] = s_3_4 ^ c_3_3; 
    assign product[5] = s_3_5 ^ c_final_4; 
    assign product[6] = s_3_6 ^ c_final_5; 
 
    assign product[7] = c_final_6 | 
                        (s_3_6 & c_final_5); 
 
endmodule