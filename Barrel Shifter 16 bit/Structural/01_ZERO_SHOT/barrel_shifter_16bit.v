`timescale 1ns/1ps 
 
//---------------------------------------------------- 
// 2:1 MUX Primitive 
//---------------------------------------------------- 
module mux2x1( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
 
wire nsel; 
wire w1; 

wire w2; 
 
not U0(nsel, sel); 
and U1(w1, a, nsel); 
and U2(w2, b, sel); 
or  U3(y, w1, w2); 
 
endmodule 
 
 
//---------------------------------------------------- 
// Generic Barrel Stage 
// SHIFT = 1,2,4,8 
//---------------------------------------------------- 
module barrel_stage 
#( 
    parameter SHIFT = 1 
) 
( 
    input  wire [15:0] in, 
    input  wire [15:0] alt, 
    input  wire        sel, 
    output wire [15:0] out 
); 
 
genvar i; 
 
generate 

    for(i=0;i<16;i=i+1) 
    begin : G 
 
        mux2x1 M 
        ( 
            .a(in[i]), 
            .b(alt[i]), 
            .sel(sel), 
            .y(out[i]) 
        ); 
 
    end 
endgenerate 
 
endmodule 
 
 
//---------------------------------------------------- 
// 16-bit Universal Barrel Shifter 
// 
// mode: 
// 000 = Left Shift 
// 001 = Right Logical 
// 010 = Right Arithmetic 
// 011 = Rotate Left 
// 100 = Rotate Right 
//---------------------------------------------------- 
module barrel_shifter16 

( 
    input  wire [15:0] din, 
    input  wire [3:0]  shamt, 
    input  wire [2:0]  mode, 
    output wire [15:0] dout 
); 
 
wire [15:0] L1,L2,L3,L4; 
wire [15:0] R1,R2,R3,R4; 
wire [15:0] A1,A2,A3,A4; 
wire [15:0] RL1,RL2,RL3,RL4; 
wire [15:0] RR1,RR2,RR3,RR4; 
 
//---------------------------------------------------- 
// LEFT SHIFT NETWORK 
//---------------------------------------------------- 
 
barrel_stage #(1) LS1( 
    din, 
    {din[14:0],1'b0}, 
    shamt[0], 
    L1 
); 
 
barrel_stage #(2) LS2( 
    L1, 
    {L1[13:0],2'b00}, 
    shamt[1], 

    L2 
); 
 
barrel_stage #(4) LS3( 
    L2, 
    {L2[11:0],4'b0000}, 
    shamt[2], 
    L3 
); 
 
barrel_stage #(8) LS4( 
    L3, 
    {L3[7:0],8'h00}, 
    shamt[3], 
    L4 
); 
 
//---------------------------------------------------- 
// RIGHT LOGICAL NETWORK 
//---------------------------------------------------- 
 
barrel_stage #(1) RS1( 
    din, 
    {1'b0,din[15:1]}, 
    shamt[0], 
    R1 
); 
 

barrel_stage #(2) RS2( 
    R1, 
    {2'b00,R1[15:2]}, 
    shamt[1], 
    R2 
); 
 
barrel_stage #(4) RS3( 
    R2, 
    {4'b0000,R2[15:4]}, 
    shamt[2], 
    R3 
); 
 
barrel_stage #(8) RS4( 
    R3, 
    {8'h00,R3[15:8]}, 
    shamt[3], 
    R4 
); 
 
//---------------------------------------------------- 
// RIGHT ARITHMETIC NETWORK 
//---------------------------------------------------- 
 
barrel_stage #(1) AR1( 
    din, 
    {din[15],din[15:1]}, 

    shamt[0], 
    A1 
); 
 
barrel_stage #(2) AR2( 
    A1, 
    {{2{din[15]}},A1[15:2]}, 
    shamt[1], 
    A2 
); 
 
barrel_stage #(4) AR3( 
    A2, 
    {{4{din[15]}},A2[15:4]}, 
    shamt[2], 
    A3 
); 
 
barrel_stage #(8) AR4( 
    A3, 
    {{8{din[15]}},A3[15:8]}, 
    shamt[3], 
    A4 
); 
 
//---------------------------------------------------- 
// ROTATE LEFT NETWORK 
//---------------------------------------------------- 

 
barrel_stage #(1) RL_S1( 
    din, 
    {din[14:0],din[15]}, 
    shamt[0], 
    RL1 
); 
 
barrel_stage #(2) RL_S2( 
    RL1, 
    {RL1[13:0],RL1[15:14]}, 
    shamt[1], 
    RL2 
); 
 
barrel_stage #(4) RL_S3( 
    RL2, 
    {RL2[11:0],RL2[15:12]}, 
    shamt[2], 
    RL3 
); 
 
barrel_stage #(8) RL_S4( 
    RL3, 
    {RL3[7:0],RL3[15:8]}, 
    shamt[3], 
    RL4 
); 

 
//---------------------------------------------------- 
// ROTATE RIGHT NETWORK 
//---------------------------------------------------- 
 
barrel_stage #(1) RR_S1( 
    din, 
    {din[0],din[15:1]}, 
    shamt[0], 
    RR1 
); 
 
barrel_stage #(2) RR_S2( 
    RR1, 
    {RR1[1:0],RR1[15:2]}, 
    shamt[1], 
    RR2 
); 
 
barrel_stage #(4) RR_S3( 
    RR2, 
    {RR2[3:0],RR2[15:4]}, 
    shamt[2], 
    RR3 
); 
 
barrel_stage #(8) RR_S4( 
    RR3, 

    {RR3[7:0],RR3[15:8]}, 
    shamt[3], 
    RR4 
); 
 
//---------------------------------------------------- 
// OUTPUT MODE SELECT 
//---------------------------------------------------- 
 
wire [15:0] M0; 
wire [15:0] M1; 
wire [15:0] M2; 
 
genvar k; 
 
generate 
 
for(k=0;k<16;k=k+1) 
begin : MODE_SEL 
 
    mux2x1 MX0( 
        .a(L4[k]), 
        .b(R4[k]), 
        .sel(mode[0]), 
        .y(M0[k]) 
    ); 
 
    mux2x1 MX1( 

        .a(A4[k]), 
        .b(RL4[k]), 
        .sel(mode[0]), 
        .y(M1[k]) 
    ); 
 
    mux2x1 MX2( 
        .a(M0[k]), 
        .b(M1[k]), 
        .sel(mode[1]), 
        .y(M2[k]) 
    ); 
 
    mux2x1 MX3( 
        .a(M2[k]), 
        .b(RR4[k]), 
        .sel(mode[2]), 
        .y(dout[k]) 
    ); 
end 
endgenerate 
endmodule