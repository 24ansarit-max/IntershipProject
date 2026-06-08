// =============================================================================
// PROMPT STRATEGY: FEW SHOT
// =============================================================================
// Study these reference snippets, then use them as style anchors to write the complete 16-bit CLA.
//
// ────────────────────────────────────────────────
// REFERENCE SNIPPET A — 1-bit PG cell (structural)
// ────────────────────────────────────────────────
//   module pg_cell(input a, b, output p, g);
//     xor u1(p, a, b);
//     and u2(g, a, b);
//   endmodule
//
// ────────────────────────────────────────────────
// REFERENCE SNIPPET B — 4-bit CLA carry equations (dataflow)
// ────────────────────────────────────────────────
//   assign C1 = G[0] | (P[0] & Cin);
//   assign C2 = G[1] | (P[1]&G[0]) | (P[1]&P[0]&Cin);
//   assign C3 = G[2] | (P[2]&G[1]) | (P[2]&P[1]&G[0]) | (P[2]&P[1]&P[0]&Cin);
//   assign C4 = G[3] | (P[3]&G[2]) | (P[3]&P[2]&G[1]) | (P[3]&P[2]&P[1]&G[0])
//                    | (P[3]&P[2]&P[1]&P[0]&Cin);
//
// ────────────────────────────────────────────────
// REFERENCE SNIPPET C — behavioral PG loop
// ────────────────────────────────────────────────
//   always @(*) begin
//     integer i;
//     for (i=0; i<N; i=i+1) begin
//       P[i] = A[i] ^ B[i];
//       G[i] = A[i] & B[i];
//     end
//   end
//
// ────────────────────────────────────────────────
// REFERENCE SNIPPET D — self-checking testbench pattern
// ────────────────────────────────────────────────
//   initial begin
//     integer i; reg [16:0] exp;
//     for (i=0; i<10000; i=i+1) begin
//       A=$random; B=$random; Cin=$random; #10;
//       exp = A + B + Cin;
//       if (Sum !== exp[15:0] || Cout !== exp[16])
//         $display("FAIL: A=%h B=%h Cin=%b Got=%h/%b Exp=%h/%b",
//                   A,B,Cin,Sum,Cout,exp[15:0],exp[16]);
//     end
//   end
//
// ────────────────────────────────────────────────
// NOW: extend these snippets into the full 16-bit CLA
// ────────────────────────────────────────────────
// Using the patterns above as your style guide, deliver FOUR sections:
//
// [1] STRUCTURAL — extend Snippet A into a full hierarchy:
//     pg_cell (from Snippet A), cla_carry4 (from Snippet B pattern),
//     sum_cell, group_pg, inter_carry, cla_adder_16bit (top)
//     No always blocks. Named port mapping. PPA header.
//
// [2] DATAFLOW — extend Snippet B for all 16 bits across 4 groups.
//     Two-level lookahead: group carries feed inter-group carry unit.
//     All assign, all wires declared. PPA header.
//
// [3] BEHAVIORAL — extend Snippet C into full algorithm:
//     DATA_WIDTH=16, GROUP_SIZE=4. Five labeled steps inside always @(*).
//     Group lookahead, not ripple. All flags. PPA header.
//
// [4] TESTBENCH — extend Snippet D:
//     Instantiate all three DUTs on same inputs.
//     Directed tests (all-zeros, all-ones, rollover, overflow, checkerboard,
//     single-bit sweeps A and B, Cin=0/1 for each).
//     50 000 random vectors. End-of-sim summary. VCD dump.
//
// Write every line. No placeholders. End with PPA comparison table.
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps
//============================================================
// Module : pg_cell
// Function: Generate and Propagate generation
// Style   : Structural
// Power   : ~2 gates/bit
// Area    : ~2 cells
// Delay   : XOR + AND
//============================================================
module pg_cell(
    input  a,
    input  b,
    output p,
    output g
);
    xor u1(p, a, b);
    and u2(g, a, b);
