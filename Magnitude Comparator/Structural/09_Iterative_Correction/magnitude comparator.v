`timescale 1ns/1ps
module cmp1 (
    input a,
    input b,
    output gt,
    output lt,
    output eq
);
    wire na;
    wire nb;
    wire xab;
    not u0(na, a);
    not u1(nb, b);
    and u2(gt, a, nb);
    and u3(lt, na, b);
    xor u4(xab, a, b);
    not u5(eq, xab);
endmodule

module cmp4 (
    input [3:0] A,
    input [3:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [3:0] gt_b;
    wire [3:0] lt_b;
    wire [3:0] eq_b;
    cmp1 C0(.a(A[0]), .b(B[0]), .gt(gt_b[0]), .lt(lt_b[0]), .eq(eq_b[0]));
    cmp1 C1(.a(A[1]), .b(B[1]), .gt(gt_b[1]), .lt(lt_b[1]), .eq(eq_b[1]));
    cmp1 C2(.a(A[2]), .b(B[2]), .gt(gt_b[2]), .lt(lt_b[2]), .eq(eq_b[2]));
    cmp1 C3(.a(A[3]), .b(B[3]), .gt(gt_b[3]), .lt(lt_b[3]), .eq(eq_b[3]));
    wire eq32;
    wire eq321;
    and U10(eq32 , eq_b[3], eq_b[2]);
    and U11(eq321, eq32 , eq_b[1]);
    and U12(EQ , eq321 , eq_b[0]);
    wire gt0;
    wire gt1;
    wire gt2;
    and U13(gt0, eq_b[3], gt_b[2]);
    and U14(gt1, eq_b[3], eq_b[2], gt_b[1]);
    and U15(gt2, eq_b[3], eq_b[2], eq_b[1], gt_b[0]);
    or U16(GT, gt_b[3], gt0, gt1, gt2);
    wire lt0;
    wire lt1;
    wire lt2;
    and U17(lt0, eq_b[3], lt_b[2]);
    and U18(lt1, eq_b[3], eq_b[2], lt_b[1]);
    and U19(lt2, eq_b[3], eq_b[2], eq_b[1], lt_b[0]);
    or U20(LT, lt_b[3], lt0, lt1, lt2);
endmodule

module cmp16_structural (
    input [15:0] A,
    input [15:0] B,
    output GT,
    output LT,
    output EQ
);
    wire gt0, gt1, gt2, gt3;
    wire lt0, lt1, lt2, lt3;
    wire eq0, eq1, eq2, eq3;
    cmp4 G0 (.A (A[3:0]), .B (B[3:0]), .GT(gt0), .LT(lt0), .EQ(eq0));
    cmp4 G1 (.A (A[7:4]), .B (B[7:4]), .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 G2 (.A (A[11:8]), .B (B[11:8]), .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 G3 (.A (A[15:12]), .B (B[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));
    wire eq32;
    wire eq321;
    and U30(eq32 , eq3 , eq2);
    and U31(eq321, eq32, eq1);
    and U32(EQ , eq321, eq0);
    wire gt_p0;
    wire gt_p1;
    wire gt_p2;
    and U33(gt_p0, eq3, gt2);
    and U34(gt_p1, eq3, eq2, gt1);
    and U35(gt_p2, eq3, eq2, eq1, gt0);
    or U36(GT, gt3, gt_p0, gt_p1, gt_p2);
    wire lt_p0;
    wire lt_p1;
    wire lt_p2;
    and U37(lt_p0, eq3, lt2);
    and U38(lt_p1, eq3, eq2, lt1);
    and U39(lt_p2, eq3, eq2, eq1, lt0);
    or U40(LT, lt3, lt_p0, lt_p1, lt_p2);
endmodule
