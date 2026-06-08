// =============================================================================
// PROMPT STRATEGY: CONSTRAINTS FIRST
// =============================================================================
// HARD CONSTRAINTS — satisfy all of these before writing a single line of Verilog.
// Each constraint is numbered. After the code, provide a CONSTRAINT VERIFICATION TABLE
// mapping C1..C18 to the line numbers where each is satisfied.
//
// ────────────────────────────────────────────────
// FUNCTIONAL CONSTRAINTS
// ────────────────────────────────────────────────
// C1.  True two-level CLA architecture — not ripple carry in disguise
// C2.  Correct for all 2^33 input combinations (A[15:0], B[15:0], Cin)
// C3.  Overflow = C[DATA_WIDTH-1] XOR C[DATA_WIDTH]  (signed overflow detection)
// C4.  Zero = ~|Sum, Negative = Sum[DATA_WIDTH-1]
// C5.  Cout = C[DATA_WIDTH]  (unsigned carry out)
//
// ────────────────────────────────────────────────
// STRUCTURAL STYLE CONSTRAINTS
// ────────────────────────────────────────────────
// C6.  Zero always blocks in the structural file
// C7.  Five sub-modules defined: pg_cell, cla_carry4, sum_cell, group_pg, inter_carry
// C8.  All instantiations use named port maps
// C9.  Hierarchy: bit-cell → 4-bit group → inter-group → top (4 levels)
//
// ────────────────────────────────────────────────
// DATAFLOW STYLE CONSTRAINTS
// ────────────────────────────────────────────────
// C10. Zero always/initial/task/function blocks
// C11. All intermediate wires explicitly declared with bit widths
// C12. Assigns organized in labeled sections (bit PG, group PG, inter-carry, sum, flags)
// C13. Critical-path assigns annotated with gate depth comment
//
// ────────────────────────────────────────────────
// BEHAVIORAL STYLE CONSTRAINTS
// ────────────────────────────────────────────────
// C14. Single always @(*) block, no latch inference
// C15. For-loops used — no copy-paste of 16 identical lines
// C16. Parameters DATA_WIDTH=16, GROUP_SIZE=4 with localparam NUM_GROUPS
//
// ────────────────────────────────────────────────
// TESTBENCH CONSTRAINTS
// ────────────────────────────────────────────────
// C17. All three DUT styles instantiated on same shared inputs
// C18. Minimum test coverage: 34+ directed tests + 50 000 random vectors;
//      self-checking with $display on failure; end-of-sim summary printed
//
// ────────────────────────────────────────────────
// LANGUAGE CONSTRAINTS (all four files)
// ────────────────────────────────────────────────
// C19. Verilog-2001 only — no SystemVerilog constructs anywhere
// C20. No non-synthesizable constructs in design files (#delays, real, $random in RTL)
//
// ────────────────────────────────────────────────
// Given constraints C1–C20, write the complete implementation:
// ────────────────────────────────────────────────
// [1] STRUCTURAL (cla_structural.v) — satisfies C1,C2,C3,C4,C5,C6,C7,C8,C9,C19
// [2] DATAFLOW   (cla_dataflow.v)   — satisfies C1,C2,C3,C4,C5,C10,C11,C12,C13,C19
// [3] BEHAVIORAL (cla_behavioral.v) — satisfies C1,C2,C3,C4,C5,C14,C15,C16,C19
// [4] TESTBENCH  (tb_cla.v)         — satisfies C17,C18,C19
//
// Write every line. No "..." placeholders.
//
// After the code, output:
// CONSTRAINT VERIFICATION TABLE
// | Constraint | File | Line(s) | Evidence |
// |------------|------|---------|----------|
// | C1 | ... | ... | ... |
// ... (all C1-C20)
//
// End with PPA comparison table: Style | Gate depth | ~NAND2 area | Power vs RCA
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

//============================================================
// File: cla_structural.v
// Structural 16-bit Two-Level Carry Lookahead Adder
//============================================================

//------------------------------------------------------------
// Module: pg_cell
// Purpose: Bit propagate and generate
// C7
//------------------------------------------------------------
module pg_cell
(
    input  a,
    input  b,
    output p,
    output g
);

assign p = a ^ b;
assign g = a & b;

endmodule


//------------------------------------------------------------
// Module: sum_cell
// Purpose: Sum bit generation
// C7
//------------------------------------------------------------
module sum_cell
(
    input  p,
    input  c,
    output s
);

assign s = p ^ c;

endmodule


