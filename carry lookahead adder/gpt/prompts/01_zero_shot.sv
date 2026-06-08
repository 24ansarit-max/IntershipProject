// =============================================================================
// PROMPT STRATEGY: ZERO SHOT
// =============================================================================
// You are an expert RTL engineer. Write a complete 16-bit Carry Lookahead Adder (CLA) in Verilog.
//
// Deliver FOUR sections in this exact order:
//   [1] STRUCTURAL style
//   [2] DATAFLOW style
//   [3] BEHAVIORAL style
//   [4] SELF-CHECKING TESTBENCH
//
// ────────────────────────────────────────────────
// COMMON SPEC (all three modules must share this)
// ────────────────────────────────────────────────
// Module name : cla_adder_16bit
// Parameters  : DATA_WIDTH = 16, GROUP_SIZE = 4
// Ports       : input  [DATA_WIDTH-1:0] A, B
//               input  Cin
//               output [DATA_WIDTH-1:0] Sum
//               output Cout, Overflow, Zero, Negative
// Architecture: Two-level CLA — four 4-bit groups.
//               Group-level P/G used to compute inter-group carries.
//               NOT a ripple-carry adder.
// Flags       : Overflow = C[DATA_WIDTH-1] ^ C[DATA_WIDTH]
//               Zero     = ~|Sum
//               Negative = Sum[DATA_WIDTH-1]
// Language    : Verilog-2001 only. No SystemVerilog.
//
// ────────────────────────────────────────────────
// [1] STRUCTURAL STYLE RULES
// ────────────────────────────────────────────────
// - No always blocks. No assign at top level.
// - Define sub-modules: pg_cell, cla_carry4, sum_cell, group_pg, inter_carry
// - Top module instantiates all sub-modules using named port mapping
// - Add PPA header comment: Delay (gate levels), Area (~NAND2 eq), Power vs RCA
//
// ────────────────────────────────────────────────
// [2] DATAFLOW STYLE RULES
// ────────────────────────────────────────────────
// - Only assign statements — zero always/initial/task blocks
// - Declare all intermediate wires before use
// - Comment each assign with its Boolean equation
// - Add PPA header comment
//
// ────────────────────────────────────────────────
// [3] BEHAVIORAL STYLE RULES
// ────────────────────────────────────────────────
// - Single always @(*) block, no latches
// - Use for-loops for P/G computation and carry fill
// - Internal regs: P , G, C[DATA_WIDTH:0], PG/GG/GC arrays
// - Add PPA header comment
//
// ────────────────────────────────────────────────
// [4] TESTBENCH RULES
// ────────────────────────────────────────────────
// - Name: tb_cla_adder_16bit
// - Instantiate all THREE DUTs (dut_struct, dut_data, dut_beh) on same inputs
// - Directed tests: all-zeros, all-ones, rollover, signed overflow, checkerboard,
//   single-bit sweep A (i=0..15), single-bit sweep B (i=0..15), Cin=0 and Cin=1
// - Random tests: 50 000 vectors using $random; reference = A+B+Cin integer
// - Self-checking: $display FAIL with A,B,Cin,Got,Expected on mismatch
// - End: print Directed pass/total, Random pass/50000, overall PASS or FAIL
// - Dump VCD: $dumpfile / $dumpvars
// - Plain Verilog-2001 only
//
// Write every line of every module — no "..." placeholders.
// End with a PPA comparison table: Style | Gate depth | ~NAND2 area | Power vs RCA
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

//==============================================================
// STRUCTURAL 16-bit CLA
// Architecture:
//   - Four 4-bit CLA groups
//   - Group Propagate / Generate
//   - Inter-group carry lookahead
//
// PPA ESTIMATE
// -------------------------------------------------------------
// Delay  : ~6-7 gate levels
// Area   : ~180 NAND2 equivalent gates
// Power  : Lower than RCA due to reduced carry-chain activity
//==============================================================



//==============================================================
// pg_cell
// Bit propagate and generate
//
// P = A ^ B
// G = A & B
//==============================================================
module pg_cell
(
    input  A,
    input  B,
    output P ,
    output G
);

    xor (P , A, B);
    and (G, A, B);

endmodule



