`timescale 1ns/1ps
//======================================================
// 16-bit Magnitude Comparator (STRICT DATAFLOW MODEL)
//======================================================
module comparator16_df(
    input [15:0] A,
    input [15:0] B,
    output A_gt_B,
    output A_lt_B,
    output A_eq_B,
    output A_gte_B,
    output A_lte_B,
    output eq_bitwise
);

assign A_eq_B = (A == B);
assign A_gt_B = (A > B);
assign A_lt_B = (A < B);
assign A_gte_B = (A >= B);
assign A_lte_B = (A <= B);
// Bitwise equality check (XNOR all bits then AND reduction)
assign eq_bitwise = &(~(A ^ B));

endmodule
