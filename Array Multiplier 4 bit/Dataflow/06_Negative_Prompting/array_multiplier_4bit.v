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
 

    // Column 1 
    wire s1, c1; 
    assign s1 = pp_0_1 ^ pp_1_0; 
    assign c1 = pp_0_1 & pp_1_0; 
 
    // Column 2 
    wire s2a, c2a; 
    wire s2,  c2b; 
    assign s2a = pp_0_2 ^ pp_1_1; 
    assign c2a = pp_0_2 & pp_1_1; 
 
    assign s2  = s2a ^ pp_2_0; 
    assign c2b = s2a & pp_2_0; 
 
    wire c2; 
    assign c2 = c2a | c2b; 
 
    // Column 3 
    wire s3a, c3a; 
    wire s3b, c3b; 
    wire s3,  c3c; 
 
    assign s3a = pp_0_3 ^ pp_1_2; 
    assign c3a = pp_0_3 & pp_1_2; 

 
    assign s3b = s3a ^ pp_2_1; 
    assign c3b = s3a & pp_2_1; 
 
    assign s3  = s3b ^ pp_3_0; 
    assign c3c = s3b & pp_3_0; 
 
    wire carry_col3; 
    assign carry_col3 = c3a | c3b | c3c; 
 
    // Column 4 
    wire s4a, c4a; 
    wire s4b, c4b; 
    wire s4c, c4c; 
 
    assign s4a = pp_1_3 ^ pp_2_2; 
    assign c4a = pp_1_3 & pp_2_2; 
 
    assign s4b = s4a ^ pp_3_1; 
    assign c4b = s4a & pp_3_1; 
 
    assign s4c = s4b ^ c2; 
    assign c4c = s4b & c2; 
 

    wire carry_col4; 
    assign carry_col4 = c4a | c4b | c4c; 
 
    // Column 5 
    wire s5a, c5a; 
    wire s5b, c5b; 
    wire s5c, c5c; 
 
    assign s5a = pp_2_3 ^ pp_3_2; 
    assign c5a = pp_2_3 & pp_3_2; 
 
    assign s5b = s5a ^ carry_col3; 
    assign c5b = s5a & carry_col3; 
 
    assign s5c = s5b ^ carry_col4; 
    assign c5c = s5b & carry_col4; 
 
    wire carry_col5; 
    assign carry_col5 = c5a | c5b | c5c; 
 
    // Column 6 
    wire s6, c6a; 
    wire c6; 
 

    assign s6  = pp_3_3 ^ carry_col5; 
    assign c6a = pp_3_3 & carry_col5; 
 
    assign c6 = c6a; 
 
    // Product bits 
    assign product[0] = pp_0_0; 
    assign product[1] = s1; 
    assign product[2] = s2 ^ c1; 
 
    wire p2carry; 
    assign p2carry = s2 & c1; 
 
    assign product[3] = s3 ^ p2carry; 
 
    wire p3carry; 
    assign p3carry = s3 & p2carry; 
 
    assign product[4] = s4c ^ p3carry; 
 
    wire p4carry; 
    assign p4carry = s4c & p3carry; 
 
    assign product[5] = s5c ^ p4carry; 

 
    wire p5carry; 
    assign p5carry = s5c & p4carry; 
 
    assign product[6] = s6 ^ p5carry; 
 
    wire p6carry; 
    assign p6carry = s6 & p5carry; 
 
    assign product[7] = c6 | p6carry; 
 
endmodule