//==============================================================
// cla_carry4
//
// Computes:
//
// C1 = G0 + P0C0
//
// C2 = G1 + P1G0 + P1P0C0
//
// C3 = G2 + P2G1 + P2P1G0 + P2P1P0C0
//
// C4 = G3 + P3G2 + P3P2G1 +
//      P3P2P1G0 +
//      P3P2P1P0C0
//==============================================================
module cla_carry4
(
    input  [3:0] P ,
    input  [3:0] G,
    input        Cin,

    output       C1,
    output       C2,
    output       C3,
    output       C4
);

    wire t10;

    wire t20;
    wire t21;

    wire t30;
    wire t31;
    wire t32;

    wire t40;
    wire t41;
    wire t42;
    wire t43;

    //----------------------------------------------------------
    // C1
    //----------------------------------------------------------
    and (t10, P[0], Cin);
    or  (C1, G[0], t10);

    //----------------------------------------------------------
    // C2
    //----------------------------------------------------------
    and (t20, P[1], G[0]);
    and (t21, P[1], P[0], Cin);

    or (C2,
        G[1],
        t20,
        t21);

    //----------------------------------------------------------
    // C3
    //----------------------------------------------------------
    and (t30, P[2], G[1]);
    and (t31, P[2], P[1], G[0]);
    and (t32, P[2], P[1], P[0], Cin);

    or (C3,
        G[2],
        t30,
        t31,
        t32);

    //----------------------------------------------------------
    // C4
    //----------------------------------------------------------
    and (t40, P[3], G[2]);

    and (t41,
         P[3],
         P[2],
         G[1]);

    and (t42,
         P[3],
         P[2],
         P[1],
         G[0]);

    and (t43,
         P[3],
         P[2],
         P[1],
         P[0],
         Cin);

    or (C4,
        G[3],
        t40,
        t41,
        t42,
        t43);

endmodule



//==============================================================
// sum_cell
//
// Sum = P XOR Cin
//==============================================================
module sum_cell
(
    input  P ,
    input  Cin,
    output Sum
);

    xor (Sum, P , Cin);

endmodule



//==============================================================
// group_pg
//
// Group Propagate
// PG = P3P2P1P0
//
// Group Generate
// GG = G3 +
//      P3G2 +
//      P3P2G1 +
//      P3P2P1G0
//==============================================================
module group_pg
(
    input  [3:0] P ,
    input  [3:0] G,

    output PG,
    output GG
);

    wire t0;
    wire t1;
    wire t2;

    //----------------------------------------------------------
    // PG
    //----------------------------------------------------------
    and (PG,
         P[3],
         P[2],
         P[1],
         P[0]);

    //----------------------------------------------------------
    // GG
    //----------------------------------------------------------
    and (t0,
         P[3],
         G[2]);

    and (t1,
         P[3],
         P[2],
         G[1]);

    and (t2,
         P[3],
         P[2],
         P[1],
         G[0]);

    or (GG,
        G[3],
        t0,
        t1,
        t2);

endmodule



//==============================================================
// inter_carry
//
// Group carries:
//
// GC1 = GG0 + PG0*Cin
//
// GC2 = GG1 +
//       PG1GG0 +
//       PG1PG0Cin
//
// GC3 = GG2 +
//       PG2GG1 +
//       PG2PG1GG0 +
//       PG2PG1PG0Cin
//
// GC4 = Final Cout
//==============================================================
module inter_carry
(
    input  [3:0] PG,
    input  [3:0] GG,
    input        Cin,

    output       GC1,
    output       GC2,
    output       GC3,
    output       GC4
);

    wire t10;

    wire t20;
    wire t21;

    wire t30;
    wire t31;
    wire t32;

    wire t40;
    wire t41;
    wire t42;
    wire t43;

    //----------------------------------------------------------
    // GC1
    //----------------------------------------------------------
    and (t10, PG[0], Cin);

    or (GC1,
        GG[0],
        t10);

    //----------------------------------------------------------
    // GC2
    //----------------------------------------------------------
    and (t20, PG[1], GG[0]);

    and (t21,
         PG[1],
         PG[0],
         Cin);

    or (GC2,
        GG[1],
        t20,
        t21);

    //----------------------------------------------------------
    // GC3
    //----------------------------------------------------------
    and (t30, PG[2], GG[1]);

    and (t31,
         PG[2],
         PG[1],
         GG[0]);

    and (t32,
         PG[2],
         PG[1],
         PG[0],
         Cin);

    or (GC3,
        GG[2],
        t30,
        t31,
        t32);

    //----------------------------------------------------------
    // GC4
    //----------------------------------------------------------
    and (t40, PG[3], GG[2]);

    and (t41,
         PG[3],
         PG[2],
         GG[1]);

    and (t42,
         PG[3],
         PG[2],
         PG[1],
         GG[0]);

    and (t43,
         PG[3],
         PG[2],
         PG[1],
         PG[0],
         Cin);

    or (GC4,
        GG[3],
        t40,
        t41,
        t42,
        t43);

endmodule



