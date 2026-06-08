// =============================================================================
// PROMPT STRATEGY: INSTRUCTION FORMAT
// =============================================================================
// INSTRUCTION: Write a complete 16-bit Carry Lookahead Adder in Verilog.
// FORMAT: Deliver output in exactly the structure below. Fill every section completely.
// Do not deviate from section headers, file names, or formatting rules.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FILE: cla_structural.v
// STYLE: Structural (module instantiations only)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FORMAT PER SUB-MODULE:
//   //--------------------------------------------
//   // Module  : <name>
//   // Purpose : <one line>
//   // Inputs  : <list>
//   // Outputs : <list>
//   // Delay   : <N gate levels>
//   // Area    : ~<M> NAND2 equivalents
//   //--------------------------------------------
//   module <name> #(<params>) (<ports>);
//     <body — gates or instantiations only, no always>
//   endmodule
//
// REQUIRED MODULES (all must appear):
//   1. pg_cell        — 1-bit P=A^B, G=A&B
//   2. cla_carry4     — 4-bit lookahead carry (C1..C4 from P[3:0],G[3:0],C0)
//   3. sum_cell       — 1-bit Sum = P ^ carry_in
//   4. group_pg       — group P_G = &P[3:0], group G_G = lookahead expansion
//   5. inter_carry    — C_group[1..4] from four group PG pairs and Cin
//   6. cla_adder_16bit — top module; named port maps; PPA header
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FILE: cla_dataflow.v
// STYLE: Dataflow (assign statements only)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FORMAT:
//   module cla_adder_16bit #(...) (...);
//     // === WIRES ===
//     <all wire declarations>
//
//     // === SECTION 1: Bit-level P and G ===
//     <32 assign statements for P[0..15], G[0..15]>
//
//     // === SECTION 2: Within-group carries ===
//     // Group 0 (bits 3:0)
//     <4 assigns for C1,C2,C3,C4>
//     // Group 1 (bits 7:4)
//     <4 assigns for C5,C6,C7,C8>
//     // Group 2 (bits 11:8)
//     <4 assigns for C9,C10,C11,C12>
//     // Group 3 (bits 15:12)
//     <4 assigns for C13,C14,C15,C16>
//
//     // === SECTION 3: Group-level PG ===
//     <8 assigns for P_G0..P_G3, G_G0..G_G3>
//
//     // === SECTION 4: Inter-group carries ===
//     <4 assigns for CG1,CG2,CG3,CG4>
//
//     // === SECTION 5: Sum ===
//     <16 assigns for Sum[0..15]>
//
//     // === SECTION 6: Flags ===
//     <4 assigns for Cout, Overflow, Zero, Negative>
//   endmodule
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FILE: cla_behavioral.v
// STYLE: Behavioral (always @(*) with for-loops)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FORMAT:
//   module cla_adder_16bit #(
//     parameter DATA_WIDTH = 16,
//     parameter GROUP_SIZE = 4
//   ) ( <ports> );
//     localparam NUM_GROUPS = DATA_WIDTH / GROUP_SIZE;
//     reg [DATA_WIDTH-1:0] P , G;
//     reg [DATA_WIDTH:0]   C;
//     reg [NUM_GROUPS-1:0] PG_g, GG_g;
//     reg [NUM_GROUPS:0]   GC;
//     integer i, k;
//
//     always @(*) begin
//       // STEP 1 — Bit-level P , G
//       <for loop i=0..DATA_WIDTH-1>
//
//       // STEP 2 — Group-level PG and GG
//       <for loop k=0..NUM_GROUPS-1, inner i=0..GROUP_SIZE-1>
//
//       // STEP 3 — Group carry lookahead (CLA core)
//       GC[0] = Cin;
//       <for loop k=0..NUM_GROUPS-1: GC[k+1] = GG_g[k]|(PG_g[k]&GC[k])>
//
//       // STEP 4 — Bit-level carry fill from group carries
//       <nested loop: outer k, inner i, using lookahead equations>
//
//       // STEP 5 — Sum and flags
//       <sum loop + Cout, Overflow, Zero, Negative>
//     end
//   endmodule
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FILE: tb_cla_adder_16bit.v
// STYLE: Testbench (Verilog-2001, self-checking)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// FORMAT:
//   module tb_cla_adder_16bit;
//     // --- DUT connections ---
//     reg  [15:0] A, B; reg Cin;
//     wire [15:0] Sum_s, Sum_d, Sum_b;
//     wire Cout_s, Cout_d, Cout_b;
//     wire Ov_s, Ov_d, Ov_b, Z_s, Z_d, Z_b, Neg_s, Neg_d, Neg_b;
//
//     // --- Instantiate three DUTs ---
//     cla_adder_16bit dut_struct (...);
//     cla_adder_16bit dut_data  (...);
//     cla_adder_16bit dut_beh   (...);
//
//     // --- Reference integers ---
//     reg [16:0] exp; integer pass_d, fail_d, pass_r, fail_r;
//
//     initial begin
//       $dumpfile("cla_tb.vcd"); $dumpvars(0, tb_cla_adder_16bit);
//       // DIRECTED TESTS
//       <all-zeros, all-ones, rollover, signed OV, checkerboard,
//        single-bit sweeps A and B, Cin=0 and Cin=1>
//
//       // RANDOM TESTS (50 000 vectors)
//       <for loop 50000 iterations: $random A,B,Cin; check all three DUTs>
//
//       // SUMMARY
//       $display("Directed : %0d / %0d", pass_d, pass_d+fail_d);
//       $display("Random   : %0d / 50000", pass_r);
//       $display("Verdict  : %s", (fail_d+fail_r==0) ? "ALL PASS" : "FAILURES");
//       $finish;
//     end
//   endmodule
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ━━━━━━━
// Fill every <placeholder> with complete working Verilog.
// No "..." allowed. Language: Verilog-2001 throughout.
// End with PPA table: Style | Gate depth | ~NAND2 | Power vs RCA
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