endmodule


//============================================================
// Module : sum_cell
// Function: Sum generation
// Style   : Structural
// Power   : ~1 XOR gate
// Area    : ~1 cell
// Delay   : 1 XOR
//============================================================
module sum_cell(
    input  p,
    input  cin,
    output sum
);
    xor u1(sum, p, cin);
endmodule


//============================================================
// Module : cla_carry4
// Function: 4-bit Carry Lookahead Logic
// Style   : Dataflow equations inside structural hierarchy
// Power   : Moderate
// Area    : ~25 gates
// Delay   : 2-level lookahead
//============================================================
module cla_carry4(
    input  [3:0] P ,
    input  [3:0] G,
    input        Cin,

    output C1,
    output C2,
    output C3,
    output C4
);

    assign C1 = G[0] |
                (P[0] & Cin);

    assign C2 = G[1] |
                (P[1] & G[0]) |
                (P[1] & P[0] & Cin);

    assign C3 = G[2] |
                (P[2] & G[1]) |
                (P[2] & P[1] & G[0]) |
                (P[2] & P[1] & P[0] & Cin);

    assign C4 = G[3] |
                (P[3] & G[2]) |
                (P[3] & P[2] & G[1]) |
                (P[3] & P[2] & P[1] & G[0]) |
                (P[3] & P[2] & P[1] & P[0] & Cin);

endmodule


//============================================================
// Module : group_pg
// Function: Group Generate/Propagate for 4-bit block
// Style   : Structural/Dataflow Hybrid
// Power   : Low
// Area    : ~10 gates
// Delay   : 2 levels
//============================================================
module group_pg(
    input  [3:0] P ,
    input  [3:0] G,

    output PG,
    output GG
);

    assign PG = P[3] &
                P[2] &
                P[1] &
                P[0];

    assign GG = G[3] |
               (P[3] & G[2]) |
               (P[3] & P[2] & G[1]) |
               (P[3] & P[2] & P[1] & G[0]);

endmodule


//============================================================
// Module : inter_carry
// Function: Group-level carry lookahead
// Computes carries between 4-bit CLA groups
//
// C4  = carry into group1
// C8  = carry into group2
// C12 = carry into group3
// C16 = final carry out
//
// Power : Low
// Area  : ~20 gates
// Delay : 2-level lookahead
//============================================================
module inter_carry(
    input  [3:0] PG,
    input  [3:0] GG,
    input        Cin,

    output C4,
    output C8,
    output C12,
    output C16
);

    assign C4 =
           GG[0] |
          (PG[0] & Cin);

    assign C8 =
           GG[1] |
          (PG[1] & GG[0]) |
          (PG[1] & PG[0] & Cin);

    assign C12 =
           GG[2] |
          (PG[2] & GG[1]) |
          (PG[2] & PG[1] & GG[0]) |
          (PG[2] & PG[1] & PG[0] & Cin);

    assign C16 =
           GG[3] |
          (PG[3] & GG[2]) |
          (PG[3] & PG[2] & GG[1]) |
          (PG[3] & PG[2] & PG[1] & GG[0]) |
          (PG[3] & PG[2] & PG[1] & PG[0] & Cin);

endmodule


