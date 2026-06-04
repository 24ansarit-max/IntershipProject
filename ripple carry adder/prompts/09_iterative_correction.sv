// =============================================================================
// PROMPT STRATEGY: ITERATIVE CORRECTION
// =============================================================================
// Expert RTL designer: 4-bit Ripple Carry Adder using ITERATIVE CORRECTION.
// Module: rca_4bit_iterative — ports A[3:0], B[3:0], Cin, Sum[3:0], Cout
// Rules:
// - Chain of 4 identical FA instances via generate loop (genvar)
// - Gate-level FA (AND, OR, XOR only) for area estimation
// - Carry-correction stage after initial sum; MAX_ITER = 4
// - Inline AREA / POWER (PG_HINT) / TIMING (CRITICAL_PATH) comments
// - Testbench: all-zeros, all-ones, mid-range, carry-chain stress
// =============================================================================

`timescale 1ns/1ps

/* Estimated PPA:
 * Gate count ~40 | Critical path ~0.8 ns (8 gate delays)
 * Switching: reuse FA cells, localized correction, no clocked logic
 */

module full_adder_gate (
    input  wire a, b, cin,
    output wire sum, cout
);
    wire axb, ab, axb_cin;

    xor (axb, a, b);
    xor (sum, axb, cin);
    and (ab, a, b);
    and (axb_cin, axb, cin);
    or  (cout, ab, axb_cin);
endmodule

module rca_4bit_iterative #(
    parameter integer MAX_ITER = 4
) (
    input  wire [3:0] A, B,
    input  wire       Cin,
    output wire [3:0] Sum,
    output wire       Cout
);
    wire [3:0] sum_raw;
    wire [4:0] carry_raw; // GLITCH_RISK — PG_HINT on carry chain

    assign carry_raw[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : FA_CHAIN
            full_adder_gate fa_inst (
                .a(A[i]), .b(B[i]), .cin(carry_raw[i]),
                .sum(sum_raw[i]), .cout(carry_raw[i+1])
            );
        end
    endgenerate

    wire [3:0] propagate, generate_g;
    assign propagate   = A ^ B;
    assign generate_g  = A & B;

    integer k;
    reg [4:0] carry_corr, next_carry;
    reg [3:0] sum_corr;

    always @(*) begin
        carry_corr = carry_raw;
        next_carry = carry_raw;
        sum_corr   = sum_raw;
        for (k = 0; k < MAX_ITER; k = k + 1) begin
            next_carry[0] = Cin;
            next_carry[1] = generate_g[0] | (propagate[0] & next_carry[0]);
            next_carry[2] = generate_g[1] | (propagate[1] & next_carry[1]);
            next_carry[3] = generate_g[2] | (propagate[2] & next_carry[2]);
            next_carry[4] = generate_g[3] | (propagate[3] & next_carry[3]);
            carry_corr = next_carry;
        end
        sum_corr[0] = propagate[0] ^ carry_corr[0];
        sum_corr[1] = propagate[1] ^ carry_corr[1];
        sum_corr[2] = propagate[2] ^ carry_corr[2];
        sum_corr[3] = propagate[3] ^ carry_corr[3];
    end

    assign Sum  = sum_corr;
    assign Cout = carry_corr[4];
endmodule

module rca_4bit_iterative_tb;
    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    rca_4bit_iterative dut (.A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout));

    task run_test;
        input [3:0] ta, tb;
        input       tcin;
        begin
            A = ta; B = tb; Cin = tcin;
            #5;
            $display("A=%2d B=%2d Cin=%b | Sum=%2d Cout=%b", A, B, Cin, Sum, Cout);
        end
    endtask

    initial begin
        $display("-----------------------------------------");
        $display("RCA 4-bit Iterative Verification");
        $display("-----------------------------------------");
        run_test(4'd0,  4'd0,  1'b0);
        run_test(4'd15, 4'd15, 1'b0);
        run_test(4'd5,  4'd9,  1'b0);
        run_test(4'd6,  4'd10, 1'b1);
        run_test(4'd15, 4'd0,  1'b1);
        run_test(4'd15, 4'd15, 1'b1);
        $display("-----------------------------------------");
        $finish;
    end
endmodule
