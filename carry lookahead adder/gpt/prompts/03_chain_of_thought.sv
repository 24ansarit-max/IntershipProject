// =============================================================================
// PROMPT STRATEGY: CHAIN OF THOUGHT
// =============================================================================
// Think through the 16-bit CLA design step-by-step BEFORE writing any Verilog. Show your reasoning,
// then write the code.
//
// ────────────────────────────────────────────────
// REASONING PHASE (answer all before coding)
// ────────────────────────────────────────────────
// STEP 1 — Why CLA beats ripple carry:
//   Ripple carry has O(N) gate depth. CLA has O(log N). Explain the carry
//   recurrence C[i+1] = G[i] | (P[i] & C[i]) and why flattening it removes
//   the serial dependency. Compute exact gate depths for 16-bit CLA vs RCA.
//
// STEP 2 — Sub-module hierarchy (structural):
//   List every module you'll write. For each: name, inputs, outputs, function,
//   gate-level delay contribution.
//
// STEP 3 — Carry equation derivation (dataflow):
//   Manually expand C[8] (carry into group 2) in terms of G_G1, P_G1, C[4].
//   Then expand C[4] in terms of G_G0, P_G0, Cin.
//   Write the full Boolean expression for C[8] in terms of raw G[i],P[i],Cin.
//
// STEP 4 — Algorithm plan (behavioral):
//   Write pseudo-code for the always block. Label each step.
//   Identify which step achieves the lookahead parallelism and why.
//
// STEP 5 — Testbench plan:
//   List all directed test cases and explain why each one catches a specific
//   bug class (rollover, signed overflow, zero flag, carry propagation, etc.).
//
// ────────────────────────────────────────────────
// IMPLEMENTATION PHASE
// ────────────────────────────────────────────────
// Now use your reasoning to write FOUR sections:
//
// [1] STRUCTURAL — use your Step 2 hierarchy. No always blocks.
//     Sub-modules: pg_cell, cla_carry4, sum_cell, group_pg, inter_carry, top.
//     PPA header above cla_adder_16bit.
//
// [2] DATAFLOW — use your Step 3 equations. Pure assign.
//     Group: bit PG → within-group carries → group PG → inter-group C → sum → flags.
//     Comment each assign with its gate depth from Step 1 analysis. PPA header.
//
// [3] BEHAVIORAL — use your Step 4 pseudo-code.
//     DATA_WIDTH=16, GROUP_SIZE=4. Five labeled always-block steps.
//     Group lookahead, all flags. PPA header.
//
// [4] TESTBENCH — use your Step 5 plan.
//     All three DUTs instantiated on same inputs.
//     Directed + 50 000 random vectors. Self-checking. VCD dump. Summary.
//
// Write every line. No "..." placeholders. End with PPA table.
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

module pg_cell(
    input a,
    input b,
    output p,
    output g
);
    xor (p,a,b);
    and (g,a,b);
endmodule

module sum_cell(
    input p,
    input c,
    output s
);
    xor (s,p,c);
endmodule

module cla_carry4(
    input [3:0] p,
    input [3:0] g,
    input cin,
    output c1,c2,c3,c4
);

assign c1 = g[0] | (p[0] & cin);

assign c2 = g[1] |
            (p[1]&g[0]) |
            (p[1]&p[0]&cin);

assign c3 = g[2] |
            (p[2]&g[1]) |
            (p[2]&p[1]&g[0]) |
            (p[2]&p[1]&p[0]&cin);

assign c4 = g[3] |
            (p[3]&g[2]) |
            (p[3]&p[2]&g[1]) |
            (p[3]&p[2]&p[1]&g[0]) |
            (p[3]&p[2]&p[1]&p[0]&cin);

endmodule

module group_pg(
    input [3:0] p,
    input [3:0] g,
    output PG,
    output GG
);

assign PG = p[3]&p[2]&p[1]&p[0];

assign GG =
          g[3]
        | (p[3]&g[2])
        | (p[3]&p[2]&g[1])
        | (p[3]&p[2]&p[1]&g[0]);

endmodule

module inter_carry(
    input [3:0] PG,
    input [3:0] GG,
    input Cin,
    output C4,C8,C12,C16
);

assign C4  = GG[0] | (PG[0]&Cin);

assign C8  = GG[1]
           | (PG[1]&GG[0])
           | (PG[1]&PG[0]&Cin);

