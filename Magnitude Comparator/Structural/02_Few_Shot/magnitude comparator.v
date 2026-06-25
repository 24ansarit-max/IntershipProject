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

module cmp4 #
(
    parameter AREA_OPT = 0
)
(
    input [3:0] A,
    input [3:0] B,
    output GT,
    output LT,
    output EQ
);
    wire [3:0] gt_b;
    wire [3:0] lt_b;
    wire [3:0] eq_b;
    wire [3:0] xor_ab;
    generate
        if (AREA_OPT) begin : AREA_PATH
            genvar i,j;
            for(i=0;i<1;i=i+1) begin : GROUP
                for(j=0;j<4;j=j+1) begin : BIT
                    xor (xor_ab[j], A[j], B[j]);
                    assign eq_b[j] = ~xor_ab[j];
                    assign gt_b[j] = A[j] & ~B[j];
                    assign lt_b[j] = ~A[j] & B[j];
                end
            end
        end
        else begin : NORMAL_PATH
            genvar i,j;
            for(i=0;i<1;i=i+1) begin : GROUP
                for(j=0;j<4;j=j+1) begin : BIT
                    cmp1 U (
                        .A (A[j]),
                        .B (B[j]),
                        .GT(gt_b[j]),
                        .LT(lt_b[j]),
                        .EQ(eq_b[j])
                    );
                end
            end
        end
    endgenerate
    assign EQ = eq_b[3] & eq_b[2] & eq_b[1] & eq_b[0];
    assign GT = gt_b[3] | (eq_b[3] & gt_b[2]) | (eq_b[3] & eq_b[2] & gt_b[1]) | (eq_b[3] & eq_b[2] & eq_b[1] & gt_b[0]);
    assign LT = lt_b[3] | (eq_b[3] & lt_b[2]) | (eq_b[3] & eq_b[2] & lt_b[1]) | (eq_b[3] & eq_b[2] & eq_b[1] & lt_b[0]);
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
    wire [N-1:0] diff;
    genvar i;
    generate
        for(i=0;i<N;i=i+1) begin : BIT_STAGE
            xor(diff[i], A[i], B[i]);
        end
    endgenerate

    wire gt0, gt1, gt2, gt3;
    wire lt0, lt1, lt2, lt3;
    wire eq0, eq1, eq2, eq3;
    cmp4 #(.AREA_OPT(AREA_OPT)) G0 (.A(A[3:0]), .B(B[3:0]), .GT(gt0), .LT(lt0), .EQ(eq0));
    cmp4 #(.AREA_OPT(AREA_OPT)) G1 (.A(A[7:4]), .B(B[7:4]), .GT(gt1), .LT(lt1), .EQ(eq1));
    cmp4 #(.AREA_OPT(AREA_OPT)) G2 (.A(A[11:8]), .B(B[11:8]), .GT(gt2), .LT(lt2), .EQ(eq2));
    cmp4 #(.AREA_OPT(AREA_OPT)) G3 (.A(A[15:12]), .B(B[15:12]), .GT(gt3), .LT(lt3), .EQ(eq3));

    generate
        case ({POWER_OPT, AREA_OPT, DELAY_OPT})
            3'b001, 3'b011, 3'b101, 3'b111 : begin : DELAY_MODE
                assign EQ = eq3 & eq2 & eq1 & eq0;
                assign GT = gt3 | (eq3 & gt2) | (eq3 & eq2 & gt1) | (eq3 & eq2 & eq1 & gt0);
                assign LT = lt3 | (eq3 & lt2) | (eq3 & eq2 & lt1) | (eq3 & eq2 & eq1 & lt0);
            end
            3'b010 : begin : AREA_MODE
                assign EQ = eq3 & eq2 & eq1 & eq0;
                assign GT = gt3 | (eq3 & gt2) | (eq3 & eq2 & gt1) | (eq3 & eq2 & eq1 & gt0);
                assign LT = lt3 | (eq3 & lt2) | (eq3 & eq2 & lt1) | (eq3 & eq2 & eq1 & lt0);
            end
            default : begin : DEFAULT_MODE
                assign EQ = eq3 & eq2 & eq1 & eq0;
                assign GT = gt3 | (eq3 & gt2) | (eq3 & eq2 & gt1) | (eq3 & eq2 & eq1 & gt0);
                assign LT = lt3 | (eq3 & lt2) | (eq3 & eq2 & lt1) | (eq3 & eq2 & eq1 & lt0);
            end
        endcase
    endgenerate
endmodule