//--------------------------------------------
// Module  : pg_cell
// Purpose : Generate bit propagate and generate
// Inputs  : A, B
// Outputs : P , G
// Delay   : 1 gate level
// Area    : ~3 NAND2 equivalents
//--------------------------------------------
module pg_cell (
    input  A,
    input  B,
    output P ,
    output G
);

    xor (P , A, B);
    and (G, A, B);

endmodule


//--------------------------------------------
// Module  : cla_carry4
// Purpose : 4-bit carry lookahead generator
// Inputs  : P[3:0], G[3:0], C0
// Outputs : C1,C2,C3,C4
// Delay   : 3 gate levels
// Area    : ~45 NAND2 equivalents
//--------------------------------------------
module cla_carry4 (
    input  [3:0] P ,
    input  [3:0] G,
    input        C0,
    output       C1,
    output       C2,
    output       C3,
    output       C4
);

    wire p0c0;
    wire p1g0,p1p0c0;
    wire p2g1,p2p1g0,p2p1p0c0;
    wire p3g2,p3p2g1,p3p2p1g0,p3p2p1p0c0;

    and (p0c0, P[0], C0);
    or  (C1, G[0], p0c0);

    and (p1g0,   P[1], G[0]);
    and (p1p0c0, P[1], P[0], C0);
    or  (C2, G[1], p1g0, p1p0c0);

    and (p2g1,     P[2], G[1]);
    and (p2p1g0,   P[2], P[1], G[0]);
    and (p2p1p0c0, P[2], P[1], P[0], C0);
    or  (C3, G[2], p2g1, p2p1g0, p2p1p0c0);

    and (p3g2,       P[3], G[2]);
    and (p3p2g1,     P[3], P[2], G[1]);
    and (p3p2p1g0,   P[3], P[2], P[1], G[0]);
    and (p3p2p1p0c0, P[3], P[2], P[1], P[0], C0);

    or  (C4,
          G[3],
          p3g2,
          p3p2g1,
          p3p2p1g0,
          p3p2p1p0c0);

endmodule


//--------------------------------------------
// Module  : sum_cell
// Purpose : Generate sum bit
// Inputs  : P , Cin
// Outputs : Sum
// Delay   : 1 gate level
// Area    : ~2 NAND2 equivalents
//--------------------------------------------
module sum_cell (
    input  P ,
    input  Cin,
    output Sum
);

    xor (Sum, P , Cin);

endmodule


//--------------------------------------------
// Module  : group_pg
// Purpose : Generate group propagate and group generate
// Inputs  : P[3:0], G[3:0]
// Outputs : PG, GG
// Delay   : 3 gate levels
// Area    : ~20 NAND2 equivalents
//--------------------------------------------
module group_pg (
    input  [3:0] P ,
    input  [3:0] G,
    output       PG,
    output       GG
);

    wire t1,t2,t3,t4;

    and (PG, P[3], P[2], P[1], P[0]);

    and (t1, P[3], G[2]);
    and (t2, P[3], P[2], G[1]);
    and (t3, P[3], P[2], P[1], G[0]);

    or  (GG,
          G[3],
          t1,
          t2,
          t3);

