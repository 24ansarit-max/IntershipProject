module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
    // Partial products 
    wire p00, p01, p02, p03; 
    wire p10, p11, p12, p13; 
    wire p20, p21, p22, p23; 
    wire p30, p31, p32, p33; 
 
    assign p00 = a[0] & b[0]; 
    assign p01 = a[0] & b[1]; 
    assign p02 = a[0] & b[2]; 
    assign p03 = a[0] & b[3]; 

 
    assign p10 = a[1] & b[0]; 
    assign p11 = a[1] & b[1]; 
    assign p12 = a[1] & b[2]; 
    assign p13 = a[1] & b[3]; 
 
    assign p20 = a[2] & b[0]; 
    assign p21 = a[2] & b[1]; 
    assign p22 = a[2] & b[2]; 
    assign p23 = a[2] & b[3]; 
 
    assign p30 = a[3] & b[0]; 
    assign p31 = a[3] & b[1]; 
    assign p32 = a[3] & b[2]; 
    assign p33 = a[3] & b[3]; 
 
    // Intermediate sums and carries 
    wire s1, c1; 
    wire s2a, c2a, s2, c2b; 
    wire s3a, c3a, s3b, c3b, s3, c3c; 
    wire s4a, c4a, s4b, c4b, s4, c4c; 
    wire s5a, c5a, s5, c5b; 
    wire s6, c6; 
 

    // Product bit 0 
    assign product[0] = p00; 
 
    // Column 1 
    assign s1 = p01 ^ p10; 
    assign c1 = p01 & p10; 
    assign product[1] = s1; 
 
    // Column 2 
    assign s2a = p02 ^ p11; 
    assign c2a = p02 & p11; 
 
    assign s2  = s2a ^ p20; 
    assign c2b = s2a & p20; 
 
    assign product[2] = s2 ^ c1; 
    wire c2; 
    assign c2 = (s2 & c1) | c2a | c2b; 
 
    // Column 3 
    assign s3a = p03 ^ p12; 
    assign c3a = p03 & p12; 
 
    assign s3b = s3a ^ p21; 

    assign c3b = s3a & p21; 
 
    assign s3  = s3b ^ p30; 
    assign c3c = s3b & p30; 
 
    assign product[3] = s3 ^ c2; 
    wire c3; 
    assign c3 = (s3 & c2) | c3a | c3b | c3c; 
 
    // Column 4 
    assign s4a = p13 ^ p22; 
    assign c4a = p13 & p22; 
 
    assign s4b = s4a ^ p31; 
    assign c4b = s4a & p31; 
 
    assign s4  = s4b ^ c3; 
    assign c4c = s4b & c3; 
 
    assign product[4] = s4; 
    wire c4; 
    assign c4 = c4a | c4b | c4c; 
 
    // Column 5 

    assign s5a = p23 ^ p32; 
    assign c5a = p23 & p32; 
 
    assign s5  = s5a ^ c4; 
    assign c5b = s5a & c4; 
 
    assign product[5] = s5 ^ p41; // invalid signal placeholder 
 
    // Correct column 5 and 6 computation 
    wire col5_sum, col5_carry; 
    assign col5_sum   = p23 ^ p32 ^ c4; 
    assign col5_carry = (p23 & p32) | (p32 & c4) | (p23 & c4); 
 
    assign product[5] = col5_sum ^ p33; 
    wire c5; 
    assign c5 = (col5_sum & p33) | col5_carry; 
 
    // Column 6 
    assign s6 = p33 ^ c5; 
    assign c6 = p33 & c5; 
 
    assign product[6] = s6; 
    assign product[7] = c6; 
 

endmodule 
​
​