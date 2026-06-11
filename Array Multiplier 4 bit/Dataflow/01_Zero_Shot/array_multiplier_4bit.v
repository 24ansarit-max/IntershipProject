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
 
    // Column 1 
    wire s1, c1; 
    assign s1 = p01 ^ p10; 
    assign c1 = p01 & p10; 
 
    // Column 2 
    wire s2a, c2a; 
    wire s2,  c2b; 
 
    assign s2a = p02 ^ p11; 
    assign c2a = p02 & p11; 
 
    assign s2  = s2a ^ p20 ^ c1; 
    assign c2b = (s2a & p20) | (s2a & c1) | (p20 & c1); 
 
    // Column 3 
    wire s3a, c3a; 
    wire s3b, c3b; 
    wire s3,  c3c; 
 
    assign s3a = p03 ^ p12; 

    assign c3a = p03 & p12; 
 
    assign s3b = s3a ^ p21 ^ c2a; 
    assign c3b = (s3a & p21) | (s3a & c2a) | (p21 & c2a); 
 
    assign s3  = s3b ^ p30 ^ c2b; 
    assign c3c = (s3b & p30) | (s3b & c2b) | (p30 & c2b); 
 
    // Column 4 
    wire s4a, c4a; 
    wire s4b, c4b; 
    wire s4,  c4c; 
 
    assign s4a = p13 ^ p22 ^ c3a; 
    assign c4a = (p13 & p22) | (p13 & c3a) | (p22 & c3a); 
 
    assign s4b = s4a ^ p31 ^ c3b; 
    assign c4b = (s4a & p31) | (s4a & c3b) | (p31 & c3b); 
 
    assign s4  = s4b ^ c3c; 
    assign c4c = s4b & c3c; 
 
    // Column 5 
    wire s5a, c5a; 

    wire s5,  c5b; 
 
    assign s5a = p23 ^ p32 ^ c4a; 
    assign c5a = (p23 & p32) | (p23 & c4a) | (p32 & c4a); 
 
    assign s5  = s5a ^ c4b ^ c4c; 
    assign c5b = (s5a & c4b) | (s5a & c4c) | (c4b & c4c); 
 
    // Column 6 
    wire s6, c6; 
 
    assign s6 = p33 ^ c5a ^ c5b; 
    assign c6 = (p33 & c5a) | (p33 & c5b) | (c5a & c5b); 
 
    // Product bits 
    assign product[0] = p00; 
    assign product[1] = s1; 
    assign product[2] = s2; 
    assign product[3] = s3; 
    assign product[4] = s4; 
    assign product[5] = s5; 
    assign product[6] = s6; 
    assign product[7] = c6; 
 

endmodule