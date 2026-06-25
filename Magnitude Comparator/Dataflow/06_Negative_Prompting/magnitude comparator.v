module comparator16_df (
    input [15:0] A,
    input [15:0] B,
    output A_gt_B,
    output A_lt_B,
    output A_eq_B,
    output A_gte_B,
    output A_lte_B
);

// A greater than B
assign A_gt_B = (A > B); // HIGH when A is greater than B
// A less than B
assign A_lt_B = (A < B); // HIGH when A is less than B
// A equal to B
assign A_eq_B = (A == B); // HIGH when A equals B
// A greater than or equal to B
assign A_gte_B = (A >= B); // HIGH when A is greater than or equal to B
// A less than or equal to B
assign A_lte_B = (A <= B); // HIGH when A is less than or equal to B

endmodule