endmodule


//--------------------------------------------
// Module  : inter_carry
// Purpose : Group-level carry lookahead
// Inputs  : PG[3:0], GG[3:0], Cin
// Outputs : CG1,CG2,CG3,CG4
// Delay   : 3 gate levels
// Area    : ~40 NAND2 equivalents
//--------------------------------------------
module inter_carry (
    input  [3:0] PG,
    input  [3:0] GG,
    input        Cin,
    output       CG1,
    output       CG2,
    output       CG3,
    output       CG4
);

    wire pg0cin;

    wire pg1gg0;
    wire pg1pg0cin;

    wire pg2gg1;
    wire pg2pg1gg0;
    wire pg2pg1pg0cin;

    wire pg3gg2;
    wire pg3pg2gg1;
    wire pg3pg2pg1gg0;
    wire pg3pg2pg1pg0cin;

    and (pg0cin, PG[0], Cin);
    or  (CG1, GG[0], pg0cin);

    and (pg1gg0,    PG[1], GG[0]);
    and (pg1pg0cin, PG[1], PG[0], Cin);
    or  (CG2, GG[1], pg1gg0, pg1pg0cin);

    and (pg2gg1,      PG[2], GG[1]);
    and (pg2pg1gg0,   PG[2], PG[1], GG[0]);
    and (pg2pg1pg0cin,PG[2], PG[1], PG[0], Cin);
    or  (CG3,
          GG[2],
          pg2gg1,
          pg2pg1gg0,
          pg2pg1pg0cin);

    and (pg3gg2,        PG[3], GG[2]);
    and (pg3pg2gg1,     PG[3], PG[2], GG[1]);
    and (pg3pg2pg1gg0,  PG[3], PG[2], PG[1], GG[0]);
    and (pg3pg2pg1pg0cin,
          PG[3], PG[2], PG[1], PG[0], Cin);

    or  (CG4,
          GG[3],
          pg3gg2,
          pg3pg2gg1,
          pg3pg2pg1gg0,
          pg3pg2pg1pg0cin);

endmodule


