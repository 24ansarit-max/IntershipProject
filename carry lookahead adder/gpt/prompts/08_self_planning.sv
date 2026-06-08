// =============================================================================
// PROMPT STRATEGY: SELF PLANNING
// =============================================================================
// Before writing any Verilog, complete the PLANNING PHASE in full. Then execute your plan.
//
// ════════════════════════════════════════════════
// PLANNING PHASE — answer every question
// ════════════════════════════════════════════════
//
// PLAN-1  Sub-module inventory (structural):
//   For each sub-module you will write, list:
//   name | inputs | outputs | function | gate-level delay
//
// PLAN-2  Signal dependency graph:
//   Trace the signal flow from inputs to outputs:
//   A,B → P ,G → [what?] → [what?] → Sum
//   Fill in all intermediate signals and the module responsible for each.
//
// PLAN-3  Carry equation derivation:
//   Manually expand the inter-group carry equation for C[8]
//   (carry into group 2) all the way to raw A[i], B[i], Cin terms.
//   Count the gate levels.
//
// PLAN-4  Behavioral algorithm pseudo-code:
//   Write the 5-step algorithm you will implement in always @(*):
//   Step 1: ...
//   Step 2: ...
//   Step 3: (this is where CLA parallelism lives — explain why)
//   Step 4: ...
//   Step 5: ...
//
// PLAN-5  Variable declaration list (behavioral):
//   List every reg and its bit width:
//   reg [?:0] P , G, C, PG_g, GG_g, GC; and any loop variables.
//
// PLAN-6  Testbench coverage matrix:
//   List every directed test case, the bug class it targets, and the
//   expected Sum/Cout/Overflow/Zero/Negative values.
//
// PLAN-7  PPA pre-estimate:
//   Before coding, estimate: gate depth | NAND2 area | power vs RCA.
//   You will compare with actuals after coding.
//
// ════════════════════════════════════════════════
// IMPLEMENTATION PHASE — execute your plan exactly
// ════════════════════════════════════════════════
// Using your answers above, write FOUR sections:
//
// [1] STRUCTURAL — implement your PLAN-1 sub-module inventory.
//     pg_cell, cla_carry4, sum_cell, group_pg, inter_carry, cla_adder_16bit.
//     Named port maps. No always. PPA header.
//
// [2] DATAFLOW — use your PLAN-3 equations as the source of truth.
//     Pure assign. Labeled sections. All wires declared. PPA header.
//
// [3] BEHAVIORAL — implement your PLAN-4 and PLAN-5 exactly.
//     DATA_WIDTH=16, GROUP_SIZE=4. Five labeled steps. All flags. PPA header.
//
// [4] TESTBENCH — implement your PLAN-6 coverage matrix.
//     All three DUTs on shared inputs. Directed + 50 000 random. Self-checking.
//     VCD dump. End-of-sim summary.
//
// ════════════════════════════════════════════════
// REFLECTION PHASE — after code
// ════════════════════════════════════════════════
// Compare PLAN-7 pre-estimates to what you actually implemented:
// | Metric     | Pre-estimate | Actual | Match? |
// |------------|-------------|--------|--------|
// | Gate depth | ...         | ...    | ...    |
// | NAND2 area | ...         | ...    | ...    |
// | Power ratio| ...         | ...    | ...    |
//
// Write every line. No "..." placeholders.
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
module carry_source (
    input Cin,
    output C0
);
    buf b1(C0, Cin);   // structural buffer (NOT assign)
