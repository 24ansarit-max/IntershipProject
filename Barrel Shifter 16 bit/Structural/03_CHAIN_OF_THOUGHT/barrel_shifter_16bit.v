module mux2x1( 

    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
 
wire nsel,w1,w2; 
 
not U0(nsel,sel); 
and U1(w1,a,nsel); 
and U2(w2,b,sel); 
or  U3(y,w1,w2); 
 
endmodule 
`timescale 1ns/1ps 
 
module mux2x1( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
 
wire nsel,w1,w2; 
 
not U0(nsel,sel); 
and U1(w1,a,nsel); 
and U2(w2,b,sel); 

or  U3(y,w1,w2); 
 
endmodule 
 
 
module barrel_shifter16 
( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift, 
 
    //000 LSL 
    //001 LSR 
    //010 ASR 
    //011 ROL 
    //100 ROR 
    input  wire [2:0] mode, 
 
    output wire [15:0] out 
); 
 
wire [15:0] l0,l1,l2,l3; 
wire [15:0] r0,r1,r2,r3; 
wire [15:0] a0,a1,a2,a3; 
wire [15:0] rl0,rl1,rl2,rl3; 
wire [15:0] rr0,rr1,rr2,rr3; 
 
wire [15:0] m0; 
wire [15:0] m1; 

wire [15:0] m2; 
 
genvar i; 
 
generate 
 
//-------------------------------------------------- 
// LEFT SHIFT 
//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:LS0 
    if(i==15) 
        mux2x1 M(in[i],1'b0,shift[0],l0[i]); 
    else 
        mux2x1 M(in[i],in[i+1],shift[0],l0[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:LS1 
    if(i>=14) 
        mux2x1 M(l0[i],1'b0,shift[1],l1[i]); 
    else 
        mux2x1 M(l0[i],l0[i+2],shift[1],l1[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:LS2 

    if(i>=12) 
        mux2x1 M(l1[i],1'b0,shift[2],l2[i]); 
    else 
        mux2x1 M(l1[i],l1[i+4],shift[2],l2[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:LS3 
    if(i>=8) 
        mux2x1 M(l2[i],1'b0,shift[3],l3[i]); 
    else 
        mux2x1 M(l2[i],l2[i+8],shift[3],l3[i]); 
end 
 
//-------------------------------------------------- 
// RIGHT LOGICAL 
//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:RS0 
    if(i==0) 
        mux2x1 M(in[i],1'b0,shift[0],r0[i]); 
    else 
        mux2x1 M(in[i],in[i-1],shift[0],r0[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RS1 

    if(i<2) 
        mux2x1 M(r0[i],1'b0,shift[1],r1[i]); 
    else 
        mux2x1 M(r0[i],r0[i-2],shift[1],r1[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RS2 
    if(i<4) 
        mux2x1 M(r1[i],1'b0,shift[2],r2[i]); 
    else 
        mux2x1 M(r1[i],r1[i-4],shift[2],r2[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RS3 
    if(i<8) 
        mux2x1 M(r2[i],1'b0,shift[3],r3[i]); 
    else 
        mux2x1 M(r2[i],r2[i-8],shift[3],r3[i]); 
end 
 
//-------------------------------------------------- 
// ARITHMETIC RIGHT 
//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:AS0 

    if(i==15) 
        mux2x1 M(in[i],in[15],shift[0],a0[i]); 
    else 
        mux2x1 M(in[i],in[i+1],shift[0],a0[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:AS1 
    if(i>=14) 
        mux2x1 M(a0[i],in[15],shift[1],a1[i]); 
    else 
        mux2x1 M(a0[i],a0[i+2],shift[1],a1[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:AS2 
    if(i>=12) 
        mux2x1 M(a1[i],in[15],shift[2],a2[i]); 
    else 
        mux2x1 M(a1[i],a1[i+4],shift[2],a2[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:AS3 
    if(i>=8) 
        mux2x1 M(a2[i],in[15],shift[3],a3[i]); 
    else 
        mux2x1 M(a2[i],a2[i+8],shift[3],a3[i]); 

end 
 
//-------------------------------------------------- 
// ROTATE LEFT 
//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:RL0 
    mux2x1 M(in[i],in[(i+1)%16],shift[0],rl0[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RL1 
    mux2x1 M(rl0[i],rl0[(i+2)%16],shift[1],rl1[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RL2 
    mux2x1 M(rl1[i],rl1[(i+4)%16],shift[2],rl2[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RL3 
    mux2x1 M(rl2[i],rl2[(i+8)%16],shift[3],rl3[i]); 
end 
 
//-------------------------------------------------- 
// ROTATE RIGHT 

//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:RR0 
    mux2x1 M(in[i],in[(i+15)%16],shift[0],rr0[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RR1 
    mux2x1 M(rr0[i],rr0[(i+14)%16],shift[1],rr1[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RR2 
    mux2x1 M(rr1[i],rr1[(i+12)%16],shift[2],rr2[i]); 
end 
 
for(i=0;i<16;i=i+1) 
begin:RR3 
    mux2x1 M(rr2[i],rr2[(i+8)%16],shift[3],rr3[i]); 
end 
 
//-------------------------------------------------- 
// MODE SELECT 
//-------------------------------------------------- 
 
for(i=0;i<16;i=i+1) 
begin:MODEMUX 

 
    mux2x1 U0(l3[i],r3[i],mode[0],m0[i]); 
    mux2x1 U1(a3[i],rl3[i],mode[0],m1[i]); 
    mux2x1 U2(m0[i],m1[i],mode[1],m2[i]); 
    mux2x1 U3(m2[i],rr3[i],mode[2],out[i]); 
 
end 
 
endgenerate 
 
endmodule