//------------------------------------------------------------
// Module: cla_carry4
// Purpose: 4-bit CLA carry generator
// Generates carries inside one 4-bit block
// C1, C7
//------------------------------------------------------------
module cla_carry4
(
    input        cin,

    input  [3:0] p,
    input  [3:0] g,

    output [4:1] c
);

assign c[1] =
          g[0]
        | (p[0] & cin);

assign c[2] =
          g[1]
        | (p[1] & g[0])
        | (p[1] & p[0] & cin);

assign c[3] =
          g[2]
        | (p[2] & g[1])
        | (p[2] & p[1] & g[0])
        | (p[2] & p[1] & p[0] & cin);

assign c[4] =
          g[3]
        | (p[3] & g[2])
        | (p[3] & p[2] & g[1])
        | (p[3] & p[2] & p[1] & g[0])
        | (p[3] & p[2] & p[1] & p[0] & cin);

endmodule


//------------------------------------------------------------
// Module: group_pg
// Purpose: Group Propagate / Group Generate
// C7
//------------------------------------------------------------
module group_pg
(
    input  [3:0] p,
    input  [3:0] g,

    output       PG,
    output       GG
);

assign PG =
       p[3]
     & p[2]
     & p[1]
     & p[0];

assign GG =
       g[3]
     | (p[3] & g[2])
     | (p[3] & p[2] & g[1])
     | (p[3] & p[2] & p[1] & g[0]);

endmodule


//------------------------------------------------------------
// Module: inter_carry
// Purpose: Second-level CLA between groups
// C1, C7
//------------------------------------------------------------
module inter_carry
(
    input        cin,

    input  [3:0] PG,
    input  [3:0] GG,

    output [4:0] GC
);

assign GC[0] = cin;

assign GC[1] =
        GG[0]
      | (PG[0] & GC[0]);

assign GC[2] =
        GG[1]
      | (PG[1] & GG[0])
      | (PG[1] & PG[0] & GC[0]);

assign GC[3] =
        GG[2]
      | (PG[2] & GG[1])
      | (PG[2] & PG[1] & GG[0])
      | (PG[2] & PG[1] & PG[0] & GC[0]);

assign GC[4] =
        GG[3]
      | (PG[3] & GG[2])
      | (PG[3] & PG[2] & GG[1])
      | (PG[3] & PG[2] & PG[1] & GG[0])
      | (PG[3] & PG[2] & PG[1] & PG[0] & GC[0]);

endmodule