//==============================================================
// cla_adder_16bit
//
// Structural top module
//==============================================================
module cla_adder_16bit_struct
#(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)
(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input                   Cin,

    output [DATA_WIDTH-1:0] Sum,
    output                  Cout,
    output                  Overflow,
    output                  Zero,
    output                  Negative
);

    //----------------------------------------------------------
    // Bit P/G
    //----------------------------------------------------------
    wire [15:0] P;
    wire [15:0] G;

    genvar i;

    generate
        for(i=0;i<16;i=i+1)
        begin : PG_GEN
            pg_cell U_PG
            (
                .A(A[i]),
                .B(B[i]),
                .P(P[i]),
                .G(G[i])
            );
        end
    endgenerate

    //----------------------------------------------------------
    // Group carries
    //----------------------------------------------------------
    wire GC1;
    wire GC2;
    wire GC3;
    wire GC4;

    //----------------------------------------------------------
    // Internal carries
    //----------------------------------------------------------
    wire C1,C2,C3,C4;
    wire C5,C6,C7,C8;
    wire C9,C10,C11,C12;
    wire C13,C14,C15,C16;

    //----------------------------------------------------------
    // Group P/G
    //----------------------------------------------------------
    wire [3:0] PG;
    wire [3:0] GG;

    group_pg GP0
    (
        .P(P[3:0]),
        .G(G[3:0]),
        .PG(PG[0]),
        .GG(GG[0])
    );

    group_pg GP1
    (
        .P(P[7:4]),
        .G(G[7:4]),
        .PG(PG[1]),
        .GG(GG[1])
    );

    group_pg GP2
    (
        .P(P[11:8]),
        .G(G[11:8]),
        .PG(PG[2]),
        .GG(GG[2])
    );

    group_pg GP3
    (
        .P(P[15:12]),
        .G(G[15:12]),
        .PG(PG[3]),
        .GG(GG[3])
    );

    //----------------------------------------------------------
    // Inter-group carry lookahead
    //----------------------------------------------------------
    inter_carry IC
    (
        .PG(PG),
        .GG(GG),
        .Cin(Cin),

        .GC1(GC1),
        .GC2(GC2),
        .GC3(GC3),
        .GC4(GC4)
    );

    //----------------------------------------------------------
    // Group 0
    //----------------------------------------------------------
    cla_carry4 CARRY0
    (
        .P(P[3:0]),
        .G(G[3:0]),
        .Cin(Cin),

        .C1(C1),
        .C2(C2),
        .C3(C3),
        .C4(C4)
    );

    //----------------------------------------------------------
    // Group 1
    //----------------------------------------------------------
    cla_carry4 CARRY1
    (
        .P(P[7:4]),
        .G(G[7:4]),
        .Cin(GC1),

        .C1(C5),
        .C2(C6),
        .C3(C7),
        .C4(C8)
    );

    //----------------------------------------------------------
    // Group 2
    //----------------------------------------------------------
    cla_carry4 CARRY2
    (
        .P(P[11:8]),
        .G(G[11:8]),
        .Cin(GC2),

        .C1(C9),
        .C2(C10),
        .C3(C11),
        .C4(C12)
    );

    //----------------------------------------------------------
    // Group 3
    //----------------------------------------------------------
    cla_carry4 CARRY3
    (
        .P(P[15:12]),
        .G(G[15:12]),
        .Cin(GC3),

        .C1(C13),
        .C2(C14),
        .C3(C15),
        .C4(C16)
    );

    //----------------------------------------------------------
    // Sum generation
    //----------------------------------------------------------
    sum_cell S0  (.P(P[0]),  .Cin(Cin), .Sum(Sum[0]));
    sum_cell S1  (.P(P[1]),  .Cin(C1),  .Sum(Sum[1]));
    sum_cell S2  (.P(P[2]),  .Cin(C2),  .Sum(Sum[2]));
    sum_cell S3  (.P(P[3]),  .Cin(C3),  .Sum(Sum[3]));

    sum_cell S4  (.P(P[4]),  .Cin(GC1), .Sum(Sum[4]));
    sum_cell S5  (.P(P[5]),  .Cin(C5),  .Sum(Sum[5]));
    sum_cell S6  (.P(P[6]),  .Cin(C6),  .Sum(Sum[6]));
    sum_cell S7  (.P(P[7]),  .Cin(C7),  .Sum(Sum[7]));

    sum_cell S8  (.P(P[8]),  .Cin(GC2), .Sum(Sum[8]));
    sum_cell S9  (.P(P[9]),  .Cin(C9),  .Sum(Sum[9]));
    sum_cell S10 (.P(P[10]), .Cin(C10), .Sum(Sum[10]));
    sum_cell S11 (.P(P[11]), .Cin(C11), .Sum(Sum[11]));

    sum_cell S12 (.P(P[12]), .Cin(GC3), .Sum(Sum[12]));
    sum_cell S13 (.P(P[13]), .Cin(C13), .Sum(Sum[13]));
    sum_cell S14 (.P(P[14]), .Cin(C14), .Sum(Sum[14]));
    sum_cell S15 (.P(P[15]), .Cin(C15), .Sum(Sum[15]));

    //----------------------------------------------------------
    // Output flags
    //----------------------------------------------------------
    xor (Overflow, C15, C16);

    nor (Zero,
         Sum[0], Sum[1], Sum[2], Sum[3],
         Sum[4], Sum[5], Sum[6], Sum[7],
         Sum[8], Sum[9], Sum[10], Sum[11],
         Sum[12], Sum[13], Sum[14], Sum[15]);

    buf (Negative, Sum[15]);

    buf (Cout, GC4);

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

