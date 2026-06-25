module comparator16_df(
    input [15:0] A,
    input [15:0] B,
    output A_gt_B,
    output A_lt_B,
    output A_eq_B,
    output A_gte_B,
    output A_lte_B
);

// One-hot property:
// Exactly one of A_gt_B, A_lt_B, or A_eq_B must be HIGH
// for any valid comparison of A and B.

assign A_gt_B = (A > B);
assign A_lt_B = (A < B);
assign A_eq_B = (A == B);
assign A_gte_B = (A >= B);
assign A_lte_B = (A <= B);

// Algebraic verification:
// A_gte_B = A_gt_B | A_eq_B
// A_lte_B = A_lt_B | A_eq_B

endmodule
