// =============================================================================
// PROMPT STRATEGY: NEGATIVE PROMPTING
// =============================================================================
// Write a complete 16-bit Carry Lookahead Adder in Verilog — three styles plus a testbench.
//
// ────────────────────────────────────────────────
//    DO NOT DO ANY OF THE FOLLOWING (common mistakes)
// ────────────────────────────────────────────────
// ARCHITECTURE MISTAKES:
//   ✗ Do NOT write a ripple-carry adder inside a behavioral always block and call it CLA
//   ✗ Do NOT use the simple loop  C[i+1] = G[i]|(P[i]&C[i])  as your "CLA" — that is O(N) ripple
//   ✗ Do NOT compute group carries one at a time sequentially — they must all be derived
//     from pre-computed group P/G signals (true parallel lookahead)
//   ✗ Do NOT hardcode carry equations for only one specific input size
//
// STRUCTURAL MISTAKES:
//   ✗ Do NOT use always blocks or assign in the structural version
//   ✗ Do NOT use positional port connections — use named port maps (.port(wire))
//   ✗ Do NOT leave sub-modules undefined (pg_cell, cla_carry4, sum_cell, group_pg, inter_carry must
// all exist)
//
// DATAFLOW MISTAKES:
//   ✗ Do NOT use always, initial, task, or function — assign only
//   ✗ Do NOT use undeclared implicit wires
//   ✗ Do NOT forget the inter-group carry assigns (C[4], C[8], C[12], C[16])
//
// BEHAVIORAL MISTAKES:
//   ✗ Do NOT create latches — ensure always @(*) drives every output in every path
//   ✗ Do NOT use SystemVerilog constructs (logic, always_comb, etc.)
//   ✗ Do NOT forget to initialize GC[0] = Cin before the carry loop
//
// FLAG MISTAKES:
//   ✗ Do NOT compute Overflow as just Cout — correct formula is C[N-1] XOR C[N]
//   ✗ Do NOT forget Zero = ~|Sum and Negative = Sum[DATA_WIDTH-1]
//
// TESTBENCH MISTAKES:
//   ✗ Do NOT instantiate only one DUT — all three styles must be tested together
//   ✗ Do NOT use SystemVerilog assertions — plain Verilog-2001 $display/$error only
//   ✗ Do NOT skip directed tests — random alone is insufficient
//   ✗ Do NOT use real or shortreal types for reference arithmetic
//
// ────────────────────────────────────────────────
//    WHAT YOU SHOULD DO INSTEAD
// ────────────────────────────────────────────────
// CORRECT CLA approach:
//   1. Compute P[i]=A[i]^B[i], G[i]=A[i]&B[i] for all bits
//   2. Derive group-level P_Gk = AND(P[4k+3:4k]), G_Gk = OR-of-AND expansion
//   3. Compute ALL group carries simultaneously: C_group[k+1] = G_Gk | (P_Gk & C_group[k])
//      (this is the lookahead — C_group[k] depends only on Cin, not on C_group[k-1] chain)
//   4. Fill bit-level carries within each group using bit lookahead equations
//   5. Sum[i] = P[i] ^ C[i]
//
// Deliver FOUR sections:
// [1] STRUCTURAL — pg_cell, cla_carry4, sum_cell, group_pg, inter_carry, top. Named ports. PPA
// header.
// [2] DATAFLOW   — assign only. Sections: bit PG → group PG → inter-group C → bit C → sum → flags.
// PPA header.
// [3] BEHAVIORAL — always @(*), for-loops, five labeled steps, all flags. PPA header.
// [4] TESTBENCH  — all 3 DUTs, directed + 50 000 random, self-checking, VCD dump, summary.
//     Params: DATA_WIDTH=16, GROUP_SIZE=4 throughout.
//
// Write every line. No placeholders. End with PPA table.
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

//============================================================
// MODULE: pg_cell
// PURPOSE: Generate and Propagate generation
// Power : Low
// Area  : 2 gates
// Delay : 1 gate level
//============================================================
module pg_cell(
    input  wire a,
    input  wire b,
    output wire p,
    output wire g
);
    xor (p, a, b);
    and (g, a, b);
endmodule


//============================================================
// MODULE: sum_cell
// PURPOSE: Sum bit generation
// Power : Low
// Area  : 1 gate
// Delay : 1 gate level
//============================================================
module sum_cell(
    input  wire p,
    input  wire c,
    output wire s
);
    xor (s, p, c);
