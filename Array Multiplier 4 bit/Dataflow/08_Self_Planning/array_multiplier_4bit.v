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
    wire s2, c2b; 
 
    assign s2a = pp_0_2 ^ pp_1_1; 
    assign c2a = pp_0_2 & pp_1_1; 
 
    assign s2  = s2a ^ pp_2_0 ^ c1; 
    assign c2b = (s2a & pp_2_0) | 
                 (s2a & c1)     | 
                 (pp_2_0 & c1); 
 
    // Column 3 
    wire s3a, c3a; 
    wire s3b, c3b; 
    wire s3, c3c; 
 
    assign s3a = pp_0_3 ^ pp_1_2 ^ pp_2_1; 
    assign c3a = (pp_0_3 & pp_1_2) | 
                 (pp_0_3 & pp_2_1) | 
                 (pp_1_2 & pp_2_1); 
 
    assign s3b = pp_3_0 ^ c2a ^ c2b; 
    assign c3b = (pp_3_0 & c2a) | 

                 (pp_3_0 & c2b) | 
                 (c2a & c2b); 
 
    assign s3  = s3a ^ s3b; 
    assign c3c = s3a & s3b; 
 
    // Column 4 
    wire s4a, c4a; 
    wire s4b, c4b; 
    wire s4, c4c; 
 
    assign s4a = pp_1_3 ^ pp_2_2 ^ pp_3_1; 
    assign c4a = (pp_1_3 & pp_2_2) | 
                 (pp_1_3 & pp_3_1) | 
                 (pp_2_2 & pp_3_1); 
 
    assign s4b = c3a ^ c3b ^ c3c; 
    assign c4b = (c3a & c3b) | 
                 (c3a & c3c) | 
                 (c3b & c3c); 
 
    assign s4  = s4a ^ s4b; 
    assign c4c = s4a & s4b; 
 

    // Column 5 
    wire s5a, c5a; 
    wire s5, c5b; 
 
    assign s5a = pp_2_3 ^ pp_3_2 ^ c4a; 
    assign c5a = (pp_2_3 & pp_3_2) | 
                 (pp_2_3 & c4a)    | 
                 (pp_3_2 & c4a); 
 
    assign s5  = s5a ^ c4b ^ c4c; 
    assign c5b = (s5a & c4b) | 
                 (s5a & c4c) | 
                 (c4b & c4c); 
 
    // Column 6 
    wire s6, c6; 
 
    assign s6 = pp_3_3 ^ c5a ^ c5b; 
    assign c6 = (pp_3_3 & c5a) | 
                (pp_3_3 & c5b) | 
                (c5a & c5b); 
 
    // Outputs 
    assign product[0] = pp_0_0; 

    assign product[1] = s1; 
    assign product[2] = s2; 
    assign product[3] = s3; 
    assign product[4] = s4; 
    assign product[5] = s5; 
    assign product[6] = s6; 
    assign product[7] = c6; 
 
endmodule