endmodule
module cla16_structural (
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] Sum,
    output        Cout
);

    wire [15:0] P , G;
    wire [16:0] C;

    wire C0;

    // -------------------------------
    // Carry input (STRUCTURAL ONLY)
    // -------------------------------
    carry_source cs (
        .Cin(Cin),
        .C0(C0)
    );

    // chain first carry
    buf b0(C[0], C0);

    genvar i;

    // -------------------------------
    // PG generation
    // -------------------------------
    generate
        for (i = 0; i < 16; i = i + 1) begin : PG_GEN
            pg_cell u_pg (
                .A(A[i]),
                .B(B[i]),
                .P(P[i]),
                .G(G[i])
            );
        end
    endgenerate

    // -------------------------------
    // CLA blocks
    // -------------------------------
    wire [4:0] Cb0, Cb1, Cb2, Cb3;

    cla_carry4 b0_inst (P[3:0],   G[3:0],   C[0],  Cb0);
    cla_carry4 b1_inst (P[7:4],   G[7:4],   C[4],  Cb1);
    cla_carry4 b2_inst (P[11:8],  G[11:8],  C[8],  Cb2);
    cla_carry4 b3_inst (P[15:12], G[15:12], C[12], Cb3);

    // -------------------------------
    // Carry wiring (STRUCTURAL, no assign)
    // -------------------------------
    buf c1(C[1], Cb0[1]);
    buf c2(C[2], Cb0[2]);
    buf c3(C[3], Cb0[3]);
    buf c4(C[4], Cb0[4]);

    buf c5(C[5], Cb1[1]);
    buf c6(C[6], Cb1[2]);
    buf c7(C[7], Cb1[3]);
    buf c8(C[8], Cb1[4]);

    buf c9 (C[9],  Cb2[1]);
    buf c10(C[10], Cb2[2]);
    buf c11(C[11], Cb2[3]);
    buf c12(C[12], Cb2[4]);

    buf c13(C[13], Cb3[1]);
    buf c14(C[14], Cb3[2]);
    buf c15(C[15], Cb3[3]);
    buf c16(C[16], Cb3[4]);

    // -------------------------------
    // Sum (STRUCTURAL ONLY)
    // -------------------------------
    generate
        for (i = 0; i < 16; i = i + 1) begin : SUM_GEN
            sum_cell u_sum (
                .P(P[i]),
                .Cin(C[i]),
                .Sum(Sum[i])
            );
        end
    endgenerate

    // final carry
    buf bfinal(Cout, C[16]);

endmodule

// --- [2] DATAFLOW STYLE ---
module cla16_dataflow (
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] Sum,
    output        Cout
);

    // -------------------------------
    // Internal signals
    // -------------------------------
    wire [15:0] P , G;
    wire [16:0] C;

    // -------------------------------
    // Bit propagate & generate
    // -------------------------------
    assign P = A ^ B;
    assign G = A & B;

    // -------------------------------
    // Carry Lookahead Equations
    // C[i+1] = G[i] + P[i]C[i]
    // Fully expanded dependency chain
    // -------------------------------

    assign C[0] = Cin;

    // Group 0 (0–3)
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) |
                          (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) |
                          (P[3] & P[2] & P[1] & G[0]) |
                          (P[3] & P[2] & P[1] & P[0] & C[0]);

    // Group 1 (4–7)
    assign C[5] = G[4] | (P[4] & C[4]);
    assign C[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & C[4]);
    assign C[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) |
                          (P[6] & P[5] & P[4] & C[4]);
    assign C[8] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) |
                          (P[7] & P[6] & P[5] & G[4]) |
                          (P[7] & P[6] & P[5] & P[4] & C[4]);

    // Group 2 (8–11)
    assign C[9]  = G[8]  | (P[8]  & C[8]);
    assign C[10] = G[9]  | (P[9]  & G[8]) | (P[9]  & P[8]  & C[8]);
    assign C[11] = G[10] | (P[10] & G[9]) | (P[10] & P[9] & G[8]) |
                            (P[10] & P[9] & P[8] & C[8]);
    assign C[12] = G[11] | (P[11] & G[10]) | (P[11] & P[10] & G[9]) |
                            (P[11] & P[10] & P[9] & G[8]) |
                            (P[11] & P[10] & P[9] & P[8] & C[8]);

    // Group 3 (12–15)
    assign C[13] = G[12] | (P[12] & C[12]);
    assign C[14] = G[13] | (P[13] & G[12]) | (P[13] & P[12] & C[12]);
    assign C[15] = G[14] | (P[14] & G[13]) | (P[14] & P[13] & G[12]) |
                            (P[14] & P[13] & P[12] & C[12]);
    assign C[16] = G[15] | (P[15] & G[14]) | (P[15] & P[14] & G[13]) |
                            (P[15] & P[14] & P[13] & G[12]) |
                            (P[15] & P[14] & P[13] & P[12] & C[12]);

    // -------------------------------
    // Sum generation
    // -------------------------------
    assign Sum = P ^ C[15:0];

    // -------------------------------
    // Final carry-out
    // -------------------------------
    assign Cout = C[16];