endmodule


//============================================================
// MODULE: and2
//============================================================
module and2(
    input  wire a,
    input  wire b,
    output wire y
);
    and (y, a, b);
endmodule


//============================================================
// MODULE: and3
//============================================================
module and3(
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    wire t1;

    and (t1, a, b);
    and (y, t1, c);
endmodule


//============================================================
// MODULE: and4
//============================================================
module and4(
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y
);
    wire t1;
    wire t2;

    and (t1, a, b);
    and (t2, c, d);
    and (y, t1, t2);
endmodule


//============================================================
// MODULE: and5
//============================================================
module and5(
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    input  wire e,
    output wire y
);
    wire t1;
    wire t2;
    wire t3;

    and (t1, a, b);
    and (t2, c, d);
    and (t3, t1, t2);
    and (y, t3, e);
endmodule


//============================================================
// MODULE: or2
//============================================================
module or2(
    input  wire a,
    input  wire b,
    output wire y
);
    or (y, a, b);
endmodule


//============================================================
// MODULE: or3
//============================================================
module or3(
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    or (y, a, b, c);
endmodule


//============================================================
// MODULE: or4
//============================================================
module or4(
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y
);
    or (y, a, b, c, d);
endmodule


//============================================================
// MODULE: or5
//============================================================
module or5(
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    input  wire e,
    output wire y
);
    or (y, a, b, c, d, e);
endmodule


//============================================================
// MODULE: cla_carry4
// PURPOSE: True 4-bit CLA carry generation
// Produces carries in parallel
//============================================================
module cla_carry4(
    input  wire [3:0] P ,
    input  wire [3:0] G,
    input  wire       Cin,

    output wire       C1,
    output wire       C2,
    output wire       C3,
    output wire       Cout
);

    wire t10;

    or2 u_c1(
        .a(G[0]),
        .b(t10),
        .y(C1)
    );

    and2 u_c1_and(
        .a(P[0]),
        .b(Cin),
        .y(t10)
    );

    wire t20,t21;
    wire t22;

    and2 u_c2_a(.a(P[1]),.b(G[0]),.y(t20));
    and3 u_c2_b(.a(P[1]),.b(P[0]),.c(Cin),.y(t21));

    or3 u_c2_o(
        .a(G[1]),
        .b(t20),
        .c(t21),
        .y(C2)
    );

    wire t30,t31,t32;

    and2 u_c3_a(.a(P[2]),.b(G[1]),.y(t30));
    and3 u_c3_b(.a(P[2]),.b(P[1]),.c(G[0]),.y(t31));
    and4 u_c3_c(.a(P[2]),.b(P[1]),.c(P[0]),.d(Cin),.y(t32));

    or4 u_c3_o(
        .a(G[2]),
        .b(t30),
        .c(t31),
        .d(t32),
        .y(C3)
    );

    wire t40,t41,t42,t43;

    and2 u_c4_a(.a(P[3]),.b(G[2]),.y(t40));
    and3 u_c4_b(.a(P[3]),.b(P[2]),.c(G[1]),.y(t41));
    and4 u_c4_c(.a(P[3]),.b(P[2]),.c(P[1]),.d(G[0]),.y(t42));

    and5 u_c4_d(
        .a(P[3]),
        .b(P[2]),
        .c(P[1]),
        .d(P[0]),
        .e(Cin),
        .y(t43)
    );

    or5 u_c4_o(
        .a(G[3]),
        .b(t40),
        .c(t41),
        .d(t42),
        .e(t43),
        .y(Cout)
    );

endmodule


//============================================================
// MODULE: group_pg
// PURPOSE: 4-bit group propagate/generate
//============================================================
module group_pg(
    input  wire [3:0] P ,
    input  wire [3:0] G,

    output wire PG,
    output wire GG
);

    wire gg1,gg2,gg3;

    and4 u_pg(
        .a(P[3]),
        .b(P[2]),
        .c(P[1]),
        .d(P[0]),
        .y(PG)
    );

    and2 u_g1(
        .a(P[3]),
        .b(G[2]),
        .y(gg1)
    );

    and3 u_g2(
        .a(P[3]),
        .b(P[2]),
        .c(G[1]),
        .y(gg2)
    );

    and4 u_g3(
        .a(P[3]),
        .b(P[2]),
        .c(P[1]),
        .d(G[0]),
        .y(gg3)
    );

    or5 u_gg(
        .a(G[3]),
        .b(gg1),
        .c(gg2),
        .d(gg3),
        .e(1'b0),
        .y(GG)
    );

endmodule


//============================================================
// MODULE: inter_carry
// PURPOSE: Parallel inter-group lookahead
// Computes:
// GC[1]=GG0|PG0*Cin
// GC[2]=GG1|PG1*GG0|PG1PG0Cin
// GC[3]=GG2|PG2GG1|PG2PG1GG0|PG2PG1PG0Cin
// GC[4]=GG3|PG3GG2|PG3PG2GG1|PG3PG2PG1GG0|PG3PG2PG1PG0Cin
//============================================================
module inter_carry(
    input  wire [3:0] PG,
    input  wire [3:0] GG,
    input  wire       Cin,

    output wire C4,
    output wire C8,
    output wire C12,
    output wire C16
);

    wire t10;

    and2 a1(.a(PG[0]),.b(Cin),.y(t10));
    or2  o1(.a(GG[0]),.b(t10),.y(C4));

    wire t20,t21;

    and2 a20(.a(PG[1]),.b(GG[0]),.y(t20));
    and3 a21(.a(PG[1]),.b(PG[0]),.c(Cin),.y(t21));

    or3 o2(
        .a(GG[1]),
        .b(t20),
        .c(t21),
        .y(C8)
    );

    wire t30,t31,t32;

    and2 a30(.a(PG[2]),.b(GG[1]),.y(t30));

    and3 a31(
        .a(PG[2]),
        .b(PG[1]),
        .c(GG[0]),
        .y(t31)
    );

    and4 a32(
        .a(PG[2]),
        .b(PG[1]),
        .c(PG[0]),
        .d(Cin),
        .y(t32)
    );

    or4 o3(
        .a(GG[2]),
        .b(t30),
        .c(t31),
        .d(t32),
        .y(C12)
    );

    wire t40,t41,t42,t43;

    and2 a40(.a(PG[3]),.b(GG[2]),.y(t40));

    and3 a41(
        .a(PG[3]),
        .b(PG[2]),
        .c(GG[1]),
        .y(t41)
    );

    and4 a42(
        .a(PG[3]),
        .b(PG[2]),
        .c(PG[1]),
        .d(GG[0]),
        .y(t42)
    );

    and5 a43(
        .a(PG[3]),
        .b(PG[2]),
        .c(PG[1]),
        .d(PG[0]),
        .e(Cin),
        .y(t43)
    );

    or5 o4(
        .a(GG[3]),
        .b(t40),
        .c(t41),
        .d(t42),
        .e(t43),
        .y(C16)
    );

endmodule


//============================================================
// MODULE: cla_top_16bit_structural
// PURPOSE: True 16-bit Carry Lookahead Adder
//============================================================
module cla_top_16bit_structural
(
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,

    output wire [15:0] Sum,
    output wire        Cout,
    output wire        Overflow,
    output wire        Zero,
    output wire        Negative
);

    wire [15:0] P;
    wire [15:0] G;

    genvar i;

    generate
        for(i=0;i<16;i=i+1)
        begin : PG_GEN
            pg_cell u_pg(
                .a(A[i]),
                .b(B[i]),
                .p(P[i]),
                .g(G[i])
            );
        end
    endgenerate

    wire PG0,PG1,PG2,PG3;
    wire GG0,GG1,GG2,GG3;

    group_pg GP0(.P(P[3:0]),   .G(G[3:0]),   .PG(PG0), .GG(GG0));
    group_pg GP1(.P(P[7:4]),   .G(G[7:4]),   .PG(PG1), .GG(GG1));
    group_pg GP2(.P(P[11:8]),  .G(G[11:8]),  .PG(PG2), .GG(GG2));
    group_pg GP3(.P(P[15:12]), .G(G[15:12]), .PG(PG3), .GG(GG3));

    wire C4,C8,C12,C16;

    inter_carry IC(
        .PG({PG3,PG2,PG1,PG0}),
        .GG({GG3,GG2,GG1,GG0}),
        .Cin(Cin),
        .C4(C4),
        .C8(C8),
        .C12(C12),
        .C16(C16)
    );

    wire C1,C2,C3;
    wire C5,C6,C7;
    wire C9,C10,C11;
    wire C13,C14,C15;

    wire dummy0,dummy1,dummy2,dummy3;

    cla_carry4 CLA0(
        .P(P[3:0]),
        .G(G[3:0]),
        .Cin(Cin),
        .C1(C1),
        .C2(C2),
        .C3(C3),
        .Cout(dummy0)
    );

    cla_carry4 CLA1(
        .P(P[7:4]),
        .G(G[7:4]),
        .Cin(C4),
        .C1(C5),
        .C2(C6),
        .C3(C7),
        .Cout(dummy1)
    );

    cla_carry4 CLA2(
        .P(P[11:8]),
        .G(G[11:8]),
        .Cin(C8),
        .C1(C9),
        .C2(C10),
        .C3(C11),
        .Cout(dummy2)
    );

    cla_carry4 CLA3(
        .P(P[15:12]),
        .G(G[15:12]),
        .Cin(C12),
        .C1(C13),
        .C2(C14),
        .C3(C15),
        .Cout(dummy3)
    );

    sum_cell S0 (.p(P[0]),  .c(Cin), .s(Sum[0]));
    sum_cell S1 (.p(P[1]),  .c(C1),  .s(Sum[1]));
    sum_cell S2 (.p(P[2]),  .c(C2),  .s(Sum[2]));
    sum_cell S3 (.p(P[3]),  .c(C3),  .s(Sum[3]));

    sum_cell S4 (.p(P[4]),  .c(C4),  .s(Sum[4]));
    sum_cell S5 (.p(P[5]),  .c(C5),  .s(Sum[5]));
    sum_cell S6 (.p(P[6]),  .c(C6),  .s(Sum[6]));
    sum_cell S7 (.p(P[7]),  .c(C7),  .s(Sum[7]));

    sum_cell S8 (.p(P[8]),  .c(C8),  .s(Sum[8]));
    sum_cell S9 (.p(P[9]),  .c(C9),  .s(Sum[9]));
    sum_cell S10(.p(P[10]), .c(C10), .s(Sum[10]));
    sum_cell S11(.p(P[11]), .c(C11), .s(Sum[11]));

    sum_cell S12(.p(P[12]), .c(C12), .s(Sum[12]));
    sum_cell S13(.p(P[13]), .c(C13), .s(Sum[13]));
    sum_cell S14(.p(P[14]), .c(C14), .s(Sum[14]));
    sum_cell S15(.p(P[15]), .c(C15), .s(Sum[15]));

    assign Cout      = C16;
    assign Overflow  = C15 ^ C16;
    assign Zero      = ~|Sum;
    assign Negative  = Sum[15];

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

//============================================================
// MODULE : cla_top_16bit_dataflow
// STYLE  : Dataflow (assign only)
// ARCH   : Hierarchical Carry Lookahead Adder
//
// Power : Medium-Low
// Area  : Medium
// Delay : O(log N)
//============================================================
module cla_top_16bit_dataflow
(
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,

    output wire [15:0] Sum,
    output wire        Cout,
    output wire        Overflow,
    output wire        Zero,
    output wire        Negative
);

    //--------------------------------------------------------
    // STEP 1 : Bit Propagate / Generate
    //--------------------------------------------------------

    wire [15:0] P;
    wire [15:0] G;

    assign P = A ^ B;
    assign G = A & B;

    //--------------------------------------------------------
    // STEP 2 : Group Propagate / Generate
    //--------------------------------------------------------

    wire [3:0] PG;
    wire [3:0] GG;

    // Group 0 : bits [3:0]

    assign PG[0] =
           P[3] &
           P[2] &
           P[1] &
           P[0];

    assign GG[0] =
           G[3]
         | (P[3] & G[2])
         | (P[3] & P[2] & G[1])
         | (P[3] & P[2] & P[1] & G[0]);

    // Group 1 : bits [7:4]

    assign PG[1] =
           P[7] &
           P[6] &
           P[5] &
           P[4];

    assign GG[1] =
           G[7]
         | (P[7] & G[6])
         | (P[7] & P[6] & G[5])
         | (P[7] & P[6] & P[5] & G[4]);

    // Group 2 : bits [11:8]

    assign PG[2] =
           P[11] &
           P[10] &
           P[9] &
           P[8];

    assign GG[2] =
           G[11]
         | (P[11] & G[10])
         | (P[11] & P[10] & G[9])
         | (P[11] & P[10] & P[9] & G[8]);

    // Group 3 : bits [15:12]

    assign PG[3] =
           P[15] &
           P[14] &
           P[13] &
           P[12];

    assign GG[3] =
           G[15]
         | (P[15] & G[14])
         | (P[15] & P[14] & G[13])
         | (P[15] & P[14] & P[13] & G[12]);

    //--------------------------------------------------------
    // STEP 3 : Inter-Group Carry Lookahead
    //--------------------------------------------------------

    wire C4;
    wire C8;
    wire C12;
    wire C16;

    assign C4 =
           GG[0]
         | (PG[0] & Cin);

    assign C8 =
           GG[1]
         | (PG[1] & GG[0])
         | (PG[1] & PG[0] & Cin);

    assign C12 =
           GG[2]
         | (PG[2] & GG[1])
         | (PG[2] & PG[1] & GG[0])
         | (PG[2] & PG[1] & PG[0] & Cin);

    assign C16 =
           GG[3]
         | (PG[3] & GG[2])
         | (PG[3] & PG[2] & GG[1])
         | (PG[3] & PG[2] & PG[1] & GG[0])
         | (PG[3] & PG[2] & PG[1] & PG[0] & Cin);

    //--------------------------------------------------------
    // STEP 4 : Bit-Level Carry Lookahead
    //--------------------------------------------------------

    wire [16:0] C;

    assign C[0] = Cin;

    //---------------- Group 0 ----------------

    assign C[1] =
           G[0]
         | (P[0] & C[0]);

    assign C[2] =
           G[1]
         | (P[1] & G[0])
         | (P[1] & P[0] & C[0]);

    assign C[3] =
           G[2]
         | (P[2] & G[1])
         | (P[2] & P[1] & G[0])
         | (P[2] & P[1] & P[0] & C[0]);

    assign C[4] = C4;

    //---------------- Group 1 ----------------

    assign C[5] =
           G[4]
         | (P[4] & C4);

    assign C[6] =
           G[5]
         | (P[5] & G[4])
         | (P[5] & P[4] & C4);

    assign C[7] =
           G[6]
         | (P[6] & G[5])
         | (P[6] & P[5] & G[4])
         | (P[6] & P[5] & P[4] & C4);

    assign C[8] = C8;

    //---------------- Group 2 ----------------

    assign C[9] =
           G[8]
         | (P[8] & C8);

    assign C[10] =
           G[9]
         | (P[9] & G[8])
         | (P[9] & P[8] & C8);

    assign C[11] =
           G[10]
         | (P[10] & G[9])
         | (P[10] & P[9] & G[8])
         | (P[10] & P[9] & P[8] & C8);

    assign C[12] = C12;

    //---------------- Group 3 ----------------

    assign C[13] =
           G[12]
         | (P[12] & C12);

    assign C[14] =
           G[13]
         | (P[13] & G[12])
         | (P[13] & P[12] & C12);

    assign C[15] =
           G[14]
         | (P[14] & G[13])
         | (P[14] & P[13] & G[12])
         | (P[14] & P[13] & P[12] & C12);

    assign C[16] = C16;

    //--------------------------------------------------------
    // STEP 5 : Sum Generation
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
    // STEP 6 : Status Flags
    //--------------------------------------------------------

    assign Cout      = C[16];

    // Correct signed overflow
    assign Overflow  = C[15] ^ C[16];

    assign Zero      = ~|Sum;

    assign Negative  = Sum[15];

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

//============================================================
// MODULE : cla_top_16bit_behavioral
// STYLE  : Behavioral
// ARCH   : Hierarchical Carry Lookahead Adder
//
// Power : Medium
// Area  : Medium
// Delay : O(log N)
//============================================================
module cla_top_16bit_behavioral
#(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)
(
    input  wire [DATA_WIDTH-1:0] A,
    input  wire [DATA_WIDTH-1:0] B,
    input  wire                  Cin,

    output reg  [DATA_WIDTH-1:0] Sum,
    output reg                   Cout,
    output reg                   Overflow,
    output reg                   Zero,
    output reg                   Negative
);

    integer i;
    integer g;

    reg [DATA_WIDTH-1:0] P;
    reg [DATA_WIDTH-1:0] G;

    reg [(DATA_WIDTH/GROUP_SIZE)-1:0] PG;
    reg [(DATA_WIDTH/GROUP_SIZE)-1:0] GG;

    reg [DATA_WIDTH:0] C;
    reg [(DATA_WIDTH/GROUP_SIZE):0] GC;

    always @(*)
    begin

        //----------------------------------------------------
        // STEP 0 : Default assignments
        //----------------------------------------------------

        P         = {DATA_WIDTH{1'b0}};
        G         = {DATA_WIDTH{1'b0}};

        PG        = {(DATA_WIDTH/GROUP_SIZE){1'b0}};
        GG        = {(DATA_WIDTH/GROUP_SIZE){1'b0}};

        C         = {(DATA_WIDTH+1){1'b0}};
        GC        = {((DATA_WIDTH/GROUP_SIZE)+1){1'b0}};

        Sum       = {DATA_WIDTH{1'b0}};
        Cout      = 1'b0;
        Overflow  = 1'b0;
        Zero      = 1'b0;
        Negative  = 1'b0;

        //----------------------------------------------------
        // STEP 1 : Bit Propagate / Generate
        //----------------------------------------------------

        for(i=0; i<DATA_WIDTH; i=i+1)
        begin
            P[i] = A[i] ^ B[i];
            G[i] = A[i] & B[i];
        end

        //----------------------------------------------------
        // STEP 2 : Group Propagate / Generate
        //----------------------------------------------------
        // Group k:
        // PG = P3&P2&P1&P0
        // GG = G3 + P3G2 + P3P2G1 + P3P2P1G0
        //----------------------------------------------------

        for(g=0; g<(DATA_WIDTH/GROUP_SIZE); g=g+1)
        begin

            PG[g] =
                P[g*4+3] &
                P[g*4+2] &
                P[g*4+1] &
                P[g*4+0];

            GG[g] =
                G[g*4+3]
                |
                (P[g*4+3] & G[g*4+2])
                |
                (P[g*4+3] &
                 P[g*4+2] &
                 G[g*4+1])
                |
                (P[g*4+3] &
                 P[g*4+2] &
                 P[g*4+1] &
                 G[g*4+0]);
        end

        //----------------------------------------------------
        // STEP 3 : Inter-Group Carry Lookahead
        //----------------------------------------------------
        // IMPORTANT:
        // GC[0] = Cin
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
            | (PG[3] & PG[2] & PG[1] & PG[0] & GC[0]);

        //----------------------------------------------------
        // STEP 4 : Bit Carry Lookahead
        //----------------------------------------------------

        C[0]  = Cin;

        //---------------- Group 0 ----------------

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

        C[4] = GC[1];

        //---------------- Group 1 ----------------

        C[5] =
              G[4]
            | (P[4] & C[4]);

        C[6] =
              G[5]
            | (P[5] & G[4])
            | (P[5] & P[4] & C[4]);

        C[7] =
              G[6]
            | (P[6] & G[5])
            | (P[6] & P[5] & G[4])
            | (P[6] & P[5] & P[4] & C[4]);

        C[8] = GC[2];

        //---------------- Group 2 ----------------

        C[9] =
              G[8]
            | (P[8] & C[8]);

        C[10] =
              G[9]
            | (P[9] & G[8])
            | (P[9] & P[8] & C[8]);

        C[11] =
              G[10]
            | (P[10] & G[9])
            | (P[10] & P[9] & G[8])
            | (P[10] & P[9] & P[8] & C[8]);

        C[12] = GC[3];

        //---------------- Group 3 ----------------

        C[13] =
              G[12]
            | (P[12] & C[12]);

        C[14] =
              G[13]
            | (P[13] & G[12])
            | (P[13] & P[12] & C[12]);

        C[15] =
              G[14]
            | (P[14] & G[13])
            | (P[14] & P[13] & G[12])
            | (P[14] & P[13] & P[12] & C[12]);

        C[16] = GC[4];

        //----------------------------------------------------
        // STEP 5 : Sum Generation
        //----------------------------------------------------

        for(i=0; i<DATA_WIDTH; i=i+1)
        begin
            Sum[i] = P[i] ^ C[i];
        end

        //----------------------------------------------------
        // STEP 6 : Status Flags
        //----------------------------------------------------

        Cout = C[DATA_WIDTH];

        // Correct signed overflow:
        // Overflow = carry into MSB XOR carry out of MSB

        Overflow = C[DATA_WIDTH-1] ^ C[DATA_WIDTH];

        Zero = ~|Sum;

        Negative = Sum[DATA_WIDTH-1];

    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla16;

    //--------------------------------------------------------
    // Parameters
    //--------------------------------------------------------

    parameter DATA_WIDTH = 16;
    parameter GROUP_SIZE = 4;
    parameter RANDOM_TESTS = 50000;

    //--------------------------------------------------------
    // DUT Inputs
    //--------------------------------------------------------

    reg  [DATA_WIDTH-1:0] A;
    reg  [DATA_WIDTH-1:0] B;
    reg                   Cin;

    //--------------------------------------------------------
    // Structural Outputs
    //--------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_struct;
    wire                  Cout_struct;
    wire                  Overflow_struct;
    wire                  Zero_struct;
    wire                  Negative_struct;

    //--------------------------------------------------------
    // Dataflow Outputs
    //--------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_data;
    wire                  Cout_data;
    wire                  Overflow_data;
    wire                  Zero_data;
    wire                  Negative_data;

    //--------------------------------------------------------
    // Behavioral Outputs
    //--------------------------------------------------------

    wire [DATA_WIDTH-1:0] Sum_beh;
    wire                  Cout_beh;
    wire                  Overflow_beh;
    wire                  Zero_beh;
    wire                  Negative_beh;

    //--------------------------------------------------------
    // Reference Model Variables
    //--------------------------------------------------------

    reg [DATA_WIDTH:0] ref_full_sum;

    reg [DATA_WIDTH-1:0] ref_sum;
    reg                  ref_cout;
    reg                  ref_overflow;
    reg                  ref_zero;
    reg                  ref_negative;

    integer pass_count;
    integer fail_count;
    integer test_count;

    integer i;

    //--------------------------------------------------------
    // DUT #1 : Structural
    //--------------------------------------------------------

    cla_top_16bit_structural DUT_STRUCT
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

    //--------------------------------------------------------
    // DUT #2 : Dataflow
    //--------------------------------------------------------

    cla_top_16bit_dataflow DUT_DATAFLOW
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

    //--------------------------------------------------------
    // DUT #3 : Behavioral
    //--------------------------------------------------------

    cla_top_16bit_behavioral
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .GROUP_SIZE(GROUP_SIZE)
    )
    DUT_BEHAVIORAL
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

    //--------------------------------------------------------
    // Reference Calculation
    //--------------------------------------------------------

    task compute_reference;
    begin

        ref_full_sum = A + B + Cin;

        ref_sum  = ref_full_sum[15:0];
        ref_cout = ref_full_sum[16];

        ref_overflow =
            (~(A[15] ^ B[15]))
            &
            (A[15] ^ ref_sum[15]);

        ref_zero =
            (ref_sum == 16'h0000);

        ref_negative =
            ref_sum[15];

    end
    endtask

    //--------------------------------------------------------
    // Result Checker
    //--------------------------------------------------------

    task check_all;
    begin

        compute_reference;

        test_count = test_count + 1;

        //----------------------------------------------------
        // Structural Check
        //----------------------------------------------------

        if ((Sum_struct      !== ref_sum     ) ||
            (Cout_struct     !== ref_cout    ) ||
            (Overflow_struct !== ref_overflow) ||
            (Zero_struct     !== ref_zero    ) ||
            (Negative_struct !== ref_negative))
        begin

            fail_count = fail_count + 1;

            $display("ERROR STRUCTURAL");
            $display("A=%h B=%h Cin=%b",A,B,Cin);
            $display("Expected: Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     ref_sum,
                     ref_cout,
                     ref_overflow,
                     ref_zero,
                     ref_negative);

            $display("Got     : Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     Sum_struct,
                     Cout_struct,
                     Overflow_struct,
                     Zero_struct,
                     Negative_struct);

            $stop;
        end

        //----------------------------------------------------
        // Dataflow Check
        //----------------------------------------------------

        if ((Sum_data      !== ref_sum     ) ||
            (Cout_data     !== ref_cout    ) ||
            (Overflow_data !== ref_overflow) ||
            (Zero_data     !== ref_zero    ) ||
            (Negative_data !== ref_negative))
        begin

            fail_count = fail_count + 1;

            $display("ERROR DATAFLOW");
            $display("A=%h B=%h Cin=%b",A,B,Cin);

            $display("Expected: Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     ref_sum,
                     ref_cout,
                     ref_overflow,
                     ref_zero,
                     ref_negative);

            $display("Got     : Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     Sum_data,
                     Cout_data,
                     Overflow_data,
                     Zero_data,
                     Negative_data);

            $stop;
        end

        //----------------------------------------------------
        // Behavioral Check
        //----------------------------------------------------

        if ((Sum_beh      !== ref_sum     ) ||
            (Cout_beh     !== ref_cout    ) ||
            (Overflow_beh !== ref_overflow) ||
            (Zero_beh     !== ref_zero    ) ||
            (Negative_beh !== ref_negative))
        begin

            fail_count = fail_count + 1;

            $display("ERROR BEHAVIORAL");
            $display("A=%h B=%h Cin=%b",A,B,Cin);

            $display("Expected: Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     ref_sum,
                     ref_cout,
                     ref_overflow,
                     ref_zero,
                     ref_negative);

            $display("Got     : Sum=%h Cout=%b Ov=%b Z=%b N=%b",
                     Sum_beh,
                     Cout_beh,
                     Overflow_beh,
                     Zero_beh,
                     Negative_beh);

            $stop;
        end

        //----------------------------------------------------
        // Cross Compare DUTs
        //----------------------------------------------------

        if ((Sum_struct  !== Sum_data ) ||
            (Sum_struct  !== Sum_beh  ) ||
            (Cout_struct !== Cout_data) ||
            (Cout_struct !== Cout_beh ))
        begin

            fail_count = fail_count + 1;

            $display("DUT MISMATCH");
            $stop;
        end

        pass_count = pass_count + 1;

    end
    endtask

    //--------------------------------------------------------
    // Directed Tests
    //--------------------------------------------------------

    task run_directed_tests;
    begin

        $display("------------------------------------");
        $display("RUNNING DIRECTED TESTS");
        $display("------------------------------------");

        A=16'h0000; B=16'h0000; Cin=0; #1; check_all();

        A=16'h0000; B=16'h0000; Cin=1; #1; check_all();

        A=16'h0001; B=16'h0001; Cin=0; #1; check_all();

        A=16'hFFFF; B=16'h0001; Cin=0; #1; check_all();

        A=16'hFFFF; B=16'hFFFF; Cin=0; #1; check_all();

        A=16'hFFFF; B=16'hFFFF; Cin=1; #1; check_all();

        A=16'hAAAA; B=16'h5555; Cin=0; #1; check_all();

        A=16'h5555; B=16'hAAAA; Cin=1; #1; check_all();

        A=16'h7FFF; B=16'h0001; Cin=0; #1; check_all();

        A=16'h8000; B=16'h8000; Cin=0; #1; check_all();

        A=16'h7FFF; B=16'h7FFF; Cin=0; #1; check_all();

        A=16'h8000; B=16'h7FFF; Cin=0; #1; check_all();

        A=16'h1234; B=16'h4321; Cin=0; #1; check_all();

        A=16'h1111; B=16'hEEEE; Cin=1; #1; check_all();

        A=16'hF0F0; B=16'h0F0F; Cin=0; #1; check_all();

        A=16'h8001; B=16'h8001; Cin=1; #1; check_all();

    end
    endtask

    //--------------------------------------------------------
    // Random Tests
    //--------------------------------------------------------

    task run_random_tests;
    begin

        $display("------------------------------------");
        $display("RUNNING RANDOM TESTS");
        $display("------------------------------------");

        for(i=0; i<RANDOM_TESTS; i=i+1)
        begin

            A   = $random;
            B   = $random;
            Cin = $random & 1'b1;

            #1;

            check_all();

        end

    end
    endtask

    //--------------------------------------------------------
    // Main Test Sequence
    //--------------------------------------------------------

    initial
    begin

        pass_count = 0;
        fail_count = 0;
        test_count = 0;

        //----------------------------------------------------
        // VCD Dump
        //----------------------------------------------------

        $dumpfile("cla16.vcd");
        $dumpvars(0,tb_cla16);

        //----------------------------------------------------
        // Banner
        //----------------------------------------------------

        $display("");
        $display("====================================");
        $display("16-BIT CARRY LOOKAHEAD ADDER TEST");
        $display("STRUCTURAL + DATAFLOW + BEHAVIORAL");
        $display("====================================");
        $display("");

        //----------------------------------------------------
        // Execute Tests
        //----------------------------------------------------

        run_directed_tests();

        run_random_tests();

        //----------------------------------------------------
        // Summary
        //----------------------------------------------------

        $display("");
        $display("====================================");
        $display("TEST SUMMARY");
        $display("====================================");
        $display("Total Tests : %0d", test_count);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);
        $display("====================================");

        if(fail_count == 0)
        begin
            $display("STATUS : PASS");
        end
        else
        begin
            $display("STATUS : FAIL");
        end

        $finish;

    end

endmodule