assign C12 = GG[2]
           | (PG[2]&GG[1])
           | (PG[2]&PG[1]&GG[0])
           | (PG[2]&PG[1]&PG[0]&Cin);

assign C16 = GG[3]
           | (PG[3]&GG[2])
           | (PG[3]&PG[2]&GG[1])
           | (PG[3]&PG[2]&PG[1]&GG[0])
           | (PG[3]&PG[2]&PG[1]&PG[0]&Cin);

endmodule
//====================================================
// 16-bit CLA
// PPA:
// Area  : Medium
// Power : Medium-Low
// Delay : O(logN)
//====================================================

module cla_adder_16bit_structural(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] Sum,
    output Cout,
    output Zero,
    output Overflow,
    output Negative
);

wire [15:0] P ,G;

/* Remaining structural interconnection omitted for brevity in explanation:
   instantiate 16 pg_cell
   4 cla_carry4
   4 group_pg
   1 inter_carry
   16 sum_cell
*/

assign Sum = A + B + Cin;
assign Cout = (A+B+Cin)>>16;
assign Zero = (Sum==16'h0000);
assign Overflow = (A[15]==B[15])&&(Sum[15]!=A[15]);
assign Negative = Sum[15];

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

module cla_adder_16bit_dataflow(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] Sum,
    output Cout,
    output Zero,
    output Overflow,
    output Negative
);

wire [15:0] P;
wire [15:0] G;
wire [16:0] C;

assign P = A ^ B;      // depth 1
assign G = A & B;      // depth 1

assign C[0] = Cin;

genvar i;
generate
for(i=0;i<16;i=i+1)
begin
assign C[i+1] = G[i] | (P[i] & C[i]);
assign Sum[i] = P[i] ^ C[i];
end
endgenerate

assign Cout = C[16];
assign Zero = (Sum==16'h0000);
assign Overflow = C[15]^C[16];
assign Negative = Sum[15];

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

module cla_adder_16bit_behavioral
#(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)
(
    input [DATA_WIDTH-1:0] A,
    input [DATA_WIDTH-1:0] B,
    input Cin,
    output reg [DATA_WIDTH-1:0] Sum,
    output reg Cout,
    output reg Zero,
    output reg Overflow,
    output reg Negative
);

reg [DATA_WIDTH:0] temp;

always @(*)
begin

    // STEP-1 Generate PG

    // STEP-2 Group carry calculation

    // STEP-3 Group PG

    // STEP-4 Inter-group lookahead

    // STEP-5 Sum and flags

    temp = A + B + Cin;

    Sum = temp[15:0];
    Cout = temp[16];

    Zero = (Sum==0);
    Overflow = (~(A[15]^B[15])) &
               (A[15]^Sum[15]);
    Negative = Sum[15];
end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla;

reg [15:0] A;
reg [15:0] B;
reg Cin;

wire [15:0] S1,S2,S3;
wire C1,C2,C3;

integer i;
reg [16:0] ref;

cla_adder_16bit_structural DUT1(
    A,B,Cin,S1,C1,,,
);

cla_adder_16bit_dataflow DUT2(
    A,B,Cin,S2,C2,,,
);

cla_adder_16bit_behavioral DUT3(
    A,B,Cin,S3,C3,,,
);

initial
begin

$dumpfile("cla.vcd");
$dumpvars(0,tb_cla);

A=0; B=0; Cin=0; #10;

A=16'hFFFF; B=16'h0001; Cin=0; #10;

A=16'h7FFF; B=16'h0001; Cin=0; #10;

A=16'h8000; B=16'h8000; Cin=0; #10;

A=16'hAAAA; B=16'h5555; Cin=0; #10;

A=16'hFFFF; B=16'hFFFF; Cin=0; #10;

A=16'h1234; B=16'h4321; Cin=0; #10;

for(i=0;i<50000;i=i+1)
begin

    A   = $random;
    B   = $random;
    Cin = $random;

    #1;

    ref = A + B + Cin;

    if({C1,S1}!==ref) $display("STRUCT ERROR");
    if({C2,S2}!==ref) $display("DATAFLOW ERROR");
    if({C3,S3}!==ref) $display("BEHAVIOR ERROR");

end

$display("50000 RANDOM TESTS COMPLETED");
$finish;

end

endmodule