//==============================================================
// DATAFLOW 16-bit CLA
//
// Architecture:
//   Four 4-bit CLA blocks
//   Group Propagate / Generate
//   Group Carry Lookahead
//
// PPA ESTIMATE
// -------------------------------------------------------------
// Delay  : ~6 gate levels
// Area   : ~170 NAND2 equivalent
// Power  : Lower than RCA due to reduced carry propagation
//==============================================================

module cla_adder_16bit_dataflow
#(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)
(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input                   Cin,

    output [DATA_WIDTH-1:0] Sum,
    output                  Cout,
    output                  Overflow,
    output                  Zero,
    output                  Negative
);

    //----------------------------------------------------------
    // Bit Propagate / Generate
    //----------------------------------------------------------

    wire [15:0] P;
    wire [15:0] G;

    assign P = A ^ B;     // Pi = Ai XOR Bi
    assign G = A & B;     // Gi = Ai AND Bi

    //----------------------------------------------------------
    // Group Propagate
    //----------------------------------------------------------

    wire PG0;
    wire PG1;
    wire PG2;
    wire PG3;

    assign PG0 = P[3]  & P[2]  & P[1]  & P[0];
    assign PG1 = P[7]  & P[6]  & P[5]  & P[4];
    assign PG2 = P[11] & P[10] & P[9]  & P[8];
    assign PG3 = P[15] & P[14] & P[13] & P[12];

    //----------------------------------------------------------
    // Group Generate
    //----------------------------------------------------------

    wire GG0;
    wire GG1;
    wire GG2;
    wire GG3;

    assign GG0 =
           G[3]
         | (P[3] & G[2])
         | (P[3] & P[2] & G[1])
         | (P[3] & P[2] & P[1] & G[0]);

    assign GG1 =
           G[7]
         | (P[7] & G[6])
         | (P[7] & P[6] & G[5])
         | (P[7] & P[6] & P[5] & G[4]);

    assign GG2 =
           G[11]
         | (P[11] & G[10])
         | (P[11] & P[10] & G[9])
         | (P[11] & P[10] & P[9] & G[8]);

    assign GG3 =
           G[15]
         | (P[15] & G[14])
         | (P[15] & P[14] & G[13])
         | (P[15] & P[14] & P[13] & G[12]);

    //----------------------------------------------------------
    // Inter-group carries
    //----------------------------------------------------------

    wire GC1;
    wire GC2;
    wire GC3;
    wire GC4;

    assign GC1 =
           GG0
         | (PG0 & Cin);

    assign GC2 =
           GG1
         | (PG1 & GG0)
         | (PG1 & PG0 & Cin);

    assign GC3 =
           GG2
         | (PG2 & GG1)
         | (PG2 & PG1 & GG0)
         | (PG2 & PG1 & PG0 & Cin);

    assign GC4 =
           GG3
         | (PG3 & GG2)
         | (PG3 & PG2 & GG1)
         | (PG3 & PG2 & PG1 & GG0)
         | (PG3 & PG2 & PG1 & PG0 & Cin);

    //----------------------------------------------------------
    // Group 0 carries
    //----------------------------------------------------------

    wire C1;
    wire C2;
    wire C3;
    wire C4;

    assign C1 =
           G[0]
         | (P[0] & Cin);

    assign C2 =
           G[1]
         | (P[1] & G[0])
         | (P[1] & P[0] & Cin);

    assign C3 =
           G[2]
         | (P[2] & G[1])
         | (P[2] & P[1] & G[0])
         | (P[2] & P[1] & P[0] & Cin);

    assign C4 =
           G[3]
         | (P[3] & G[2])
         | (P[3] & P[2] & G[1])
         | (P[3] & P[2] & P[1] & G[0])
         | (P[3] & P[2] & P[1] & P[0] & Cin);

    //----------------------------------------------------------
    // Group 1 carries
    //----------------------------------------------------------

    wire C5;
    wire C6;
    wire C7;
    wire C8;

    assign C5 =
           G[4]
         | (P[4] & GC1);

    assign C6 =
           G[5]
         | (P[5] & G[4])
         | (P[5] & P[4] & GC1);

    assign C7 =
           G[6]
         | (P[6] & G[5])
         | (P[6] & P[5] & G[4])
         | (P[6] & P[5] & P[4] & GC1);

    assign C8 =
           G[7]
         | (P[7] & G[6])
         | (P[7] & P[6] & G[5])
         | (P[7] & P[6] & P[5] & G[4])
         | (P[7] & P[6] & P[5] & P[4] & GC1);

    //----------------------------------------------------------
    // Group 2 carries
    //----------------------------------------------------------

    wire C9;
    wire C10;
    wire C11;
    wire C12;

    assign C9 =
           G[8]
         | (P[8] & GC2);

    assign C10 =
           G[9]
         | (P[9] & G[8])
         | (P[9] & P[8] & GC2);

    assign C11 =
           G[10]
         | (P[10] & G[9])
         | (P[10] & P[9] & G[8])
         | (P[10] & P[9] & P[8] & GC2);

    assign C12 =
           G[11]
         | (P[11] & G[10])
         | (P[11] & P[10] & G[9])
         | (P[11] & P[10] & P[9] & G[8])
         | (P[11] & P[10] & P[9] & P[8] & GC2);

    //----------------------------------------------------------
    // Group 3 carries
    //----------------------------------------------------------

    wire C13;
    wire C14;
    wire C15;
    wire C16;

    assign C13 =
           G[12]
         | (P[12] & GC3);

    assign C14 =
           G[13]
         | (P[13] & G[12])
         | (P[13] & P[12] & GC3);

    assign C15 =
           G[14]
         | (P[14] & G[13])
         | (P[14] & P[13] & G[12])
         | (P[14] & P[13] & P[12] & GC3);

    assign C16 =
           G[15]
         | (P[15] & G[14])
         | (P[15] & P[14] & G[13])
         | (P[15] & P[14] & P[13] & G[12])
         | (P[15] & P[14] & P[13] & P[12] & GC3);

    //----------------------------------------------------------
    // Sum equations
    //----------------------------------------------------------

    assign Sum[0]  = P[0]  ^ Cin;   // S0
    assign Sum[1]  = P[1]  ^ C1;    // S1
    assign Sum[2]  = P[2]  ^ C2;    // S2
    assign Sum[3]  = P[3]  ^ C3;    // S3

    assign Sum[4]  = P[4]  ^ GC1;   // S4
    assign Sum[5]  = P[5]  ^ C5;    // S5
    assign Sum[6]  = P[6]  ^ C6;    // S6
    assign Sum[7]  = P[7]  ^ C7;    // S7

    assign Sum[8]  = P[8]  ^ GC2;   // S8
    assign Sum[9]  = P[9]  ^ C9;    // S9
    assign Sum[10] = P[10] ^ C10;   // S10
    assign Sum[11] = P[11] ^ C11;   // S11

    assign Sum[12] = P[12] ^ GC3;   // S12
    assign Sum[13] = P[13] ^ C13;   // S13
    assign Sum[14] = P[14] ^ C14;   // S14
    assign Sum[15] = P[15] ^ C15;   // S15

    //----------------------------------------------------------
    // Outputs
    //----------------------------------------------------------

    assign Cout = GC4;              // Final carry out

    assign Overflow = C15 ^ C16;    // Signed overflow

    assign Zero = ~|Sum;            // Zero flag

    assign Negative = Sum[15];      // Sign flag

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