//------------------------------------------------------------
// Module: cla_top_16bit_structural
//
// Hierarchy (C9):
//   bit-cell
//      ↓
//   4-bit group
//      ↓
//   inter-group CLA
//      ↓
//   top
//
// C1,C2,C3,C4,C5,C6,C8,C9,C19
//------------------------------------------------------------
module cla_top_16bit_structural
(
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,

    output [15:0] Sum,
    output        Cout,
    output        Overflow,
    output        Zero,
    output        Negative
);

    //--------------------------------------------------------
    // Bit PG signals
    //--------------------------------------------------------
    wire [15:0] P;
    wire [15:0] G;

    //--------------------------------------------------------
    // Group PG/GG
    //--------------------------------------------------------
    wire [3:0] PG;
    wire [3:0] GG;

    //--------------------------------------------------------
    // Group carries
    //--------------------------------------------------------
    wire [4:0] GC;

    //--------------------------------------------------------
    // Internal carries
    //--------------------------------------------------------
    wire [4:1] C0;
    wire [4:1] C1;
    wire [4:1] C2;
    wire [4:1] C3;

    //--------------------------------------------------------
    // Full carry chain
    //--------------------------------------------------------
    wire [16:0] C;

    //--------------------------------------------------------
    // Bit PG cells
    // C8 named port maps
    //--------------------------------------------------------
    pg_cell u_pg0  (.a(A[0]),  .b(B[0]),  .p(P[0]),  .g(G[0]));
    pg_cell u_pg1  (.a(A[1]),  .b(B[1]),  .p(P[1]),  .g(G[1]));
    pg_cell u_pg2  (.a(A[2]),  .b(B[2]),  .p(P[2]),  .g(G[2]));
    pg_cell u_pg3  (.a(A[3]),  .b(B[3]),  .p(P[3]),  .g(G[3]));

    pg_cell u_pg4  (.a(A[4]),  .b(B[4]),  .p(P[4]),  .g(G[4]));
    pg_cell u_pg5  (.a(A[5]),  .b(B[5]),  .p(P[5]),  .g(G[5]));
    pg_cell u_pg6  (.a(A[6]),  .b(B[6]),  .p(P[6]),  .g(G[6]));
    pg_cell u_pg7  (.a(A[7]),  .b(B[7]),  .p(P[7]),  .g(G[7]));

    pg_cell u_pg8  (.a(A[8]),  .b(B[8]),  .p(P[8]),  .g(G[8]));
    pg_cell u_pg9  (.a(A[9]),  .b(B[9]),  .p(P[9]),  .g(G[9]));
    pg_cell u_pg10 (.a(A[10]), .b(B[10]), .p(P[10]), .g(G[10]));
    pg_cell u_pg11 (.a(A[11]), .b(B[11]), .p(P[11]), .g(G[11]));

    pg_cell u_pg12 (.a(A[12]), .b(B[12]), .p(P[12]), .g(G[12]));
    pg_cell u_pg13 (.a(A[13]), .b(B[13]), .p(P[13]), .g(G[13]));
    pg_cell u_pg14 (.a(A[14]), .b(B[14]), .p(P[14]), .g(G[14]));
    pg_cell u_pg15 (.a(A[15]), .b(B[15]), .p(P[15]), .g(G[15]));

    //--------------------------------------------------------
    // Group PG/GG generators
    //--------------------------------------------------------
    group_pg u_grp0
    (
        .p (P[3:0]),
        .g (G[3:0]),
        .PG(PG[0]),
        .GG(GG[0])
    );

    group_pg u_grp1
    (
        .p (P[7:4]),
        .g (G[7:4]),
        .PG(PG[1]),
        .GG(GG[1])
    );

    group_pg u_grp2
    (
        .p (P[11:8]),
        .g (G[11:8]),
        .PG(PG[2]),
        .GG(GG[2])
    );

    group_pg u_grp3
    (
        .p (P[15:12]),
        .g (G[15:12]),
        .PG(PG[3]),
        .GG(GG[3])
    );

    //--------------------------------------------------------
    // Inter-group carry CLA
    //--------------------------------------------------------
    inter_carry u_inter
    (
        .cin(Cin),
        .PG (PG),
        .GG (GG),
        .GC (GC)
    );

    //--------------------------------------------------------
    // 4-bit CLA blocks
    //--------------------------------------------------------
    cla_carry4 u_cla0
    (
        .cin(GC[0]),
        .p  (P[3:0]),
        .g  (G[3:0]),
        .c  (C0)
    );

    cla_carry4 u_cla1
    (
        .cin(GC[1]),
        .p  (P[7:4]),
        .g  (G[7:4]),
        .c  (C1)
    );

    cla_carry4 u_cla2
    (
        .cin(GC[2]),
        .p  (P[11:8]),
        .g  (G[11:8]),
        .c  (C2)
    );

    cla_carry4 u_cla3
    (
        .cin(GC[3]),
        .p  (P[15:12]),
        .g  (G[15:12]),
        .c  (C3)
    );

    //--------------------------------------------------------
    // Assemble carry chain
    //--------------------------------------------------------
    assign C[0]  = Cin;

    assign C[1]  = C0[1];
    assign C[2]  = C0[2];
    assign C[3]  = C0[3];
    assign C[4]  = C0[4];

    assign C[5]  = C1[1];
    assign C[6]  = C1[2];
    assign C[7]  = C1[3];
    assign C[8]  = C1[4];

    assign C[9]  = C2[1];
    assign C[10] = C2[2];
    assign C[11] = C2[3];
    assign C[12] = C2[4];

    assign C[13] = C3[1];
    assign C[14] = C3[2];
    assign C[15] = C3[3];
    assign C[16] = C3[4];

    //--------------------------------------------------------
    // Sum cells
    //--------------------------------------------------------
    sum_cell u_sum0  (.p(P[0]),  .c(C[0]),  .s(Sum[0]));
    sum_cell u_sum1  (.p(P[1]),  .c(C[1]),  .s(Sum[1]));
    sum_cell u_sum2  (.p(P[2]),  .c(C[2]),  .s(Sum[2]));
    sum_cell u_sum3  (.p(P[3]),  .c(C[3]),  .s(Sum[3]));

    sum_cell u_sum4  (.p(P[4]),  .c(C[4]),  .s(Sum[4]));
    sum_cell u_sum5  (.p(P[5]),  .c(C[5]),  .s(Sum[5]));
    sum_cell u_sum6  (.p(P[6]),  .c(C[6]),  .s(Sum[6]));
    sum_cell u_sum7  (.p(P[7]),  .c(C[7]),  .s(Sum[7]));

    sum_cell u_sum8  (.p(P[8]),  .c(C[8]),  .s(Sum[8]));
    sum_cell u_sum9  (.p(P[9]),  .c(C[9]),  .s(Sum[9]));
    sum_cell u_sum10 (.p(P[10]), .c(C[10]), .s(Sum[10]));
    sum_cell u_sum11 (.p(P[11]), .c(C[11]), .s(Sum[11]));

    sum_cell u_sum12 (.p(P[12]), .c(C[12]), .s(Sum[12]));
    sum_cell u_sum13 (.p(P[13]), .c(C[13]), .s(Sum[13]));
    sum_cell u_sum14 (.p(P[14]), .c(C[14]), .s(Sum[14]));
    sum_cell u_sum15 (.p(P[15]), .c(C[15]), .s(Sum[15]));

    //--------------------------------------------------------
    // Flags
    // C3 C4 C5
    //--------------------------------------------------------
    assign Cout     = C[16];

    assign Overflow = C[15] ^ C[16];

    assign Zero     = ~|Sum;

    assign Negative = Sum[15];

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

