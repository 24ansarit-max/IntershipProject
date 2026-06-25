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

module cmp4
#(
    parameter N = 4,
    parameter AREA_OPT = 0
)
(
    input [N-1:0] A,
    input [N-1:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [N-1:0] gt_b;
    wire [N-1:0] lt_b;
    wire [N-1:0] eq_b;
    genvar i;
    genvar j;
    generate
        if (AREA_OPT) begin : AREA_PATH
            wire [N-1:0] xor_bus;
            for (i=0; i<2; i=i+1) begin : OUTER_AREA
                for (j=0; j<2; j=j+1) begin : INNER_AREA
                    xor GX (xor_bus[(i*2)+j], A[(i*2)+j], B[(i*2)+j]);
                    not GE (eq_b[(i*2)+j], xor_bus[(i*2)+j]);
                    wire na;
                    wire nb;
                    not GN0(na, A[(i*2)+j]);
                    not GN1(nb, B[(i*2)+j]);
                    and GGT(gt_b[(i*2)+j], A[(i*2)+j], nb);
                    and GLT(lt_b[(i*2)+j], na, B[(i*2)+j]);
                end
            end
        end
        else begin : STD_PATH
            for (i=0; i<2; i=i+1) begin : OUTER_STD
                for (j=0; j<2; j=j+1) begin : INNER_STD
                    cmp1 U_CMP1 (.a(A[(i*2)+j]), .b(B[(i*2)+j]), .gt(gt_b[(i*2)+j]), .lt(lt_b[(i*2)+j]), .eq(eq_b[(i*2)+j]));
                end
            end
        end
    endgenerate
    wire eq32;
    wire eq321;
    and U10(eq32 , eq_b[3], eq_b[2]);
    and U11(eq321, eq32 , eq_b[1]);
    and U12(EQ , eq321 , eq_b[0]);
    wire gt_p0;
    wire gt_p1;
    wire gt_p2;
    and U13(gt_p0, eq_b[3], gt_b[2]);
    and U14(gt_p1, eq_b[3], eq_b[2], gt_b[1]);
    and U15(gt_p2, eq_b[3], eq_b[2], eq_b[1], gt_b[0]);
    or U16(GT, gt_b[3], gt_p0, gt_p1, gt_p2);
    wire lt_p0;
    wire lt_p1;
    wire lt_p2;
    and U17(lt_p0, eq_b[3], lt_b[2]);
    and U18(lt_p1, eq_b[3], eq_b[2], lt_b[1]);
    and U19(lt_p2, eq_b[3], eq_b[2], eq_b[1], lt_b[0]);
    or U20(LT, lt_b[3], lt_p0, lt_p1, lt_p2);
endmodule

module cmp16_structural
#(
    parameter N = 16,
    parameter POWER_OPT = 0,
    parameter AREA_OPT = 0,
    parameter DELAY_OPT = 0
)
(
    input [N-1:0] A,
    input [N-1:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [N-1:0] A_INT;
    wire [N-1:0] B_INT;
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin : BIT_CHAIN
            if (AREA_OPT == 1) begin : AREA_PATH
                xor GX (A_INT[i], A[i], 1'b0);
                xor GY (B_INT[i], B[i], 1'b0);
            end
            else begin : STD_PATH
                or GX (A_INT[i], A[i], 1'b0);
                or GY (B_INT[i], B[i], 1'b0);
            end
        end
    endgenerate

    generate
        case ({POWER_OPT, DELAY_OPT})
            2'b00 : begin : STANDARD
                wire std_keep;
                or G0(std_keep, A_INT[0], B_INT[0]);
            end
            2'b01 : begin : LOOK_AHEAD
                wire la0;
                wire la1;
                and G1(la0, A_INT[N-1], B_INT[N-1]);
                or G2(la1, la0, A_INT[N-2]);
            end
            2'b10 : begin : GATED
                wire gate0;
                and G3(gate0, A_INT[0], 1'b1);
            end
            2'b11 : begin : GATED_LA
                wire gla0;
                wire gla1;
                and G4(gla0, A_INT[N-1], 1'b1);
                and G5(gla1, B_INT[N-1], 1'b1);
            end
        endcase
    endgenerate

    wire gt0;
    wire gt1;
    wire gt2;
    wire gt3;
    wire lt0;
    wire lt1;
    wire lt2;
    wire lt3;
    wire eq0;
    wire eq1;
    wire eq2;
    wire eq3;
    cmp4 #(.N(4), .AREA_OPT(AREA_OPT)) u_grp0 (.A (A_INT[3:0]), .B (B_INT[3:0]), .GT(gt0), .LT(lt0), .EQ(eq0));
    cmp4 #(.N(4), .AREA_OPT(AREA_OPT)) u_grp1 (.A (A_INT[7:4]), .B (B_INT[7:4]), .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 #(.N(4), .AREA_OPT(AREA_OPT)) u_grp2 (.A (A_INT[11:8]), .B (B_INT[11:8]), .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 #(.N(4), .AREA_OPT(AREA_OPT)) u_grp3 (.A (A_INT[15:12]), .B (B_INT[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));

    wire eq32;
    wire eq321;
    and F0(eq32 , eq3, eq2);
    and F1(eq321, eq32, eq1);
    and F2(EQ , eq321, eq0);
    wire gt_p0;
    wire gt_p1;
    wire gt_p2;
    and F3(gt_p0, eq3, gt2);
    and F4(gt_p1, eq3, eq2, gt1);
    and F5(gt_p2, eq3, eq2, eq1, gt0);
    or F6(GT, gt3, gt_p0, gt_p1, gt_p2);
    wire lt_p0;
    wire lt_p1;
    wire lt_p2;
    and F7(lt_p0, eq3, lt2);
    and F8(lt_p1, eq3, eq2, lt1);
    and F9(lt_p2, eq3, eq2, eq1, lt0);
    or F10(LT, lt3, lt_p0, lt_p1, lt_p2);
endmodule