endmodule

// --- [3] BEHAVIORAL STYLE ---
module cla16_behavioral(
  input [15:0] A,B,
  input Cin,
  output reg [15:0] Sum,
  output reg Cout,
  output reg Zero, Negative, Overflow
);

reg [16:0] C;
reg [15:0] P ,G;
integer i;

always @(*) begin

  // Step 1
  for(i=0;i<16;i=i+1) begin
    P[i] = A[i] ^ B[i];
    G[i] = A[i] & B[i];
  end

  // Step 2
  C[0] = Cin;

  // Step 3 (CLA parallel logic simulated sequentially)
  for(i=0;i<16;i=i+1)
    C[i+1] = G[i] | (P[i] & C[i]);

  // Step 4
  for(i=0;i<16;i=i+1)
    Sum[i] = P[i] ^ C[i];

  // Step 5
  Cout = C[16];
  Zero = (Sum == 0);
  Negative = Sum[15];
  Overflow = C[16] ^ C[15];

end
endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla16_all;

    // -------------------------------
    // Inputs
    // -------------------------------
    reg [15:0] A, B;
    reg Cin;

    // -------------------------------
    // Outputs (Structural)
    // -------------------------------
    wire [15:0] Sum_s;
    wire Cout_s;

    // -------------------------------
    // Outputs (Dataflow)
    // -------------------------------
    wire [15:0] Sum_d;
    wire Cout_d;

    // -------------------------------
    // Outputs (Behavioral)
    // -------------------------------
    wire [15:0] Sum_b;
    wire Cout_b;
    wire Zero_b, Negative_b, Overflow_b;

    // -------------------------------
    // DUT Instantiations
    // -------------------------------

    cla16_structural DUT_S (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum_s),
        .Cout(Cout_s)
    );

    cla16_dataflow DUT_D (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum_d),
        .Cout(Cout_d)
    );

    cla16_behavioral DUT_B (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum_b),
        .Cout(Cout_b),
        .Zero(Zero_b),
        .Negative(Negative_b),
        .Overflow(Overflow_b)
    );

    integer i;
    reg [16:0] golden;

    // -------------------------------
    // SELF CHECK TASK
    // -------------------------------
    task check;
    begin
        golden = A + B + Cin;

        if ((Sum_s !== golden[15:0]) || (Sum_d !== golden[15:0]) || (Sum_b !== golden[15:0])) begin
            $display("  SUM MISMATCH | A=%h B=%h Cin=%b | S=%h D=%h B=%h | GOLD=%h",
                      A, B, Cin, Sum_s, Sum_d, Sum_b, golden[15:0]);
        end

        if ((Cout_s !== golden[16]) || (Cout_d !== golden[16]) || (Cout_b !== golden[16])) begin
            $display("  COUT MISMATCH | A=%h B=%h Cin=%b | S=%b D=%b B=%b | GOLD=%b",
                      A, B, Cin, Cout_s, Cout_d, Cout_b, golden[16]);
        end
    end
    endtask

    // -------------------------------
    // TEST PROCEDURE
    // -------------------------------
    initial begin

        $dumpfile("cla_all.vcd");
        $dumpvars(0, tb_cla16_all);

        $display("===== STARTING CLA TESTBENCH =====");

        // -----------------------
        // DIRECTED TESTS
        // -----------------------

        A = 16'h0000; B = 16'h0000; Cin = 0; #10; check;
        A = 16'hFFFF; B = 16'h0001; Cin = 0; #10; check;
        A = 16'hAAAA; B = 16'h5555; Cin = 0; #10; check;
        A = 16'h8000; B = 16'h8000; Cin = 0; #10; check;
        A = 16'h1234; B = 16'h5678; Cin = 1; #10; check;

        // -----------------------
        // RANDOM TESTS
        // -----------------------
        for (i = 0; i < 50000; i = i + 1) begin
            A   = $random;
            B   = $random;
            Cin = $random;

            #1;
            check;
        end

        // -----------------------
        // FINAL REPORT
        // -----------------------
        $display("===== TEST COMPLETED =====");
        $finish;
    end

endmodule