//============================================================
// Module : cla_adder_16bit
// Function: 16-bit Carry Lookahead Adder
// Architecture:
//
// 4 x PG blocks
// 4 x Local CLA carry generators
// 1 x Group PG generator set
// 1 x Inter-group carry generator
//
// Power : Low-Medium
// Area  : ~120-150 gates
// Delay : O(log4(16))
//============================================================
module cla_adder_16bit(
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,

    output [15:0] Sum,
    output        Cout
);

    //--------------------------------------------------------
    // Bit-level Propagate / Generate
    //--------------------------------------------------------
    wire [15:0] P;
    wire [15:0] G;

    genvar i;

    generate
        for(i=0;i<16;i=i+1)
        begin : PG_STAGE

            pg_cell pg_inst(
                .a(A[i]),
                .b(B[i]),
                .p(P[i]),
                .g(G[i])
            );

        end
    endgenerate


    //--------------------------------------------------------
    // Group PG/GG
    //--------------------------------------------------------
    wire [3:0] PG_grp;
    wire [3:0] GG_grp;

    group_pg GP0(
        .P (P[3:0]),
        .G (G[3:0]),
        .PG(PG_grp[0]),
        .GG(GG_grp[0])
    );

    group_pg GP1(
        .P (P[7:4]),
        .G (G[7:4]),
        .PG(PG_grp[1]),
        .GG(GG_grp[1])
    );

    group_pg GP2(
        .P (P[11:8]),
        .G (G[11:8]),
        .PG(PG_grp[2]),
        .GG(GG_grp[2])
    );

    group_pg GP3(
        .P (P[15:12]),
        .G (G[15:12]),
        .PG(PG_grp[3]),
        .GG(GG_grp[3])
    );


    //--------------------------------------------------------
    // Inter-group carries
    //--------------------------------------------------------
    wire C4;
    wire C8;
    wire C12;
    wire C16;

    inter_carry ICARRY(
        .PG (PG_grp),
        .GG (GG_grp),
        .Cin(Cin),

        .C4 (C4),
        .C8 (C8),
        .C12(C12),
        .C16(C16)
    );


    //--------------------------------------------------------
    // Internal carries for each block
    //--------------------------------------------------------
    wire c1,c2,c3;
    wire c5,c6,c7;
    wire c9,c10,c11;
    wire c13,c14,c15;


    //--------------------------------------------------------
    // CLA Block 0
    //--------------------------------------------------------
    cla_carry4 CLA0(
        .P  (P[3:0]),
        .G  (G[3:0]),
        .Cin(Cin),

        .C1(c1),
        .C2(c2),
        .C3(c3),
        .C4()
    );


    //--------------------------------------------------------
    // CLA Block 1
    //--------------------------------------------------------
    cla_carry4 CLA1(
        .P  (P[7:4]),
        .G  (G[7:4]),
        .Cin(C4),

        .C1(c5),
        .C2(c6),
        .C3(c7),
        .C4()
    );


    //--------------------------------------------------------
    // CLA Block 2
    //--------------------------------------------------------
    cla_carry4 CLA2(
        .P  (P[11:8]),
        .G  (G[11:8]),
        .Cin(C8),

        .C1(c9),
        .C2(c10),
        .C3(c11),
        .C4()
    );


    //--------------------------------------------------------
    // CLA Block 3
    //--------------------------------------------------------
    cla_carry4 CLA3(
        .P  (P[15:12]),
        .G  (G[15:12]),
        .Cin(C12),

        .C1(c13),
        .C2(c14),
        .C3(c15),
        .C4()
    );


    //--------------------------------------------------------
    // Sum Generation
    //--------------------------------------------------------
    sum_cell S0(
        .p(P[0]),
        .cin(Cin),
        .sum(Sum[0])
    );

    sum_cell S1(
        .p(P[1]),
        .cin(c1),
        .sum(Sum[1])
    );

    sum_cell S2(
        .p(P[2]),
        .cin(c2),
        .sum(Sum[2])
    );

    sum_cell S3(
        .p(P[3]),
        .cin(c3),
        .sum(Sum[3])
    );

    sum_cell S4(
        .p(P[4]),
        .cin(C4),
        .sum(Sum[4])
    );

    sum_cell S5(
        .p(P[5]),
        .cin(c5),
        .sum(Sum[5])
    );

    sum_cell S6(
        .p(P[6]),
        .cin(c6),
        .sum(Sum[6])
    );

    sum_cell S7(
        .p(P[7]),
        .cin(c7),
        .sum(Sum[7])
    );

    sum_cell S8(
        .p(P[8]),
        .cin(C8),
        .sum(Sum[8])
    );

    sum_cell S9(
        .p(P[9]),
        .cin(c9),
        .sum(Sum[9])
    );

    sum_cell S10(
        .p(P[10]),
        .cin(c10),
        .sum(Sum[10])
    );

    sum_cell S11(
        .p(P[11]),
        .cin(c11),
        .sum(Sum[11])
    );

    sum_cell S12(
        .p(P[12]),
        .cin(C12),
        .sum(Sum[12])
    );

    sum_cell S13(
        .p(P[13]),
        .cin(c13),
        .sum(Sum[13])
    );

    sum_cell S14(
        .p(P[14]),
        .cin(c14),
        .sum(Sum[14])
    );

    sum_cell S15(
        .p(P[15]),
        .cin(c15),
        .sum(Sum[15])
    );


    //--------------------------------------------------------
    // Final Carry Out
    //--------------------------------------------------------
    assign Cout = C16;

