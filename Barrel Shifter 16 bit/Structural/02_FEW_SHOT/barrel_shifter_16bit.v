module mux2x1( 
    input  wire sel, 
    input  wire a, 
    input  wire b, 
    output wire y 
); 
    wire nsel,w1,w2; 
    not (nsel,sel); 
    and (w1,a,nsel); 
    and (w2,b,sel); 
    or  (y,w1,w2); 
endmodule 
 
module barrel_left16( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift, 
    output wire [15:0] out 
); 
 

wire [15:0] s0,s1,s2; 
 
genvar i; 
 
generate 
 
// Shift by 1 
for(i=0;i<16;i=i+1) 
begin : STAGE0 
    if(i==15) 
        mux2x1 M(.sel(shift[0]),.a(in[i]),.b(1'b0),.y(s0[i])); 
    else 
        mux2x1 M(.sel(shift[0]),.a(in[i]),.b(in[i+1]),.y(s0[i])); 
end 
 
// Shift by 2 
for(i=0;i<16;i=i+1) 
begin : STAGE1 
    if(i>=14) 
        mux2x1 M(.sel(shift[1]),.a(s0[i]),.b(1'b0),.y(s1[i])); 
    else 
        mux2x1 M(.sel(shift[1]),.a(s0[i]),.b(s0[i+2]),.y(s1[i])); 
end 
 
// Shift by 4 
for(i=0;i<16;i=i+1) 
begin : STAGE2 
    if(i>=12) 

        mux2x1 M(.sel(shift[2]),.a(s1[i]),.b(1'b0),.y(s2[i])); 
    else 
        mux2x1 M(.sel(shift[2]),.a(s1[i]),.b(s1[i+4]),.y(s2[i])); 
end 
 
// Shift by 8 
for(i=0;i<16;i=i+1) 
begin : STAGE3 
    if(i>=8) 
        mux2x1 M(.sel(shift[3]),.a(s2[i]),.b(1'b0),.y(out[i])); 
    else 
        mux2x1 M(.sel(shift[3]),.a(s2[i]),.b(s2[i+8]),.y(out[i])); 
end 
 
endgenerate 
 
endmodule