//--------------------------------------------
// Module  : cla_adder_16bit
// Purpose : 16-bit Carry Lookahead Adder
// Inputs  : A[15:0], B[15:0], Cin
// Outputs : Sum[15:0], Cout, Overflow,
//            Zero, Negative
// Delay   : ~5 gate levels
// Area    : ~220 NAND2 equivalents
//--------------------------------------------
module cla_adder_16bit (
    input  [15:0] A,
    input  [15:0] B,
    input         Cin,
    output [15:0] Sum,
    output        Cout,
    output        Overflow,
    output        Zero,
    output        Negative
);

    //=================================================
    // Bit Propagate / Generate
    //=================================================
    wire [15:0] P;
    wire [15:0] G;

    genvar i;

    generate
        for(i=0;i<16;i=i+1)
        begin : PG_GEN
            pg_cell u_pg (
                .A (A[i]),
                .B (B[i]),
                .P (P[i]),
                .G (G[i])
            );
        end
    endgenerate

    //=================================================
    // Group PG/GG
    //=================================================
    wire [3:0] PG_g;
    wire [3:0] GG_g;

    group_pg u_gpg0 (
        .P  (P[3:0]),
        .G  (G[3:0]),
        .PG (PG_g[0]),
        .GG (GG_g[0])
    );

    group_pg u_gpg1 (
        .P  (P[7:4]),
        .G  (G[7:4]),
        .PG (PG_g[1]),
        .GG (GG_g[1])
    );

    group_pg u_gpg2 (
        .P  (P[11:8]),
        .G  (G[11:8]),
        .PG (PG_g[2]),
        .GG (GG_g[2])
    );

    group_pg u_gpg3 (
        .P  (P[15:12]),
        .G  (G[15:12]),
        .PG (PG_g[3]),
        .GG (GG_g[3])
    );

    //=================================================
    // Inter-group carries
    //=================================================
    wire CG1,CG2,CG3,CG4;

    inter_carry u_inter (
        .PG  (PG_g),
        .GG  (GG_g),
        .Cin (Cin),
        .CG1 (CG1),
        .CG2 (CG2),
        .CG3 (CG3),
        .CG4 (CG4)
    );

    //=================================================
    // Intra-group carries
    //=================================================
    wire C1,C2,C3,C4;
    wire C5,C6,C7,C8;
    wire C9,C10,C11,C12;
    wire C13,C14,C15,C16;

    cla_carry4 u_cla0 (
        .P  (P[3:0]),
        .G  (G[3:0]),
        .C0 (Cin),
        .C1 (C1),
        .C2 (C2),
        .C3 (C3),
        .C4 (C4)
    );

    cla_carry4 u_cla1 (
        .P  (P[7:4]),
        .G  (G[7:4]),
        .C0 (CG1),
        .C1 (C5),
        .C2 (C6),
        .C3 (C7),
        .C4 (C8)
    );

    cla_carry4 u_cla2 (
        .P  (P[11:8]),
        .G  (G[11:8]),
        .C0 (CG2),
        .C1 (C9),
        .C2 (C10),
        .C3 (C11),
        .C4 (C12)
    );

    cla_carry4 u_cla3 (
        .P  (P[15:12]),
        .G  (G[15:12]),
        .C0 (CG3),
        .C1 (C13),
        .C2 (C14),
        .C3 (C15),
        .C4 (C16)
    );

    //=================================================
    // Sum generation
    //=================================================
    sum_cell s0  (.P(P[0]),  .Cin(Cin), .Sum(Sum[0]));
    sum_cell s1  (.P(P[1]),  .Cin(C1),  .Sum(Sum[1]));
    sum_cell s2  (.P(P[2]),  .Cin(C2),  .Sum(Sum[2]));
    sum_cell s3  (.P(P[3]),  .Cin(C3),  .Sum(Sum[3]));

    sum_cell s4  (.P(P[4]),  .Cin(CG1), .Sum(Sum[4]));
    sum_cell s5  (.P(P[5]),  .Cin(C5),  .Sum(Sum[5]));
    sum_cell s6  (.P(P[6]),  .Cin(C6),  .Sum(Sum[6]));
    sum_cell s7  (.P(P[7]),  .Cin(C7),  .Sum(Sum[7]));

    sum_cell s8  (.P(P[8]),  .Cin(CG2), .Sum(Sum[8]));
    sum_cell s9  (.P(P[9]),  .Cin(C9),  .Sum(Sum[9]));
    sum_cell s10 (.P(P[10]), .Cin(C10), .Sum(Sum[10]));
    sum_cell s11 (.P(P[11]), .Cin(C11), .Sum(Sum[11]));

    sum_cell s12 (.P(P[12]), .Cin(CG3), .Sum(Sum[12]));
    sum_cell s13 (.P(P[13]), .Cin(C13), .Sum(Sum[13]));
    sum_cell s14 (.P(P[14]), .Cin(C14), .Sum(Sum[14]));
    sum_cell s15 (.P(P[15]), .Cin(C15), .Sum(Sum[15]));

    //=================================================
    // Flags
    //=================================================
    assign Cout     = C16;
    assign Overflow = C15 ^ C16;
    assign Negative = Sum[15];
    assign Zero     = ~(|Sum);

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

