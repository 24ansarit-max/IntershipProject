`timescale 1ns/1ps
module cmp1(
    input A,
    input B,
    output GT,
    output LT,
    output EQ
);
    wire nA, nB, x1;
    not (nA, A);
    not (nB, B);
    and (GT, A, nB);
    and (LT, nA, B);
    xor (x1, A, B);
    not (EQ, x1);
endmodule

module cmp4(
    input [3:0] A,
    input [3:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [3:0] gt_b;
    wire [3:0] lt_b;
    wire [3:0] eq_b;
    
    genvar i;
    generate
        for(i=0; i<4; i=i+1) begin : BIT_STAGE
            cmp1 U (
                .A (A[i]),
                .B (B[i]),
                .GT(gt_b[i]),
                .LT(lt_b[i]),
                .EQ(eq_b[i])
            );
        end
    endgenerate

    assign EQ = eq_b[3] & eq_b[2] & eq_b[1] & eq_b[0];
    assign GT = gt_b[3] | (eq_b[3] & gt_b[2]) | (eq_b[3] & eq_b[2] & gt_b[1]) | (eq_b[3] & eq_b[2] & eq_b[1] & gt_b[0]);
    assign LT = lt_b[3] | (eq_b[3] & lt_b[2]) | (eq_b[3] & eq_b[2] & lt_b[1]) | (eq_b[3] & eq_b[2] & eq_b[1] & lt_b[0]);
endmodule

module cmp16_structural #
(
    parameter N = 16
)
(
    input [N-1:0] A,
    input [N-1:0] B,
    output GT,
    output LT,
    output EQ
);
    wire gt3, gt2, gt1, gt0;
    wire lt3, lt2, lt1, lt0;
    wire eq3, eq2, eq1, eq0;

    cmp4 G3(.A(A[15:12]), .B(B[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));
    cmp4 G2(.A(A[11:8]),  .B(B[11:8]),  .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 G1(.A(A[7:4]),   .B(B[7:4]),   .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 G0(.A(A[3:0]),   .B(B[3:0]),   .GT(gt0), .LT(lt0), .EQ(eq0));

    assign EQ = eq3 & eq2 & eq1 & eq0;
    assign GT = gt3 | (eq3 & gt2) | (eq3 & eq2 & gt1) | (eq3 & eq2 & eq1 & gt0);
    assign LT = lt3 | (eq3 & lt2) | (eq3 & eq2 & lt1) | (eq3 & eq2 & eq1 & lt0);
endmodule