endmodule

// --- [2] DATAFLOW STYLE ---
module cla_adder_16bit_dataflow(
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,

    output [15:0] Sum,
    output        Cout
);

    //--------------------------------------------------------
    // Propagate / Generate
    //--------------------------------------------------------
    wire [15:0] P;
    wire [15:0] G;

    assign P = A ^ B;
    assign G = A & B;

    //--------------------------------------------------------
    // Group Propagate / Generate
    //--------------------------------------------------------
    wire [3:0] PG;
    wire [3:0] GG;

    // Group 0
    assign PG[0] =
           P[3] & P[2] & P[1] & P[0];

    assign GG[0] =
           G[3] |
          (P[3] & G[2]) |
          (P[3] & P[2] & G[1]) |
          (P[3] & P[2] & P[1] & G[0]);

    // Group 1
    assign PG[1] =
           P[7] & P[6] & P[5] & P[4];

    assign GG[1] =
           G[7] |
          (P[7] & G[6]) |
          (P[7] & P[6] & G[5]) |
          (P[7] & P[6] & P[5] & G[4]);

    // Group 2
    assign PG[2] =
           P[11] & P[10] & P[9] & P[8];

    assign GG[2] =
           G[11] |
          (P[11] & G[10]) |
          (P[11] & P[10] & G[9]) |
          (P[11] & P[10] & P[9] & G[8]);

    // Group 3
    assign PG[3] =
           P[15] & P[14] & P[13] & P[12];

    assign GG[3] =
           G[15] |
          (P[15] & G[14]) |
          (P[15] & P[14] & G[13]) |
          (P[15] & P[14] & P[13] & G[12]);

    //--------------------------------------------------------
    // Inter-Group Carries
    //--------------------------------------------------------
    wire C4;
    wire C8;
    wire C12;
    wire C16;

    assign C4 =
           GG[0] |
          (PG[0] & Cin);

    assign C8 =
           GG[1] |
          (PG[1] & GG[0]) |
          (PG[1] & PG[0] & Cin);

    assign C12 =
           GG[2] |
          (PG[2] & GG[1]) |
          (PG[2] & PG[1] & GG[0]) |
          (PG[2] & PG[1] & PG[0] & Cin);

    assign C16 =
           GG[3] |
          (PG[3] & GG[2]) |
          (PG[3] & PG[2] & GG[1]) |
          (PG[3] & PG[2] & PG[1] & GG[0]) |
          (PG[3] & PG[2] & PG[1] & PG[0] & Cin);

    //--------------------------------------------------------
    // Internal Carries : Group 0
    //--------------------------------------------------------
    wire C1;
    wire C2;
    wire C3;

    assign C1 =
           G[0] |
          (P[0] & Cin);

    assign C2 =
           G[1] |
          (P[1] & G[0]) |
          (P[1] & P[0] & Cin);

    assign C3 =
           G[2] |
          (P[2] & G[1]) |
          (P[2] & P[1] & G[0]) |
          (P[2] & P[1] & P[0] & Cin);

    //--------------------------------------------------------
    // Internal Carries : Group 1
    //--------------------------------------------------------
    wire C5;
    wire C6;
    wire C7;

    assign C5 =
           G[4] |
          (P[4] & C4);

    assign C6 =
           G[5] |
          (P[5] & G[4]) |
          (P[5] & P[4] & C4);

    assign C7 =
           G[6] |
          (P[6] & G[5]) |
          (P[6] & P[5] & G[4]) |
          (P[6] & P[5] & P[4] & C4);

    //--------------------------------------------------------
    // Internal Carries : Group 2
    //--------------------------------------------------------
    wire C9;
    wire C10;
    wire C11;

    assign C9 =
           G[8] |
          (P[8] & C8);

    assign C10 =
           G[9] |
          (P[9] & G[8]) |
          (P[9] & P[8] & C8);

    assign C11 =
           G[10] |
          (P[10] & G[9]) |
          (P[10] & P[9] & G[8]) |
          (P[10] & P[9] & P[8] & C8);

    //--------------------------------------------------------
    // Internal Carries : Group 3
    //--------------------------------------------------------
    wire C13;
    wire C14;
    wire C15;

    assign C13 =
           G[12] |
          (P[12] & C12);

    assign C14 =
           G[13] |
          (P[13] & G[12]) |
          (P[13] & P[12] & C12);

    assign C15 =
           G[14] |
          (P[14] & G[13]) |
          (P[14] & P[13] & G[12]) |
          (P[14] & P[13] & P[12] & C12);

    //--------------------------------------------------------
    // Sum Equations
    //--------------------------------------------------------
    assign Sum[0]  = P[0]  ^ Cin;
    assign Sum[1]  = P[1]  ^ C1;
    assign Sum[2]  = P[2]  ^ C2;
    assign Sum[3]  = P[3]  ^ C3;

    assign Sum[4]  = P[4]  ^ C4;
    assign Sum[5]  = P[5]  ^ C5;
    assign Sum[6]  = P[6]  ^ C6;
    assign Sum[7]  = P[7]  ^ C7;

    assign Sum[8]  = P[8]  ^ C8;
    assign Sum[9]  = P[9]  ^ C9;
    assign Sum[10] = P[10] ^ C10;
    assign Sum[11] = P[11] ^ C11;

    assign Sum[12] = P[12] ^ C12;
    assign Sum[13] = P[13] ^ C13;
    assign Sum[14] = P[14] ^ C14;
    assign Sum[15] = P[15] ^ C15;

    //--------------------------------------------------------
    // Final Carry Out
    //--------------------------------------------------------
    assign Cout = C16;

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps
//============================================================
// Module : cla_adder_16bit_behavioral
// Function: 16-bit Carry Lookahead Adder
// Style   : Behavioral
//
// Architecture:
//   Step 1 : Bit PG generation
//   Step 2 : Group PG/GG generation
//   Step 3 : Inter-group carry lookahead
//   Step 4 : Intra-group carry lookahead
//   Step 5 : Sum and Cout generation
//
// Parameters:
//   DATA_WIDTH = 16
//   GROUP_SIZE = 4
//
// Power : Medium
// Area  : Small RTL description
// Delay : Equivalent to 2-level CLA after synthesis
//============================================================
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
    output reg                  Cout
);

    integer i;

    //--------------------------------------------------------
    // Internal Signals
    //--------------------------------------------------------
    reg [DATA_WIDTH-1:0] P;
    reg [DATA_WIDTH-1:0] G;

    reg [3:0] PG;
    reg [3:0] GG;

    reg [16:0] C;

    always @(*) begin

        //----------------------------------------------------
        // Default Assignments
        //----------------------------------------------------
        P    = 16'd0;
        G    = 16'd0;
        PG   = 4'd0;
        GG   = 4'd0;
        C    = 17'd0;
        Sum  = 16'd0;
        Cout = 1'b0;

        C[0] = Cin;

        //----------------------------------------------------
        // STEP 1 : Bit Propagate / Generate
        //----------------------------------------------------
        for(i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            P[i] = A[i] ^ B[i];
            G[i] = A[i] & B[i];
        end

        //----------------------------------------------------
        // STEP 2 : Group PG / GG Generation
        //----------------------------------------------------

        // Group 0
        PG[0] =
            P[3] & P[2] & P[1] & P[0];

        GG[0] =
            G[3] |
           (P[3] & G[2]) |
           (P[3] & P[2] & G[1]) |
           (P[3] & P[2] & P[1] & G[0]);

        // Group 1
        PG[1] =
            P[7] & P[6] & P[5] & P[4];

        GG[1] =
            G[7] |
           (P[7] & G[6]) |
           (P[7] & P[6] & G[5]) |
           (P[7] & P[6] & P[5] & G[4]);

        // Group 2
        PG[2] =
            P[11] & P[10] & P[9] & P[8];

        GG[2] =
            G[11] |
           (P[11] & G[10]) |
           (P[11] & P[10] & G[9]) |
           (P[11] & P[10] & P[9] & G[8]);

        // Group 3
        PG[3] =
            P[15] & P[14] & P[13] & P[12];

        GG[3] =
            G[15] |
           (P[15] & G[14]) |
           (P[15] & P[14] & G[13]) |
           (P[15] & P[14] & P[13] & G[12]);

        //----------------------------------------------------
        // STEP 3 : Inter-Group Carry Lookahead
        //----------------------------------------------------

        C[4] =
            GG[0] |
           (PG[0] & C[0]);

        C[8] =
            GG[1] |
           (PG[1] & GG[0]) |
           (PG[1] & PG[0] & C[0]);

        C[12] =
            GG[2] |
           (PG[2] & GG[1]) |
           (PG[2] & PG[1] & GG[0]) |
           (PG[2] & PG[1] & PG[0] & C[0]);

        C[16] =
            GG[3] |
           (PG[3] & GG[2]) |
           (PG[3] & PG[2] & GG[1]) |
           (PG[3] & PG[2] & PG[1] & GG[0]) |
           (PG[3] & PG[2] & PG[1] & PG[0] & C[0]);

        //----------------------------------------------------
        // STEP 4 : Intra-Group Carry Lookahead
        //----------------------------------------------------

        // Group 0
        C[1] =
            G[0] |
           (P[0] & C[0]);

        C[2] =
            G[1] |
           (P[1] & G[0]) |
           (P[1] & P[0] & C[0]);

        C[3] =
            G[2] |
           (P[2] & G[1]) |
           (P[2] & P[1] & G[0]) |
           (P[2] & P[1] & P[0] & C[0]);

        // Group 1
        C[5] =
            G[4] |
           (P[4] & C[4]);

        C[6] =
            G[5] |
           (P[5] & G[4]) |
           (P[5] & P[4] & C[4]);

        C[7] =
            G[6] |
           (P[6] & G[5]) |
           (P[6] & P[5] & G[4]) |
           (P[6] & P[5] & P[4] & C[4]);

        // Group 2
        C[9] =
            G[8] |
           (P[8] & C[8]);

        C[10] =
            G[9] |
           (P[9] & G[8]) |
           (P[9] & P[8] & C[8]);

        C[11] =
            G[10] |
           (P[10] & G[9]) |
           (P[10] & P[9] & G[8]) |
           (P[10] & P[9] & P[8] & C[8]);

        // Group 3
        C[13] =
            G[12] |
           (P[12] & C[12]);

        C[14] =
            G[13] |
           (P[13] & G[12]) |
           (P[13] & P[12] & C[12]);

        C[15] =
            G[14] |
           (P[14] & G[13]) |
           (P[14] & P[13] & G[12]) |
           (P[14] & P[13] & P[12] & C[12]);

        //----------------------------------------------------
        // STEP 5 : Sum and Carry-Out Generation
        //----------------------------------------------------
        for(i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            Sum[i] = P[i] ^ C[i];
        end

        Cout = C[16];

    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

//============================================================
// Testbench : tb_cla_16bit
// Function  : Verification of Structural,
//             Dataflow and Behavioral CLA
//
// Tests:
//   1. All Zeros
//   2. All Ones
//   3. Rollover
//   4. Overflow
//   5. Checkerboard
//   6. Single-Bit Sweep A
//   7. Single-Bit Sweep B
//   8. 50,000 Random Tests
//
// Verification:
//   Golden Reference = A + B + Cin
//
//============================================================
module tb_cla_16bit;

    //--------------------------------------------------------
    // Parameters
    //--------------------------------------------------------
    parameter WIDTH = 16;

    //--------------------------------------------------------
    // DUT Inputs
    //--------------------------------------------------------
    reg  [WIDTH-1:0] A;
    reg  [WIDTH-1:0] B;
    reg              Cin;

    //--------------------------------------------------------
    // Structural DUT
    //--------------------------------------------------------
    wire [WIDTH-1:0] Sum_struct;
    wire             Cout_struct;

    //--------------------------------------------------------
    // Dataflow DUT
    //--------------------------------------------------------
    wire [WIDTH-1:0] Sum_dataflow;
    wire             Cout_dataflow;

    //--------------------------------------------------------
    // Behavioral DUT
    //--------------------------------------------------------
    wire [WIDTH-1:0] Sum_behavioral;
    wire             Cout_behavioral;

    //--------------------------------------------------------
    // Golden Reference
    //--------------------------------------------------------
    reg [WIDTH:0] expected;

    //--------------------------------------------------------
    // Statistics
    //--------------------------------------------------------
    integer total_tests;
    integer pass_count;
    integer fail_count;

    integer i;

    //--------------------------------------------------------
    // DUT Instantiation
    //--------------------------------------------------------

    cla_adder_16bit DUT_STRUCTURAL
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_struct),
        .Cout(Cout_struct)
    );

    cla_adder_16bit_dataflow DUT_DATAFLOW
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_dataflow),
        .Cout(Cout_dataflow)
    );

    cla_adder_16bit_behavioral DUT_BEHAVIORAL
    (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum_behavioral),
        .Cout(Cout_behavioral)
    );

    //--------------------------------------------------------
    // Check Task
    //--------------------------------------------------------
    task check_result;
    begin

        expected = A + B + Cin;

        total_tests = total_tests + 1;

        //----------------------------------------------------
        // Structural Check
        //----------------------------------------------------
        if ((Sum_struct !== expected[15:0]) ||
            (Cout_struct !== expected[16]))
        begin

            fail_count = fail_count + 1;

            $display("STRUCTURAL FAIL");
            $display("A=%h B=%h Cin=%b",
                     A,B,Cin);

            $display("Got=%h/%b Exp=%h/%b",
                     Sum_struct,
                     Cout_struct,
                     expected[15:0],
                     expected[16]);
        end

        //----------------------------------------------------
        // Dataflow Check
        //----------------------------------------------------
        else if ((Sum_dataflow !== expected[15:0]) ||
                 (Cout_dataflow !== expected[16]))
        begin

            fail_count = fail_count + 1;

            $display("DATAFLOW FAIL");
            $display("A=%h B=%h Cin=%b",
                     A,B,Cin);

            $display("Got=%h/%b Exp=%h/%b",
                     Sum_dataflow,
                     Cout_dataflow,
                     expected[15:0],
                     expected[16]);
        end

        //----------------------------------------------------
        // Behavioral Check
        //----------------------------------------------------
        else if ((Sum_behavioral !== expected[15:0]) ||
                 (Cout_behavioral !== expected[16]))
        begin

            fail_count = fail_count + 1;

            $display("BEHAVIORAL FAIL");
            $display("A=%h B=%h Cin=%b",
                     A,B,Cin);

            $display("Got=%h/%b Exp=%h/%b",
                     Sum_behavioral,
                     Cout_behavioral,
                     expected[15:0],
                     expected[16]);
        end

        //----------------------------------------------------
        // Cross DUT Check
        //----------------------------------------------------
        else if ((Sum_struct     !== Sum_dataflow) ||
                 (Sum_struct     !== Sum_behavioral) ||
                 (Cout_struct    !== Cout_dataflow) ||
                 (Cout_struct    !== Cout_behavioral))
        begin

            fail_count = fail_count + 1;

            $display("DUT MISMATCH");
        end

        else
        begin
            pass_count = pass_count + 1;
        end

    end
    endtask


    //--------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------
    initial
    begin

        //----------------------------------------------------
        // Initialize
        //----------------------------------------------------
        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;

        //----------------------------------------------------
        // VCD Dump
        //----------------------------------------------------
        $dumpfile("cla16.vcd");
        $dumpvars(0, tb_cla_16bit);

        //----------------------------------------------------
        // TEST 1 : All Zeros
        //----------------------------------------------------
        A   = 16'h0000;
        B   = 16'h0000;
        Cin = 1'b0;
        #10;
        check_result();

        //----------------------------------------------------
        // TEST 2 : All Ones
        //----------------------------------------------------
        A   = 16'hFFFF;
        B   = 16'hFFFF;
        Cin = 1'b1;
        #10;
        check_result();

        //----------------------------------------------------
        // TEST 3 : Rollover
        //----------------------------------------------------
        A   = 16'hFFFF;
        B   = 16'h0001;
        Cin = 1'b0;
        #10;
        check_result();

        //----------------------------------------------------
        // TEST 4 : Overflow
        //----------------------------------------------------
        A   = 16'h7FFF;
        B   = 16'h0001;
        Cin = 1'b0;
        #10;
        check_result();

        //----------------------------------------------------
        // TEST 5 : Checkerboard
        //----------------------------------------------------
        A   = 16'hAAAA;
        B   = 16'h5555;
        Cin = 1'b0;
        #10;
        check_result();

        A   = 16'h5555;
        B   = 16'hAAAA;
        Cin = 1'b1;
        #10;
        check_result();

        //----------------------------------------------------
        // TEST 6 : Single Bit Sweep A
        //----------------------------------------------------
        for(i=0;i<16;i=i+1)
        begin

            A   = (16'h0001 << i);
            B   = 16'h0000;
            Cin = 1'b0;

            #10;
            check_result();

            Cin = 1'b1;

            #10;
            check_result();
        end

        //----------------------------------------------------
        // TEST 7 : Single Bit Sweep B
        //----------------------------------------------------
        for(i=0;i<16;i=i+1)
        begin

            A   = 16'h0000;
            B   = (16'h0001 << i);
            Cin = 1'b0;

            #10;
            check_result();

            Cin = 1'b1;

            #10;
            check_result();
        end

        //----------------------------------------------------
        // TEST 8 : Walking Ones
        //----------------------------------------------------
        for(i=0;i<16;i=i+1)
        begin

            A   = (16'h0001 << i);
            B   = ~(16'h0001 << i);
            Cin = i[0];

            #10;
            check_result();
        end

        //----------------------------------------------------
        // TEST 9 : 50,000 Random Vectors
        //----------------------------------------------------
        for(i=0;i<50000;i=i+1)
        begin

            A   = $random;
            B   = $random;
            Cin = $random;

            #10;

            check_result();
        end

        //----------------------------------------------------
        // Summary
        //----------------------------------------------------
        $display("\n");
        $display("====================================");
        $display("      CLA VERIFICATION SUMMARY");
        $display("====================================");
        $display("Total Tests : %0d", total_tests);
        $display("Pass Count  : %0d", pass_count);
        $display("Fail Count  : %0d", fail_count);
        $display("====================================");

        if(fail_count == 0)
        begin
            $display("STATUS : PASS");
        end
        else
        begin
            $display("STATUS : FAIL");
        end

        $display("====================================");

        #20;
        $finish;

    end

endmodule