//==============================================================
// BEHAVIORAL 16-bit CLA
//
// Architecture:
//   Two-level Carry Lookahead
//   Four 4-bit CLA groups
//   Group Propagate / Generate
//   Inter-group Carry Lookahead
//
// PPA ESTIMATE
// -------------------------------------------------------------
// Delay  : ~6 gate levels
// Area   : ~160 NAND2 equivalent
// Power  : Similar to dataflow, lower than RCA
//==============================================================

module cla_adder_16bit_behavioral
#(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)
(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input                   Cin,

    output reg [DATA_WIDTH-1:0] Sum,
    output reg                  Cout,
    output reg                  Overflow,
    output reg                  Zero,
    output reg                  Negative
);

    integer i;
    integer g;

    //----------------------------------------------------------
    // Internal arrays required by specification
    //----------------------------------------------------------

    reg [DATA_WIDTH-1:0] P;
    reg [DATA_WIDTH-1:0] G;

    reg [DATA_WIDTH:0] C;

    reg [3:0] PG;
    reg [3:0] GG;

    reg [4:0] GC;

    //----------------------------------------------------------
    // Single combinational block
    //----------------------------------------------------------

    always @(*)
    begin

        //------------------------------------------------------
        // Default assignments
        //------------------------------------------------------

        P          = {DATA_WIDTH{1'b0}};
        G          = {DATA_WIDTH{1'b0}};
        C          = {(DATA_WIDTH+1){1'b0}};

        PG         = 4'b0;
        GG         = 4'b0;
        GC         = 5'b0;

        Sum        = {DATA_WIDTH{1'b0}};

        Cout       = 1'b0;
        Overflow   = 1'b0;
        Zero       = 1'b0;
        Negative   = 1'b0;

        //------------------------------------------------------
        // Bit Propagate / Generate
        //------------------------------------------------------

        for(i=0;i<DATA_WIDTH;i=i+1)
        begin
            P[i] = A[i] ^ B[i];
            G[i] = A[i] & B[i];
        end

        //------------------------------------------------------
        // Group Propagate / Generate
        //------------------------------------------------------

        for(g=0; g<4; g=g+1)
        begin

            PG[g] =
                  P[g*4+3]
                & P[g*4+2]
                & P[g*4+1]
                & P[g*4+0];

            GG[g] =
                  G[g*4+3]
                | (P[g*4+3] & G[g*4+2])
                | (P[g*4+3] & P[g*4+2] & G[g*4+1])
                | (P[g*4+3] & P[g*4+2] & P[g*4+1] & G[g*4+0]);

        end

        //------------------------------------------------------
        // Inter-group carry lookahead
        //------------------------------------------------------

        GC[0] = Cin;

        GC[1] =
                GG[0]
              | (PG[0] & GC[0]);

        GC[2] =
                GG[1]
              | (PG[1] & GG[0])
              | (PG[1] & PG[0] & GC[0]);

        GC[3] =
                GG[2]
              | (PG[2] & GG[1])
              | (PG[2] & PG[1] & GG[0])
              | (PG[2] & PG[1] & PG[0] & GC[0]);

        GC[4] =
                GG[3]
              | (PG[3] & GG[2])
              | (PG[3] & PG[2] & GG[1])
              | (PG[3] & PG[2] & PG[1] & GG[0])
              | (PG[3] & PG[2] & PG[1] & PG[0] & GC[0]);

        //------------------------------------------------------
        // Carry array
        //------------------------------------------------------

        C[0] = Cin;

        //------------------------------------------------------
        // Group 0
        //------------------------------------------------------

        C[1] =
              G[0]
            | (P[0] & C[0]);

        C[2] =
              G[1]
            | (P[1] & G[0])
            | (P[1] & P[0] & C[0]);

        C[3] =
              G[2]
            | (P[2] & G[1])
            | (P[2] & P[1] & G[0])
            | (P[2] & P[1] & P[0] & C[0]);

        C[4] =
              G[3]
            | (P[3] & G[2])
            | (P[3] & P[2] & G[1])
            | (P[3] & P[2] & P[1] & G[0])
            | (P[3] & P[2] & P[1] & P[0] & C[0]);

        //------------------------------------------------------
        // Group 1
        //------------------------------------------------------

        C[5] =
              G[4]
            | (P[4] & GC[1]);

        C[6] =
              G[5]
            | (P[5] & G[4])
            | (P[5] & P[4] & GC[1]);

        C[7] =
              G[6]
            | (P[6] & G[5])
            | (P[6] & P[5] & G[4])
            | (P[6] & P[5] & P[4] & GC[1]);

        C[8] =
              G[7]
            | (P[7] & G[6])
            | (P[7] & P[6] & G[5])
            | (P[7] & P[6] & P[5] & G[4])
            | (P[7] & P[6] & P[5] & P[4] & GC[1]);

        //------------------------------------------------------
        // Group 2
        //------------------------------------------------------

        C[9] =
              G[8]
            | (P[8] & GC[2]);

        C[10] =
              G[9]
            | (P[9] & G[8])
            | (P[9] & P[8] & GC[2]);

        C[11] =
              G[10]
            | (P[10] & G[9])
            | (P[10] & P[9] & G[8])
            | (P[10] & P[9] & P[8] & GC[2]);

        C[12] =
              G[11]
            | (P[11] & G[10])
            | (P[11] & P[10] & G[9])
            | (P[11] & P[10] & P[9] & G[8])
            | (P[11] & P[10] & P[9] & P[8] & GC[2]);

        //------------------------------------------------------
        // Group 3
        //------------------------------------------------------

        C[13] =
              G[12]
            | (P[12] & GC[3]);

        C[14] =
              G[13]
            | (P[13] & G[12])
            | (P[13] & P[12] & GC[3]);

        C[15] =
              G[14]
            | (P[14] & G[13])
            | (P[14] & P[13] & G[12])
            | (P[14] & P[13] & P[12] & GC[3]);

        C[16] =
              G[15]
            | (P[15] & G[14])
            | (P[15] & P[14] & G[13])
            | (P[15] & P[14] & P[13] & G[12])
            | (P[15] & P[14] & P[13] & P[12] & GC[3]);

        //------------------------------------------------------
        // Sum computation
        //------------------------------------------------------

        for(i=0;i<DATA_WIDTH;i=i+1)
        begin
            Sum[i] = P[i] ^ C[i];
        end

        //------------------------------------------------------
        // Flags
        //------------------------------------------------------

        Cout     = GC[4];

        Overflow = C[15] ^ C[16];

        Zero     = ~|Sum;

        Negative = Sum[15];

    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla_adder_16bit;

    parameter DATA_WIDTH = 16;

    //----------------------------------------------------------
    // DUT Inputs
    //----------------------------------------------------------

    reg  [DATA_WIDTH-1:0] A;
    reg  [DATA_WIDTH-1:0] B;
    reg                   Cin;

    //----------------------------------------------------------
    // STRUCTURAL DUT Outputs
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_struct;
    wire                  Cout_struct;
    wire                  Overflow_struct;
    wire                  Zero_struct;
    wire                  Negative_struct;

    //----------------------------------------------------------
    // DATAFLOW DUT Outputs
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_data;
    wire                  Cout_data;
    wire                  Overflow_data;
    wire                  Zero_data;
    wire                  Negative_data;

    //----------------------------------------------------------
    // BEHAVIORAL DUT Outputs
    //----------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_beh;
    wire                  Cout_beh;
    wire                  Overflow_beh;
    wire                  Zero_beh;
    wire                  Negative_beh;

    //----------------------------------------------------------
    // Reference
    //----------------------------------------------------------

    reg [DATA_WIDTH:0] reference;

    integer i;
    integer pass_directed;
    integer total_directed;

    integer pass_random;
    integer total_random;

    integer failures;

    //----------------------------------------------------------
    // DUT Instantiations
    //----------------------------------------------------------

    cla_adder_16bit_struct dut_struct
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_struct),
        .Cout(Cout_struct),
        .Overflow(Overflow_struct),
        .Zero(Zero_struct),
        .Negative(Negative_struct)
    );

    cla_adder_16bit_dataflow dut_data
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_data),
        .Cout(Cout_data),
        .Overflow(Overflow_data),
        .Zero(Zero_data),
        .Negative(Negative_data)
    );

    cla_adder_16bit_behavioral dut_beh
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_beh),
        .Cout(Cout_beh),
        .Overflow(Overflow_beh),
        .Zero(Zero_beh),
        .Negative(Negative_beh)
    );

    //----------------------------------------------------------
    // VCD Dump
    //----------------------------------------------------------

    initial
    begin
        $dumpfile("cla_adder_16bit.vcd");
        $dumpvars(0,tb_cla_adder_16bit);
    end

    //----------------------------------------------------------
    // Result Checker
    //----------------------------------------------------------

    task check_result;
    begin

        reference = A + B + Cin;

        //------------------------------------------------------
        // Structural
        //------------------------------------------------------

        if({Cout_struct,Sum_struct} !== reference)
        begin
            failures = failures + 1;

            $display(
            "FAIL STRUCT : A=%h B=%h Cin=%b Got=%h_%h Exp=%h",
            A,B,Cin,
            Cout_struct,
            Sum_struct,
            reference);
        end

        //------------------------------------------------------
        // Dataflow
        //------------------------------------------------------

        if({Cout_data,Sum_data} !== reference)
        begin
            failures = failures + 1;

            $display(
            "FAIL DATA   : A=%h B=%h Cin=%b Got=%h_%h Exp=%h",
            A,B,Cin,
            Cout_data,
            Sum_data,
            reference);
        end

        //------------------------------------------------------
        // Behavioral
        //------------------------------------------------------

        if({Cout_beh,Sum_beh} !== reference)
        begin
            failures = failures + 1;

            $display(
            "FAIL BEHAV  : A=%h B=%h Cin=%b Got=%h_%h Exp=%h",
            A,B,Cin,
            Cout_beh,
            Sum_beh,
            reference);
        end

        //------------------------------------------------------
        // Cross compare DUTs
        //------------------------------------------------------

        if(Sum_struct !== Sum_data)
        begin
            failures = failures + 1;
            $display("MISMATCH STRUCT/DATA");
        end

        if(Sum_struct !== Sum_beh)
        begin
            failures = failures + 1;
            $display("MISMATCH STRUCT/BEHAV");
        end

        if({Cout_struct,Overflow_struct,Zero_struct,Negative_struct}
           !==
           {Cout_data,Overflow_data,Zero_data,Negative_data})
        begin
            failures = failures + 1;
            $display("FLAG MISMATCH STRUCT/DATA");
        end

        if({Cout_struct,Overflow_struct,Zero_struct,Negative_struct}
           !==
           {Cout_beh,Overflow_beh,Zero_beh,Negative_beh})
        begin
            failures = failures + 1;
            $display("FLAG MISMATCH STRUCT/BEHAV");
        end

    end
    endtask

    //----------------------------------------------------------
    // Main Test Sequence
    //----------------------------------------------------------

    initial
    begin

        pass_directed = 0;
        total_directed = 0;

        pass_random = 0;
        total_random = 50000;

        failures = 0;

        //------------------------------------------------------
        // ALL ZEROS
        //------------------------------------------------------

        A   = 16'h0000;
        B   = 16'h0000;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // ALL ONES
        //------------------------------------------------------

        A   = 16'hFFFF;
        B   = 16'hFFFF;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // ROLLOVER
        //------------------------------------------------------

        A   = 16'hFFFF;
        B   = 16'h0001;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // SIGNED OVERFLOW +
        //------------------------------------------------------

        A   = 16'h7FFF;
        B   = 16'h0001;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // SIGNED OVERFLOW -
        //------------------------------------------------------

        A   = 16'h8000;
        B   = 16'h8000;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // CHECKERBOARD
        //------------------------------------------------------

        A   = 16'hAAAA;
        B   = 16'h5555;
        Cin = 1'b0;
        #1;

        total_directed = total_directed + 1;
        if({Cout_struct,Sum_struct} == (A+B+Cin))
            pass_directed = pass_directed + 1;

        check_result();

        //------------------------------------------------------
        // SINGLE BIT SWEEP A
        //------------------------------------------------------

        for(i=0;i<16;i=i+1)
        begin

            A   = (16'h0001 << i);
            B   = 16'h0000;
            Cin = 1'b0;

            #1;

            total_directed = total_directed + 1;

            if({Cout_struct,Sum_struct} == (A+B+Cin))
                pass_directed = pass_directed + 1;

            check_result();

            Cin = 1'b1;

            #1;

            total_directed = total_directed + 1;

            if({Cout_struct,Sum_struct} == (A+B+Cin))
                pass_directed = pass_directed + 1;

            check_result();

        end

        //------------------------------------------------------
        // SINGLE BIT SWEEP B
        //------------------------------------------------------

        for(i=0;i<16;i=i+1)
        begin

            A   = 16'h0000;
            B   = (16'h0001 << i);
            Cin = 1'b0;

            #1;

            total_directed = total_directed + 1;

            if({Cout_struct,Sum_struct} == (A+B+Cin))
                pass_directed = pass_directed + 1;

            check_result();

            Cin = 1'b1;

            #1;

            total_directed = total_directed + 1;

            if({Cout_struct,Sum_struct} == (A+B+Cin))
                pass_directed = pass_directed + 1;

            check_result();

        end

        //------------------------------------------------------
        // RANDOM TESTS
        //------------------------------------------------------

        for(i=0;i<50000;i=i+1)
        begin

            A   = $random;
            B   = $random;
            Cin = $random;

            #1;

            reference = A + B + Cin;

            if({Cout_struct,Sum_struct} == reference)
                pass_random = pass_random + 1;

            check_result();

        end

        //------------------------------------------------------
        // REPORT
        //------------------------------------------------------

        $display("");
        $display("====================================");
        $display("DIRECTED PASS = %0d / %0d",
                  pass_directed,
                  total_directed);

        $display("RANDOM PASS   = %0d / 50000",
                  pass_random);

        $display("FAILURES      = %0d",
                  failures);

        if(failures == 0)
            $display("OVERALL RESULT : PASS");
        else
            $display("OVERALL RESULT : FAIL");

        $display("====================================");

        $finish;

    end

endmodule
