module array_multiplier_4bit( 
    input  [3:0] a, 
    input  [3:0] b, 
    output [7:0] product 
); 
 
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
 
wire s1, c1; 
 
assign s1 = pp01 ^ pp10; 
assign c1 = pp01 & pp10; 
 
wire s2a, c2a, s2b, c2b, s2, c2c, c2; 
 
assign s2a = pp02 ^ pp11; 
assign c2a = pp02 & pp11; 
 

assign s2b = s2a ^ pp20; 
assign c2b = s2a & pp20; 
 
assign s2   = s2b ^ c1; 
assign c2c  = s2b & c1; 
 
assign c2 = c2a | c2b | c2c; 
 
wire s3a, c3a, s3b, c3b, s3c, c3c, s3, c3d, c3; 
 
assign s3a = pp03 ^ pp12; 
assign c3a = pp03 & pp12; 
 
assign s3b = s3a ^ pp21; 
assign c3b = s3a & pp21; 
 
assign s3c = s3b ^ pp30; 
assign c3c = s3b & pp30; 
 
assign s3  = s3c ^ c2; 
assign c3d = s3c & c2; 
 
assign c3 = c3a | c3b | c3c | c3d; 
 

wire s4a, c4a, s4b, c4b, s4, c4c, c4; 
 
assign s4a = pp13 ^ pp22; 
assign c4a = pp13 & pp22; 
 
assign s4b = s4a ^ pp31; 
assign c4b = s4a & pp31; 
 
assign s4  = s4b ^ c3; 
assign c4c = s4b & c3; 
 
assign c4 = c4a | c4b | c4c; 
 
wire s5a, c5a, s5, c5b, c5; 
 
assign s5a = pp23 ^ pp32; 
assign c5a = pp23 & pp32; 
 
assign s5  = s5a ^ c4; 
assign c5b = s5a & c4; 
 
assign c5 = c5a | c5b; 
 
wire s6, c6; 

 
assign s6 = pp33 ^ c5; 
assign c6 = pp33 & c5; 
 
assign product[0] = pp00; 
assign product[1] = s1; 
assign product[2] = s2; 
assign product[3] = s3; 
assign product[4] = s4; 
assign product[5] = s5; 
assign product[6] = s6; 
assign product[7] = c6; 
 
endmodule 
​