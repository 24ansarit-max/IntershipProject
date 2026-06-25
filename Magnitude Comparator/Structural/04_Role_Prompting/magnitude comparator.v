`timescale 1ns/1ps
module cmp1 (
    input wire A,
    input wire B,
    output wire GT,
    output wire LT,
    output wire EQ
);
    wire nA;
    wire nB;
    wire xAB;
    not U0 (nA, A);
    not U1 (nB, B);
    and U2 (GT, A, nB);
    and U3 (LT, nA, B);
    xor U4 (xAB, A, B);
    not U5 (EQ, xAB);
endmodule

module cmp4 #
(
    parameter AREA_OPT = 0
)
(
    input wire [3:0] A,
    input wire [3:0] B,
    output wire GT,
    output wire LT,
    output wire EQ
);
    wire [3:0] gt_b;
    wire [3:0] lt_b;
    wire [3:0] eq_b;
    generate
        if (AREA_OPT) begin : AREA_PATH
            wire group_xor;
            xor GX0(group_xor, A[0], B[0], A[1], B[1], A[2], B[2], A[3], B[3]);
            genvar i,j;
            for (i=0;i<1;i=i+1) begin : GROUP
                for (j=0;j<4;j=j+1) begin : BIT
                    cmp1 U_CMP1 (.A(A[j]), .B(B[j]), .GT(gt_b[j]), .LT(lt_b[j]), .EQ(eq_b[j]));
                end
            end
        end
        else begin : STD_PATH
            genvar i,j;
            for (i=0;i<1;i=i+1) begin : GROUP
                for (j=0;j<4;j=j+1) begin : BIT
                    cmp1 U_CMP1 (.A(A[j]), .B(B[j]), .GT(gt_b[j]), .LT(lt_b[j]), .EQ(eq_b[j]));
                end
            end
        end
    endgenerate
    wire eq32;
    wire eq321;
    and U10(eq32 , eq_b[3], eq_b[2]);
    and U11(eq321, eq32 , eq_b[1]);
    and U12(EQ , eq321 , eq_b[0]);
    wire t0,t1,t2;
    wire s0,s1,s2;
    and U13(t0, eq_b[3], gt_b[2]);
    and U14(t1, eq_b[3], eq_b[2], gt_b[1]);
    and U15(t2, eq_b[3], eq_b[2], eq_b[1], gt_b[0]);
    or U16(GT, gt_b[3], t0, t1, t2);
    and U17(s0, eq_b[3], lt_b[2]);
    and U18(s1, eq_b[3], eq_b[2], lt_b[1]);
    and U19(s2, eq_b[3], eq_b[2], eq_b[1], lt_b[0]);
    or U20(LT, lt_b[3], s0, s1, s2);
endmodule

module cmp16_structural #
(
    parameter N = 16,
    parameter POWER_OPT = 0,
    parameter AREA_OPT = 0,
    parameter DELAY_OPT = 0
)
(
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire GT,
    output wire LT,
    output wire EQ
);
    wire [N-1:0] A_int;
    wire [N-1:0] B_int;
    genvar i;
    generate
        for (i=0;i<N;i=i+1) begin : BIT_CHAIN
            if (POWER_OPT) begin : GATED
                and UG0(A_int[i], A[i], 1'b1);
                and UG1(B_int[i], B[i], 1'b1);
            end
            else begin : DIRECT
                buf UB0(A_int[i], A[i]);
                buf UB1(B_int[i], B[i]);
            end
        end
    endgenerate

    wire gt0,gt1,gt2,gt3;
    wire lt0,lt1,lt2,lt3;
    wire eq0,eq1,eq2,eq3;
    cmp4 #(.AREA_OPT(AREA_OPT)) U_G0 (.A(A_int[3:0]), .B(B_int[3:0]), .GT(gt0), .LT(lt0), .EQ(eq0));
    cmp4 #(.AREA_OPT(AREA_OPT)) U_G1 (.A(A_int[7:4]), .B(B_int[7:4]), .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 #(.AREA_OPT(AREA_OPT)) U_G2 (.A(A_int[11:8]), .B(B_int[11:8]), .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 #(.AREA_OPT(AREA_OPT)) U_G3 (.A(A_int[15:12]), .B(B_int[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));

    generate
        case ({POWER_OPT, DELAY_OPT})
            2'b01, 2'b11 : begin : DELAY_PATH
                wire eq32;
                wire eq321;
                and D0(eq32 , eq3 , eq2);
                and D1(eq321, eq32, eq1);
                and D2(EQ , eq321, eq0);
                wire g0,g1,g2;
                wire l0,l1,l2;
                and D3(g0, eq3, gt2);
                and D4(g1, eq3, eq2, gt1);
                and D5(g2, eq3, eq2, eq1, gt0);
                or D6(GT, gt3, g0, g1, g2);
                and D7(l0, eq3, lt2);
                and D8(l1, eq3, eq2, lt1);
                and D9(l2, eq3, eq2, eq1, lt0);
                or D10(LT, lt3, l0, l1, l2);
            end
            default : begin : STD_TOPOLOGY
                wire eq32;
                wire eq321;
                and S0(eq32 , eq3 , eq2);
                and S1(eq321, eq32, eq1);
                and S2(EQ , eq321, eq0);
                wire g0,g1,g2;
                wire l0,l1,l2;
                and S3(g0, eq3, gt2);
                and S4(g1, eq3, eq2, gt1);
                and S5(g2, eq3, eq2, eq1, gt0);
                or S6(GT, gt3, g0, g1, g2);
                and S7(l0, eq3, lt2);
                and S8(l1, eq3, eq2, lt1);
                and S9(l2, eq3, eq2, eq1, lt0);
                or S10(LT, lt3, l0, l1, l2);
            end
        endcase
    endgenerate
endmodule