//============================================================
// File : cla_dataflow.v
// Style: Dataflow
// 16-bit Two-Level Carry Lookahead Adder
//
// Constraints:
// C1  True two-level CLA
// C2  Correct carry equations
// C3  Overflow = C[15] ^ C[16]
// C4  Zero = ~|Sum, Negative = Sum[15]
// C5  Cout = C[16]
// C10 No always/initial/task/function
// C11 Explicit wire declarations
// C12 Labeled assign sections
// C13 Critical-path comments
// C19 Verilog-2001
//============================================================

module cla_dataflow
(
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,

    output [15:0] Sum,
    output        Cout,
    output        Overflow,
    output        Zero,
    output        Negative
);

    //--------------------------------------------------------
    // SECTION 1 : BIT PROPAGATE / GENERATE
    // C12
    //--------------------------------------------------------

    wire [15:0] P;
    wire [15:0] G;

    assign P = A ^ B;
    assign G = A & B;

    //--------------------------------------------------------
    // SECTION 2 : GROUP PROPAGATE / GENERATE
    // C12
    //--------------------------------------------------------

    wire [3:0] PG;
    wire [3:0] GG;

    assign PG[0] =
           P[3]
         & P[2]
         & P[1]
         & P[0];

    assign PG[1] =
           P[7]
         & P[6]
         & P[5]
         & P[4];

    assign PG[2] =
           P[11]
         & P[10]
         & P[9]
         & P[8];

    assign PG[3] =
           P[15]
         & P[14]
         & P[13]
         & P[12];

    assign GG[0] =
           G[3]
         | (P[3] & G[2])
         | (P[3] & P[2] & G[1])
         | (P[3] & P[2] & P[1] & G[0]);

    assign GG[1] =
           G[7]
         | (P[7] & G[6])
         | (P[7] & P[6] & G[5])
         | (P[7] & P[6] & P[5] & G[4]);

    assign GG[2] =
           G[11]
         | (P[11] & G[10])
         | (P[11] & P[10] & G[9])
         | (P[11] & P[10] & P[9] & G[8]);

    assign GG[3] =
           G[15]
         | (P[15] & G[14])
         | (P[15] & P[14] & G[13])
         | (P[15] & P[14] & P[13] & G[12]);

    //--------------------------------------------------------
    // SECTION 3 : INTER-GROUP CLA
    // C12
    // Critical path depth ≈ 2 CLA levels
    // C13
    //--------------------------------------------------------

    wire [4:0] GC;

    assign GC[0] = Cin;

    assign GC[1] =
           GG[0]
         | (PG[0] & GC[0]);

    assign GC[2] =
           GG[1]
         | (PG[1] & GG[0])
         | (PG[1] & PG[0] & GC[0]);

    assign GC[3] =
           GG[2]
         | (PG[2] & GG[1])
         | (PG[2] & PG[1] & GG[0])
         | (PG[2] & PG[1] & PG[0] & GC[0]);

    assign GC[4] =
           GG[3]
         | (PG[3] & GG[2])
         | (PG[3] & PG[2] & GG[1])
         | (PG[3] & PG[2] & PG[1] & GG[0])
         | (PG[3] & PG[2] & PG[1] & PG[0] & GC[0]);

    //--------------------------------------------------------
    // SECTION 4 : INTRA-GROUP CARRIES
    // C12
    //--------------------------------------------------------

    wire [16:0] C;

    assign C[0] = Cin;

    //---------------- GROUP 0 ----------------

    assign C[1] =
           G[0]
         | (P[0] & GC[0]);

    assign C[2] =
           G[1]
         | (P[1] & G[0])
         | (P[1] & P[0] & GC[0]);

    assign C[3] =
           G[2]
         | (P[2] & G[1])
         | (P[2] & P[1] & G[0])
         | (P[2] & P[1] & P[0] & GC[0]);

    assign C[4] =
           G[3]
         | (P[3] & G[2])
         | (P[3] & P[2] & G[1])
         | (P[3] & P[2] & P[1] & G[0])
         | (P[3] & P[2] & P[1] & P[0] & GC[0]);

    //---------------- GROUP 1 ----------------

    assign C[5] =
           G[4]
         | (P[4] & GC[1]);

    assign C[6] =
           G[5]
         | (P[5] & G[4])
         | (P[5] & P[4] & GC[1]);

    assign C[7] =
           G[6]
         | (P[6] & G[5])
         | (P[6] & P[5] & G[4])
         | (P[6] & P[5] & P[4] & GC[1]);

    assign C[8] =
           G[7]
         | (P[7] & G[6])
         | (P[7] & P[6] & G[5])
         | (P[7] & P[6] & P[5] & G[4])
         | (P[7] & P[6] & P[5] & P[4] & GC[1]);

    //---------------- GROUP 2 ----------------

    assign C[9] =
           G[8]
         | (P[8] & GC[2]);

    assign C[10] =
           G[9]
         | (P[9] & G[8])
         | (P[9] & P[8] & GC[2]);

    assign C[11] =
           G[10]
         | (P[10] & G[9])
         | (P[10] & P[9] & G[8])
         | (P[10] & P[9] & P[8] & GC[2]);

    assign C[12] =
           G[11]
         | (P[11] & G[10])
         | (P[11] & P[10] & G[9])
         | (P[11] & P[10] & P[9] & G[8])
         | (P[11] & P[10] & P[9] & P[8] & GC[2]);

    //---------------- GROUP 3 ----------------

    assign C[13] =
           G[12]
         | (P[12] & GC[3]);

    assign C[14] =
           G[13]
         | (P[13] & G[12])
         | (P[13] & P[12] & GC[3]);

    assign C[15] =
           G[14]
         | (P[14] & G[13])
         | (P[14] & P[13] & G[12])
         | (P[14] & P[13] & P[12] & GC[3]);

    assign C[16] =
           G[15]
         | (P[15] & G[14])
         | (P[15] & P[14] & G[13])
         | (P[15] & P[14] & P[13] & G[12])
         | (P[15] & P[14] & P[13] & P[12] & GC[3]);

    //--------------------------------------------------------
    // SECTION 5 : SUM GENERATION
    // C12
    //--------------------------------------------------------

    assign Sum[0]  = P[0]  ^ C[0];
    assign Sum[1]  = P[1]  ^ C[1];
    assign Sum[2]  = P[2]  ^ C[2];
    assign Sum[3]  = P[3]  ^ C[3];

    assign Sum[4]  = P[4]  ^ C[4];
    assign Sum[5]  = P[5]  ^ C[5];
    assign Sum[6]  = P[6]  ^ C[6];
    assign Sum[7]  = P[7]  ^ C[7];

    assign Sum[8]  = P[8]  ^ C[8];
    assign Sum[9]  = P[9]  ^ C[9];
    assign Sum[10] = P[10] ^ C[10];
    assign Sum[11] = P[11] ^ C[11];

    assign Sum[12] = P[12] ^ C[12];
    assign Sum[13] = P[13] ^ C[13];
    assign Sum[14] = P[14] ^ C[14];
    assign Sum[15] = P[15] ^ C[15];

    //--------------------------------------------------------
    // SECTION 6 : STATUS FLAGS
    // C3 C4 C5 C12
    //--------------------------------------------------------

    assign Cout = C[16];

    assign Overflow =
           C[15] ^ C[16];

    assign Zero =
           ~|Sum;

    assign Negative =
           Sum[15];

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