module cla_adder_16bit #(
    parameter DATA_WIDTH = 16
)(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input                   Cin,
    output [DATA_WIDTH-1:0] Sum,
    output                  Cout,
    output                  Overflow,
    output                  Zero,
    output                  Negative
);

    // === WIRES ===
    wire [15:0] P;
    wire [15:0] G;

    wire C1,C2,C3,C4;
    wire C5,C6,C7,C8;
    wire C9,C10,C11,C12;
    wire C13,C14,C15,C16;

    wire P_G0,P_G1,P_G2,P_G3;
    wire G_G0,G_G1,G_G2,G_G3;

    wire CG1,CG2,CG3,CG4;

    // === SECTION 1: Bit-level P and G ===

    assign P[0]  = A[0]  ^ B[0];
    assign G[0]  = A[0]  & B[0];

    assign P[1]  = A[1]  ^ B[1];
    assign G[1]  = A[1]  & B[1];

    assign P[2]  = A[2]  ^ B[2];
    assign G[2]  = A[2]  & B[2];

    assign P[3]  = A[3]  ^ B[3];
    assign G[3]  = A[3]  & B[3];

    assign P[4]  = A[4]  ^ B[4];
    assign G[4]  = A[4]  & B[4];

    assign P[5]  = A[5]  ^ B[5];
    assign G[5]  = A[5]  & B[5];

    assign P[6]  = A[6]  ^ B[6];
    assign G[6]  = A[6]  & B[6];

    assign P[7]  = A[7]  ^ B[7];
    assign G[7]  = A[7]  & B[7];

    assign P[8]  = A[8]  ^ B[8];
    assign G[8]  = A[8]  & B[8];

    assign P[9]  = A[9]  ^ B[9];
    assign G[9]  = A[9]  & B[9];

    assign P[10] = A[10] ^ B[10];
    assign G[10] = A[10] & B[10];

    assign P[11] = A[11] ^ B[11];
    assign G[11] = A[11] & B[11];

    assign P[12] = A[12] ^ B[12];
    assign G[12] = A[12] & B[12];

    assign P[13] = A[13] ^ B[13];
    assign G[13] = A[13] & B[13];

    assign P[14] = A[14] ^ B[14];
    assign G[14] = A[14] & B[14];

    assign P[15] = A[15] ^ B[15];
    assign G[15] = A[15] & B[15];

    // === SECTION 2: Within-group carries ===

    // Group 0 (bits 3:0)

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

    // Group 1 (bits 7:4)

    assign C5 = G[4] |
               (P[4] & CG1);

    assign C6 = G[5] |
               (P[5] & G[4]) |
               (P[5] & P[4] & CG1);

    assign C7 = G[6] |
               (P[6] & G[5]) |
               (P[6] & P[5] & G[4]) |
               (P[6] & P[5] & P[4] & CG1);

    assign C8 = G[7] |
               (P[7] & G[6]) |
               (P[7] & P[6] & G[5]) |
               (P[7] & P[6] & P[5] & G[4]) |
               (P[7] & P[6] & P[5] & P[4] & CG1);

    // Group 2 (bits 11:8)

    assign C9 = G[8] |
               (P[8] & CG2);

    assign C10 = G[9] |
                (P[9] & G[8]) |
                (P[9] & P[8] & CG2);

    assign C11 = G[10] |
                (P[10] & G[9]) |
                (P[10] & P[9] & G[8]) |
                (P[10] & P[9] & P[8] & CG2);

    assign C12 = G[11] |
                (P[11] & G[10]) |
                (P[11] & P[10] & G[9]) |
                (P[11] & P[10] & P[9] & G[8]) |
                (P[11] & P[10] & P[9] & P[8] & CG2);

    // Group 3 (bits 15:12)

    assign C13 = G[12] |
                (P[12] & CG3);

    assign C14 = G[13] |
                (P[13] & G[12]) |
                (P[13] & P[12] & CG3);

    assign C15 = G[14] |
                (P[14] & G[13]) |
                (P[14] & P[13] & G[12]) |
                (P[14] & P[13] & P[12] & CG3);

    assign C16 = G[15] |
                (P[15] & G[14]) |
                (P[15] & P[14] & G[13]) |
                (P[15] & P[14] & P[13] & G[12]) |
                (P[15] & P[14] & P[13] & P[12] & CG3);

    // === SECTION 3: Group-level PG ===

    assign P_G0 = P[3]  & P[2]  & P[1]  & P[0];
    assign G_G0 = G[3]  |
                 (P[3] & G[2]) |
                 (P[3] & P[2] & G[1]) |
                 (P[3] & P[2] & P[1] & G[0]);

    assign P_G1 = P[7]  & P[6]  & P[5]  & P[4];
    assign G_G1 = G[7]  |
                 (P[7] & G[6]) |
                 (P[7] & P[6] & G[5]) |
                 (P[7] & P[6] & P[5] & G[4]);

    assign P_G2 = P[11] & P[10] & P[9]  & P[8];
    assign G_G2 = G[11] |
                 (P[11] & G[10]) |
                 (P[11] & P[10] & G[9]) |
                 (P[11] & P[10] & P[9] & G[8]);

    assign P_G3 = P[15] & P[14] & P[13] & P[12];
    assign G_G3 = G[15] |
                 (P[15] & G[14]) |
                 (P[15] & P[14] & G[13]) |
                 (P[15] & P[14] & P[13] & G[12]);

    // === SECTION 4: Inter-group carries ===

    assign CG1 = G_G0 |
                (P_G0 & Cin);

    assign CG2 = G_G1 |
                (P_G1 & G_G0) |
                (P_G1 & P_G0 & Cin);

    assign CG3 = G_G2 |
                (P_G2 & G_G1) |
                (P_G2 & P_G1 & G_G0) |
                (P_G2 & P_G1 & P_G0 & Cin);

    assign CG4 = G_G3 |
                (P_G3 & G_G2) |
                (P_G3 & P_G2 & G_G1) |
                (P_G3 & P_G2 & P_G1 & G_G0) |
                (P_G3 & P_G2 & P_G1 & P_G0 & Cin);

    // === SECTION 5: Sum ===

    assign Sum[0]  = P[0]  ^ Cin;
    assign Sum[1]  = P[1]  ^ C1;
    assign Sum[2]  = P[2]  ^ C2;
    assign Sum[3]  = P[3]  ^ C3;

    assign Sum[4]  = P[4]  ^ CG1;
    assign Sum[5]  = P[5]  ^ C5;
    assign Sum[6]  = P[6]  ^ C6;
    assign Sum[7]  = P[7]  ^ C7;

    assign Sum[8]  = P[8]  ^ CG2;
    assign Sum[9]  = P[9]  ^ C9;
    assign Sum[10] = P[10] ^ C10;
    assign Sum[11] = P[11] ^ C11;

    assign Sum[12] = P[12] ^ CG3;
    assign Sum[13] = P[13] ^ C13;
    assign Sum[14] = P[14] ^ C14;
    assign Sum[15] = P[15] ^ C15;

    // === SECTION 6: Flags ===

    assign Cout     = C16;
    assign Overflow = C15 ^ C16;
    assign Zero     = (Sum == 16'h0000);
    assign Negative = Sum[15];

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

module cla_adder_16bit #(
    parameter DATA_WIDTH = 16,
    parameter GROUP_SIZE = 4
)(
    input  [DATA_WIDTH-1:0] A,
    input  [DATA_WIDTH-1:0] B,
    input                   Cin,

    output reg [DATA_WIDTH-1:0] Sum,
    output reg                  Cout,
    output reg                  Overflow,
    output reg                  Zero,
    output reg                  Negative
);

    localparam NUM_GROUPS = DATA_WIDTH / GROUP_SIZE;

    reg [DATA_WIDTH-1:0] P , G;
    reg [DATA_WIDTH:0]   C;

    reg [NUM_GROUPS-1:0] PG_g;
    reg [NUM_GROUPS-1:0] GG_g;

    reg [NUM_GROUPS:0]   GC;

    integer i, k;

    always @(*) begin

        //--------------------------------------------------
        // Default assignments
        //--------------------------------------------------
        P         = {DATA_WIDTH{1'b0}};
        G         = {DATA_WIDTH{1'b0}};
        C         = {(DATA_WIDTH+1){1'b0}};
        Sum       = {DATA_WIDTH{1'b0}};

        PG_g      = {NUM_GROUPS{1'b0}};
        GG_g      = {NUM_GROUPS{1'b0}};
        GC        = {(NUM_GROUPS+1){1'b0}};

        Cout      = 1'b0;
        Overflow  = 1'b0;
        Zero      = 1'b0;
        Negative  = 1'b0;

        //--------------------------------------------------
        // STEP 1 — Bit-level P , G
        //--------------------------------------------------
        for(i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            P[i] = A[i] ^ B[i];
            G[i] = A[i] & B[i];
        end

        //--------------------------------------------------
        // STEP 2 — Group-level PG and GG
        //--------------------------------------------------
        for(k = 0; k < NUM_GROUPS; k = k + 1)
        begin

            PG_g[k] = 1'b1;

            for(i = 0; i < GROUP_SIZE; i = i + 1)
            begin
                PG_g[k] = PG_g[k] &
                          P[k*GROUP_SIZE + i];
            end

            GG_g[k] =
                G[k*GROUP_SIZE + (GROUP_SIZE-1)] |

               (P[k*GROUP_SIZE + (GROUP_SIZE-1)] &
                G[k*GROUP_SIZE + (GROUP_SIZE-2)]) |

               (P[k*GROUP_SIZE + (GROUP_SIZE-1)] &
                P[k*GROUP_SIZE + (GROUP_SIZE-2)] &
                G[k*GROUP_SIZE + (GROUP_SIZE-3)]) |

               (P[k*GROUP_SIZE + (GROUP_SIZE-1)] &
                P[k*GROUP_SIZE + (GROUP_SIZE-2)] &
                P[k*GROUP_SIZE + (GROUP_SIZE-3)] &
                G[k*GROUP_SIZE + (GROUP_SIZE-4)]);
        end

        //--------------------------------------------------
        // STEP 3 — Group carry lookahead (CLA core)
        //--------------------------------------------------
        GC[0] = Cin;

        for(k = 0; k < NUM_GROUPS; k = k + 1)
        begin
            GC[k+1] = GG_g[k] |
                      (PG_g[k] & GC[k]);
        end

        //--------------------------------------------------
        // STEP 4 — Bit-level carry fill from group carries
        //--------------------------------------------------
        for(k = 0; k < NUM_GROUPS; k = k + 1)
        begin

            C[k*GROUP_SIZE] = GC[k];

            for(i = 0; i < GROUP_SIZE; i = i + 1)
            begin
                C[k*GROUP_SIZE + i + 1] =
                    G[k*GROUP_SIZE + i] |
                   (P[k*GROUP_SIZE + i] &
                    C[k*GROUP_SIZE + i]);
            end

        end

        //--------------------------------------------------
        // STEP 5 — Sum and flags
        //--------------------------------------------------
        for(i = 0; i < DATA_WIDTH; i = i + 1)
        begin
            Sum[i] = P[i] ^ C[i];
        end

        Cout     = C[DATA_WIDTH];

        Overflow = C[DATA_WIDTH] ^
                   C[DATA_WIDTH-1];

        Zero     = (Sum == {DATA_WIDTH{1'b0}});

        Negative = Sum[DATA_WIDTH-1];

    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla_adder_16bit;

    // --------------------------------------------------
    // DUT connections
    // --------------------------------------------------
    reg  [15:0] A;
    reg  [15:0] B;
    reg         Cin;

    wire [15:0] Sum_s;
    wire [15:0] Sum_d;
    wire [15:0] Sum_b;

    wire Cout_s;
    wire Cout_d;
    wire Cout_b;

    wire Ov_s;
    wire Ov_d;
    wire Ov_b;

    wire Z_s;
    wire Z_d;
    wire Z_b;

    wire Neg_s;
    wire Neg_d;
    wire Neg_b;

    // --------------------------------------------------
    // Instantiate three DUTs
    // --------------------------------------------------

    // Structural
    cla_adder_16bit dut_struct (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (Sum_s),
        .Cout      (Cout_s),
        .Overflow  (Ov_s),
        .Zero      (Z_s),
        .Negative  (Neg_s)
    );

    // Dataflow
    cla_adder_16bit dut_data (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (Sum_d),
        .Cout      (Cout_d),
        .Overflow  (Ov_d),
        .Zero      (Z_d),
        .Negative  (Neg_d)
    );

    // Behavioral
    cla_adder_16bit dut_beh (
        .A         (A),
        .B         (B),
        .Cin       (Cin),
        .Sum       (Sum_b),
        .Cout      (Cout_b),
        .Overflow  (Ov_b),
        .Zero      (Z_b),
        .Negative  (Neg_b)
    );

    // --------------------------------------------------
    // Reference variables
    // --------------------------------------------------
    reg [16:0] exp;

    integer pass_d;
    integer fail_d;

    integer pass_r;
    integer fail_r;

    integer i;

    // --------------------------------------------------
    // Overflow reference function
    // --------------------------------------------------
    function calc_overflow;
        input [15:0] a;
        input [15:0] b;
        input [15:0] s;
        begin
            calc_overflow =
                (~(a[15] ^ b[15])) &
                 (a[15] ^ s[15]);
        end
    endfunction

    // --------------------------------------------------
    // Check task
    // --------------------------------------------------
    task check_vector;
        begin

            exp = A + B + Cin;

            #1;

            // -----------------------------
            // Structural
            // -----------------------------
            if ((Sum_s  !== exp[15:0]) ||
                (Cout_s !== exp[16])   ||
                (Ov_s   !== calc_overflow(A,B,exp[15:0])) ||
                (Z_s    !== (exp[15:0] == 16'h0000))      ||
                (Neg_s  !== exp[15]))
            begin
                $display("STRUCT FAIL : A=%h B=%h Cin=%b Sum=%h Exp=%h",
                         A,B,Cin,Sum_s,exp[15:0]);
                fail_r = fail_r + 1;
            end

            // -----------------------------
            // Dataflow
            // -----------------------------
            if ((Sum_d  !== exp[15:0]) ||
                (Cout_d !== exp[16])   ||
                (Ov_d   !== calc_overflow(A,B,exp[15:0])) ||
                (Z_d    !== (exp[15:0] == 16'h0000))      ||
                (Neg_d  !== exp[15]))
            begin
                $display("DATAFLOW FAIL : A=%h B=%h Cin=%b Sum=%h Exp=%h",
                         A,B,Cin,Sum_d,exp[15:0]);
                fail_r = fail_r + 1;
            end

            // -----------------------------
            // Behavioral
            // -----------------------------
            if ((Sum_b  !== exp[15:0]) ||
                (Cout_b !== exp[16])   ||
                (Ov_b   !== calc_overflow(A,B,exp[15:0])) ||
                (Z_b    !== (exp[15:0] == 16'h0000))      ||
                (Neg_b  !== exp[15]))
            begin
                $display("BEHAVIORAL FAIL : A=%h B=%h Cin=%b Sum=%h Exp=%h",
                         A,B,Cin,Sum_b,exp[15:0]);
                fail_r = fail_r + 1;
            end

        end
    endtask

    // --------------------------------------------------
    // Main stimulus
    // --------------------------------------------------
    initial
    begin

        $dumpfile("cla_tb.vcd");
        $dumpvars(0, tb_cla_adder_16bit);

        pass_d = 0;
        fail_d = 0;

        pass_r = 0;
        fail_r = 0;

        //------------------------------------------------
        // DIRECTED TESTS
        //------------------------------------------------

        // All zeros
        A   = 16'h0000;
        B   = 16'h0000;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // All ones
        A   = 16'hFFFF;
        B   = 16'hFFFF;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // Rollover
        A   = 16'hFFFF;
        B   = 16'h0001;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // Signed overflow positive
        A   = 16'h7FFF;
        B   = 16'h0001;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // Signed overflow negative
        A   = 16'h8000;
        B   = 16'h8000;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // Checkerboard
        A   = 16'hAAAA;
        B   = 16'h5555;
        Cin = 1'b0;
        check_vector();
        pass_d = pass_d + 1;

        // Checkerboard inverse
        A   = 16'h5555;
        B   = 16'hAAAA;
        Cin = 1'b1;
        check_vector();
        pass_d = pass_d + 1;

        //------------------------------------------------
        // Single-bit sweep on A
        //------------------------------------------------
        for(i=0;i<16;i=i+1)
        begin
            A   = (16'h0001 << i);
            B   = 16'h0000;
            Cin = 1'b0;
            check_vector();
            pass_d = pass_d + 1;

            A   = (16'h0001 << i);
            B   = 16'h0000;
            Cin = 1'b1;
            check_vector();
            pass_d = pass_d + 1;
        end

        //------------------------------------------------
        // Single-bit sweep on B
        //------------------------------------------------
        for(i=0;i<16;i=i+1)
        begin
            A   = 16'h0000;
            B   = (16'h0001 << i);
            Cin = 1'b0;
            check_vector();
            pass_d = pass_d + 1;

            A   = 16'h0000;
            B   = (16'h0001 << i);
            Cin = 1'b1;
            check_vector();
            pass_d = pass_d + 1;
        end

        //------------------------------------------------
        // RANDOM TESTS (50,000 vectors)
        //------------------------------------------------
        for(i=0;i<50000;i=i+1)
        begin

            A   = $random;
            B   = $random;
            Cin = $random;

            exp = A + B + Cin;

            #1;

            if ((Sum_s  === exp[15:0]) &&
                (Cout_s === exp[16])   &&
                (Sum_d  === exp[15:0]) &&
                (Cout_d === exp[16])   &&
                (Sum_b  === exp[15:0]) &&
                (Cout_b === exp[16]))
            begin
                pass_r = pass_r + 1;
            end
            else
            begin
                fail_r = fail_r + 1;

                $display(
                    "RANDOM FAIL %0d : A=%h B=%h Cin=%b Exp=%h",
                    i,A,B,Cin,exp
                );
            end
        end

        //------------------------------------------------
        // SUMMARY
        //------------------------------------------------

        $display("=======================================");
        $display("CLA VERIFICATION SUMMARY");
        $display("=======================================");
        $display("Directed : %0d / %0d",
                  pass_d,
                  pass_d + fail_d);

        $display("Random   : %0d / 50000",
                  pass_r);

        $display("Failures : %0d",
                  fail_d + fail_r);

        $display("Verdict  : %s",
                 ((fail_d + fail_r) == 0) ?
                 "ALL PASS" :
                 "FAILURES");

        $display("=======================================");

        $finish;

    end

endmodule
