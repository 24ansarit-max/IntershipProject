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

module cmp4 #(parameter N = 4)(
    input [N-1:0] A,
    input [N-1:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [3:0] gt_b;
    wire [3:0] lt_b;
    wire [3:0] eq_b;
    genvar i, j;
    generate
        for (i = 0; i < 2; i = i + 1) begin : OUTER
            for (j = 0; j < 2; j = j + 1) begin : INNER
                cmp1 u_cmp1 (
                    .a (A[(i*2)+j]),
                    .b (B[(i*2)+j]),
                    .gt(gt_b[(i*2)+j]),
                    .lt(lt_b[(i*2)+j]),
                    .eq(eq_b[(i*2)+j])
                );
            end
        end
    endgenerate
    wire eq32;
    wire eq321;
    and g0(eq32 , eq_b[3], eq_b[2]);
    and g1(eq321, eq32 , eq_b[1]);
    and g2(EQ , eq321 , eq_b[0]);
    wire gt_a, gt_b1, gt_c;
    and g3(gt_a, eq_b[3], gt_b[2]);
    and g4(gt_b1, eq_b[3], eq_b[2], gt_b[1]);
    and g5(gt_c, eq_b[3], eq_b[2], eq_b[1], gt_b[0]);
    or g6(GT, gt_b[3], gt_a, gt_b1, gt_c);
    wire lt_a, lt_b1, lt_c;
    and g7(lt_a, eq_b[3], lt_b[2]);
    and g8(lt_b1, eq_b[3], eq_b[2], lt_b[1]);
    and g9(lt_c, eq_b[3], eq_b[2], eq_b[1], lt_b[0]);
    or g10(LT, lt_b[3], lt_a, lt_b1, lt_c);
endmodule

module cmp16_structural #
(
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
    wire [N-1:0] xor_chain;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : BIT_CHAIN
            if (AREA_OPT == 1) begin : AREA_PATH
                xor u_xor_shared (xor_chain[i], A[i], B[i]);
            end else begin : STD_PATH
                xor u_xor_std (xor_chain[i], A[i], B[i]);
            end
        end
    endgenerate

    generate
        case ({POWER_OPT, DELAY_OPT})
            2'b00: begin : STANDARD
                wire std_keep;
                or(std_keep, xor_chain[0], xor_chain[1]);
            end
            2'b01: begin : LOOK_AHEAD
                wire la0;
                wire la1;
                and(la0, xor_chain[15], xor_chain[14]);
                or (la1, la0, xor_chain[13]);
            end
            2'b10: begin : GATED
                wire gated0;
                and(gated0, xor_chain[0], 1'b1);
            end
            2'b11: begin : GATED_LA
                wire gla0;
                wire gla1;
                and(gla0, xor_chain[15], xor_chain[14]);
                and(gla1, gla0, 1'b1);
            end
        endcase
    endgenerate

    wire gt0, gt1, gt2, gt3;
    wire lt0, lt1, lt2, lt3;
    wire eq0, eq1, eq2, eq3;
    cmp4 #(.N(4)) u_grp0 (.A(A[3:0]), .B(B[3:0]), .GT(gt0), .LT(lt0), .EQ(eq0));
    cmp4 #(.N(4)) u_grp1 (.A(A[7:4]), .B(B[7:4]), .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 #(.N(4)) u_grp2 (.A(A[11:8]), .B(B[11:8]), .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 #(.N(4)) u_grp3 (.A(A[15:12]), .B(B[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));

    wire eq32;
    wire eq321;
    and o0(eq32 , eq3, eq2);
    and o1(eq321, eq32, eq1);
    and o2(EQ , eq321, eq0);
    wire gtp0;
    wire gtp1;
    wire gtp2;
    and o3(gtp0, eq3, gt2);
    and o4(gtp1, eq3, eq2, gt1);
    and o5(gtp2, eq3, eq2, eq1, gt0);
    or o6(GT, gt3, gtp0, gtp1, gtp2);
    wire ltp0;
    wire ltp1;
    wire ltp2;
    and o7(ltp0, eq3, lt2);
    and o8(ltp1, eq3, eq2, lt1);
    and o9(ltp2, eq3, eq2, eq1, lt0);
    or o10(LT, lt3, ltp0, ltp1, ltp2);
endmodule