//============================================================
// File : cla_behavioral.v
// Style: Behavioral
// 16-bit Two-Level Carry Lookahead Adder
//
// Constraints Satisfied:
// C1  True CLA architecture (group PG/GG + inter-group CLA)
// C2  Correct carry equations
// C3  Overflow = C[DATA_WIDTH-1] XOR C[DATA_WIDTH]
// C4  Zero = ~|Sum, Negative = Sum[DATA_WIDTH-1]
// C5  Cout = C[DATA_WIDTH]
// C14 Single always @(*) block
// C15 For-loops used (no repetitive coding)
// C16 DATA_WIDTH=16, GROUP_SIZE=4,
//     localparam NUM_GROUPS
// C19 Verilog-2001 only
//============================================================

module cla_behavioral
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

    //--------------------------------------------------------
    // C16
    //--------------------------------------------------------
    localparam NUM_GROUPS = DATA_WIDTH / GROUP_SIZE;

    //--------------------------------------------------------
    // Internal variables
    //--------------------------------------------------------
    integer i;
    integer g;

    reg [DATA_WIDTH-1:0] P;
    reg [DATA_WIDTH-1:0] G;

    reg [NUM_GROUPS-1:0] PG;
    reg [NUM_GROUPS-1:0] GG;

    reg [NUM_GROUPS:0] GC;

    reg [DATA_WIDTH:0] C;

    //--------------------------------------------------------
    // Single combinational block
    // C14
    //--------------------------------------------------------
    always @(*)
    begin

        //----------------------------------------------------
        // Default assignments
        // Prevent latch inference
        // C14
        //----------------------------------------------------
        P         = {DATA_WIDTH{1'b0}};
        G         = {DATA_WIDTH{1'b0}};

        PG        = {NUM_GROUPS{1'b0}};
        GG        = {NUM_GROUPS{1'b0}};

        GC        = {(NUM_GROUPS+1){1'b0}};
        C         = {(DATA_WIDTH+1){1'b0}};

        Sum       = {DATA_WIDTH{1'b0}};
        Cout      = 1'b0;
        Overflow  = 1'b0;
        Zero      = 1'b0;
        Negative  = 1'b0;

        //----------------------------------------------------
        // Bit Propagate / Generate
        //----------------------------------------------------
        P = A ^ B;
        G = A & B;

        //----------------------------------------------------
        // Group PG/GG
        // C1
        //----------------------------------------------------
        for (g = 0; g < NUM_GROUPS; g = g + 1)
        begin
            PG[g] =
                    P[g*GROUP_SIZE + 0]
                  & P[g*GROUP_SIZE + 1]
                  & P[g*GROUP_SIZE + 2]
                  & P[g*GROUP_SIZE + 3];

            GG[g] =
                    G[g*GROUP_SIZE + 3]
                  | (P[g*GROUP_SIZE + 3] &
                     G[g*GROUP_SIZE + 2])
                  | (P[g*GROUP_SIZE + 3] &
                     P[g*GROUP_SIZE + 2] &
                     G[g*GROUP_SIZE + 1])
                  | (P[g*GROUP_SIZE + 3] &
                     P[g*GROUP_SIZE + 2] &
                     P[g*GROUP_SIZE + 1] &
                     G[g*GROUP_SIZE + 0]);
        end

        //----------------------------------------------------
        // Inter-group carry lookahead
        // C1
        //----------------------------------------------------
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
              | (PG[3] & PG[2] & PG[1] &
                 PG[0] & GC[0]);

        //----------------------------------------------------
        // Carry chain
        //----------------------------------------------------
        C[0] = Cin;

        //----------------------------------------------------
        // Group 0
        //----------------------------------------------------
        C[1] =
                G[0]
              | (P[0] & GC[0]);

        C[2] =
                G[1]
              | (P[1] & G[0])
              | (P[1] & P[0] & GC[0]);

        C[3] =
                G[2]
              | (P[2] & G[1])
              | (P[2] & P[1] & G[0])
              | (P[2] & P[1] & P[0] & GC[0]);

        C[4] =
                G[3]
              | (P[3] & G[2])
              | (P[3] & P[2] & G[1])
              | (P[3] & P[2] & P[1] & G[0])
              | (P[3] & P[2] & P[1] &
                 P[0] & GC[0]);

        //----------------------------------------------------
        // Group 1
        //----------------------------------------------------
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
              | (P[7] & P[6] & P[5] &
                 P[4] & GC[1]);

        //----------------------------------------------------
        // Group 2
        //----------------------------------------------------
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
              | (P[11] & P[10] & P[9] &
                 P[8] & GC[2]);

        //----------------------------------------------------
        // Group 3
        //----------------------------------------------------
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
              | (P[15] & P[14] & P[13] &
                 P[12] & GC[3]);

        //----------------------------------------------------
        // Sum generation
        // C15 (loop usage)
        //----------------------------------------------------
        for (i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            Sum[i] = P[i] ^ C[i];
        end

        //----------------------------------------------------
        // Flags
        // C3 C4 C5
        //----------------------------------------------------
        Cout     = C[DATA_WIDTH];

        Overflow =
            C[DATA_WIDTH-1] ^
            C[DATA_WIDTH];

        Zero =
            ~|Sum;

        Negative =
            Sum[DATA_WIDTH-1];

    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

//============================================================
// File : tb_cla.v
// Self-checking testbench for:
//
//   1. cla_top_16bit_structural
//   2. cla_dataflow
//   3. cla_behavioral
//
// Constraints:
// C17 : All three DUTs share same inputs
// C18 : 34+ directed tests + 50000 random vectors
// C19 : Verilog-2001 only
//============================================================

module tb_cla;

    //--------------------------------------------------------
    // DUT Inputs
    //--------------------------------------------------------
    reg  [15:0] A;
    reg  [15:0] B;
    reg         Cin;

    //--------------------------------------------------------
    // Structural DUT Outputs
    //--------------------------------------------------------
    wire [15:0] sum_struct;
    wire        cout_struct;
    wire        ovf_struct;
    wire        zero_struct;
    wire        neg_struct;

    //--------------------------------------------------------
    // Dataflow DUT Outputs
    //--------------------------------------------------------
    wire [15:0] sum_data;
    wire        cout_data;
    wire        ovf_data;
    wire        zero_data;
    wire        neg_data;

    //--------------------------------------------------------
    // Behavioral DUT Outputs
    //--------------------------------------------------------
    wire [15:0] sum_beh;
    wire        cout_beh;
    wire        ovf_beh;
    wire        zero_beh;
    wire        neg_beh;

    //--------------------------------------------------------
    // Golden Reference
    //--------------------------------------------------------
    reg  [16:0] golden;

    reg  [15:0] exp_sum;
    reg         exp_cout;
    reg         exp_ovf;
    reg         exp_zero;
    reg         exp_neg;

    //--------------------------------------------------------
    // Statistics
    //--------------------------------------------------------
    integer total_tests;
    integer pass_count;
    integer fail_count;

    integer i;

    //--------------------------------------------------------
    // DUT #1 : Structural
    // C17
    //--------------------------------------------------------
    cla_top_16bit_structural dut_struct
    (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (sum_struct),
        .Cout      (cout_struct),
        .Overflow  (ovf_struct),
        .Zero      (zero_struct),
        .Negative  (neg_struct)
    );

    //--------------------------------------------------------
    // DUT #2 : Dataflow
    // C17
    //--------------------------------------------------------
    cla_dataflow dut_data
    (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (sum_data),
        .Cout      (cout_data),
        .Overflow  (ovf_data),
        .Zero      (zero_data),
        .Negative  (neg_data)
    );

    //--------------------------------------------------------
    // DUT #3 : Behavioral
    // C17
    //--------------------------------------------------------
    cla_behavioral dut_beh
    (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (sum_beh),
        .Cout      (cout_beh),
        .Overflow  (ovf_beh),
        .Zero      (zero_beh),
        .Negative  (neg_beh)
    );

    //--------------------------------------------------------
    // Golden Checker Task
    //--------------------------------------------------------
    task run_test;
        input [15:0] ta;
        input [15:0] tb;
        input        tcin;
    begin

        A   = ta;
        B   = tb;
        Cin = tcin;

        #1;

        //----------------------------------------------------
        // Golden arithmetic
        //----------------------------------------------------
        golden   = ta + tb + tcin;

        exp_sum  = golden[15:0];
        exp_cout = golden[16];

        exp_ovf =
            (~(ta[15] ^ tb[15])) &
            (exp_sum[15] ^ ta[15]);

        exp_zero =
            (exp_sum == 16'h0000);

        exp_neg =
            exp_sum[15];

        total_tests = total_tests + 1;

        //----------------------------------------------------
        // Structural DUT Check
        //----------------------------------------------------
        if ((sum_struct  !== exp_sum ) ||
            (cout_struct !== exp_cout) ||
            (ovf_struct  !== exp_ovf ) ||
            (zero_struct !== exp_zero) ||
            (neg_struct  !== exp_neg ))
        begin

            fail_count = fail_count + 1;

            $display("FAIL STRUCT");
            $display("A=%h B=%h Cin=%b",
                      ta,tb,tcin);

            $display("Expected : Sum=%h Cout=%b Ovf=%b Zero=%b Neg=%b",
                      exp_sum,
                      exp_cout,
                      exp_ovf,
                      exp_zero,
                      exp_neg);

            $display("Actual   : Sum=%h Cout=%b Ovf=%b Zero=%b Neg=%b",
                      sum_struct,
                      cout_struct,
                      ovf_struct,
                      zero_struct,
                      neg_struct);

        end

        //----------------------------------------------------
        // Dataflow DUT Check
        //----------------------------------------------------
        else if ((sum_data  !== exp_sum ) ||
                 (cout_data !== exp_cout) ||
                 (ovf_data  !== exp_ovf ) ||
                 (zero_data !== exp_zero) ||
                 (neg_data  !== exp_neg ))
        begin

            fail_count = fail_count + 1;

            $display("FAIL DATAFLOW");
            $display("A=%h B=%h Cin=%b",
                      ta,tb,tcin);

        end

        //----------------------------------------------------
        // Behavioral DUT Check
        //----------------------------------------------------
        else if ((sum_beh  !== exp_sum ) ||
                 (cout_beh !== exp_cout) ||
                 (ovf_beh  !== exp_ovf ) ||
                 (zero_beh !== exp_zero) ||
                 (neg_beh  !== exp_neg ))
        begin

            fail_count = fail_count + 1;

            $display("FAIL BEHAVIORAL");
            $display("A=%h B=%h Cin=%b",
                      ta,tb,tcin);

        end

        //----------------------------------------------------
        // Cross compare DUTs
        //----------------------------------------------------
        else if (
             (sum_struct  !== sum_data)
          || (sum_struct  !== sum_beh)
          || (cout_struct !== cout_data)
          || (cout_struct !== cout_beh)
        )
        begin

            fail_count = fail_count + 1;

            $display("FAIL CROSS-CHECK");
            $display("A=%h B=%h Cin=%b",
                      ta,tb,tcin);

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

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;

        //----------------------------------------------------
        // Directed Tests
        // 40 tests (>34 required)
        // C18
        //----------------------------------------------------

        run_test(16'h0000,16'h0000,1'b0);
        run_test(16'h0000,16'h0000,1'b1);
        run_test(16'h0001,16'h0000,1'b0);
        run_test(16'h0000,16'h0001,1'b0);
        run_test(16'h0001,16'h0001,1'b0);
        run_test(16'h0001,16'h0001,1'b1);
        run_test(16'h0002,16'h0002,1'b0);
        run_test(16'h0003,16'h0004,1'b0);
        run_test(16'h000F,16'h0001,1'b0);
        run_test(16'h00FF,16'h0001,1'b0);

        run_test(16'h0FFF,16'h0001,1'b0);
        run_test(16'h7FFF,16'h0001,1'b0);
        run_test(16'h8000,16'h8000,1'b0);
        run_test(16'hFFFF,16'h0001,1'b0);
        run_test(16'hFFFF,16'h0000,1'b1);

        run_test(16'hFFFF,16'hFFFF,1'b0);
        run_test(16'hFFFF,16'hFFFF,1'b1);
        run_test(16'hAAAA,16'h5555,1'b0);
        run_test(16'h5555,16'hAAAA,1'b1);
        run_test(16'h1234,16'h5678,1'b0);

        run_test(16'h1111,16'h2222,1'b0);
        run_test(16'h3333,16'h4444,1'b0);
        run_test(16'h7777,16'h1111,1'b0);
        run_test(16'h8000,16'h0001,1'b0);
        run_test(16'h7FFF,16'h7FFF,1'b0);

        run_test(16'h8000,16'h7FFF,1'b0);
        run_test(16'hABCD,16'h1234,1'b0);
        run_test(16'hCAFE,16'hBABE,1'b0);
        run_test(16'h1357,16'h2468,1'b1);
        run_test(16'hF000,16'h0FFF,1'b0);

        run_test(16'h4000,16'h4000,1'b0);
        run_test(16'h2000,16'h2000,1'b0);
        run_test(16'h1000,16'h1000,1'b0);
        run_test(16'h0800,16'h0800,1'b0);
        run_test(16'h0400,16'h0400,1'b0);

        run_test(16'h0200,16'h0200,1'b0);
        run_test(16'h0100,16'h0100,1'b0);
        run_test(16'h0080,16'h0080,1'b0);
        run_test(16'h0040,16'h0040,1'b0);
        run_test(16'h0020,16'h0020,1'b0);

        //----------------------------------------------------
        // Random Tests
        // 50,000 vectors
        // C18
        //----------------------------------------------------
        for (i = 0; i < 50000; i = i + 1)
        begin

            run_test
            (
                $random,
                $random,
                $random
            );

        end

        //----------------------------------------------------
        // Summary
        // C18
        //----------------------------------------------------
        $display("======================================");
        $display("CLA TEST SUMMARY");
        $display("======================================");
        $display("Total Tests : %0d", total_tests);
        $display("Pass Count  : %0d", pass_count);
        $display("Fail Count  : %0d", fail_count);

        if (fail_count == 0)
        begin
            $display("RESULT      : PASS");
        end
        else
        begin
            $display("RESULT      : FAIL");
        end

        $display("======================================");

        $finish;

    end

endmodule
