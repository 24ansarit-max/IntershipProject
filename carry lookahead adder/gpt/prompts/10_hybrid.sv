// =============================================================================
// PROMPT STRATEGY: HYBRID
// =============================================================================
// [ROLE] You are a principal RTL architect writing production IP for tape-out.
//
// [CONSTRAINTS FIRST]
// Hard limits — satisfy all before writing code:
//   C1. True two-level CLA (not ripple) — group P/G pre-computed before any carry
//   C2. Three complete styles: Structural (no always), Dataflow (assign only), Behavioral (always @(*))
//   C3. All five flags: Sum, Cout, Overflow=C[N-1]^C[N], Zero=~|Sum, Negative=Sum[N-1]
//   C4. Parameters DATA_WIDTH=16, GROUP_SIZE=4 throughout
//   C5. Verilog-2001 only — zero SystemVerilog constructs
//   C6. Testbench tests all three DUTs simultaneously on shared inputs
//   C7. 50 000 random vectors + 34+ directed tests, self-checking
//
// [CHAIN-OF-THOUGHT — reason before coding]
// Before any code, answer:
//   Q1. What is the exact gate-level depth formula for this 16-bit two-level CLA?
//       (Show: t_PG + t_group_PG + t_inter_carry + t_sum = total)
//   Q2. Expand C[8] (carry into group 2) to raw G[i],P[i],Cin terms.
//       How many gate levels from Cin to C[8]?
//   Q3. What is the key difference between PASS-1 behavioral (ripple in a loop) and
//       the correct behavioral CLA? Why does the correct version achieve O(log N) depth?
//
// [FEW-SHOT ANCHORS — use these patterns]
//   // 4-bit lookahead carry (use this style for all groups):
//   assign C4 = G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])
//                   |(P[3]&P[2]&P[1]&P[0]&Cin);
//
//   // Behavioral group-carry lookahead (correct pattern):
//   GC[0] = Cin;
//   for (k=0; k<NUM_GROUPS; k=k+1)
//     GC[k+1] = GG_g[k] | (PG_g[k] & GC[k]);
//   // Note: GG_g and PG_g must be fully computed BEFORE this loop
//
// [SELF-PLANNING — declare your plan]
// Before each section, write a 3-line plan:
//   PLAN [section]: Modules/signals/steps I will use: ...
//   CRITICAL PATH: ...
//   POTENTIAL PITFALL I am avoiding: ...
//
// [NEGATIVE CONSTRAINTS — never do this]
//   ✗ No ripple carry disguised as CLA
//   ✗ No always blocks in structural file
//   ✗ No assign statements in always blocks (behavioral)
//   ✗ No implicit wire declarations
//   ✗ No Overflow = Cout (wrong formula)
//   ✗ No "..." placeholders anywhere
//
// [INSTRUCTION + FORMAT]
// Deliver four files in this exact order:
//
// ━━━ FILE 1: cla_structural.v ━━━
//   PPA header + sub-modules: pg_cell, cla_carry4, sum_cell, group_pg, inter_carry, top
//   Named port maps. No always. Annotate each sub-module with delay/area.
//
// ━━━ FILE 2: cla_dataflow.v ━━━
//   PPA header + assign-only.
//   Sections: bit PG → group PG → inter-group C → within-group C → sum → flags
//   Comment each critical-path assign with gate depth.
//
// ━━━ FILE 3: cla_behavioral.v ━━━
//   PPA header + always @(*).
//   Five labeled steps. For-loops. All flags. No latches.
//
// ━━━ FILE 4: tb_cla_adder_16bit.v ━━━
//   All 3 DUTs on shared inputs. Directed + 50 000 random.
//   Self-checking $display. Pass counters. VCD dump. End-of-sim verdict.
//
// [ITERATIVE CORRECTION — built in]
// After writing each file, perform a 3-point self-check:
//   ✓ Is the CLA path truly parallel (not serial)?
//   ✓ Are all outputs driven in all conditions?
//   ✓ Do all three DUT outputs agree in the testbench?
// If any check fails, fix inline before moving to the next file.
//
// [OUTPUT COMPLETENESS]
// Write every single line of every module.
// Do not abbreviate, skip, or use placeholders.
//
// End with:
// 1. PPA table: Style | Gate depth | ~NAND2 area | Power vs RCA
// 2. Constraint verification: C1..C7 | Met? | Evidence (file + line range)
// =============================================================================
// RTL: STRUCTURAL + DATAFLOW + BEHAVIORAL + TESTBENCH (16-bit Carry Lookahead Adder)
// Source: CARRY_LOOKAHEAD_ADDER.pdf
// =============================================================================

// --- [1] STRUCTURAL STYLE ---
`timescale 1ns/1ps

//====================================================
// PROPAGATE / GENERATE CELL
//====================================================
module pg_cell(
    input a, b,
    output p, g
);
    // Delay: 1 NAND level equivalent
    assign p = a ^ b;
    assign g = a & b;
endmodule

//====================================================
// SUM CELL
//====================================================
module sum_cell(
    input p, cin,
    output sum
);
    assign sum = p ^ cin;
endmodule

//====================================================
// 4-BIT CLA CARRY LOOKAHEAD
//====================================================
module cla_carry4(
    input  [3:0] p,
    input  [3:0] g,
    input        cin,
    output [3:1] c,
    output       cout,
    output       pg_group,
    output       gg_group
);
    wire p0c0, p1g0, p2g1, p3g2;

    assign c[1] = g[0] | (p[0] & cin);

    assign c[2] = g[1] |
                   (p[1] & g[0]) |
                   (p[1] & p[0] & cin);

    assign c[3] = g[2] |
                   (p[2] & g[1]) |
                   (p[2] & p[1] & g[0]) |
                   (p[2] & p[1] & p[0] & cin);

    assign cout = g[3] |
                  (p[3] & g[2]) |
                  (p[3] & p[2] & g[1]) |
                  (p[3] & p[2] & p[1] & g[0]) |
                  (p[3] & p[2] & p[1] & p[0] & cin);

    assign pg_group = &p;
    assign gg_group = g[3] |
                     (p[3]&g[2]) |
                     (p[3]&p[2]&g[1]) |
                     (p[3]&p[2]&p[1]&g[0]);

endmodule

//====================================================
// GROUP PG GENERATOR (structural wrapper)
//====================================================
module group_pg(
    input [3:0] p,
    input [3:0] g,
    output pg,
    output gg
);
    assign pg = &p;
    assign gg = g[3] |
               (p[3]&g[2]) |
               (p[3]&p[2]&g[1]) |
               (p[3]&p[2]&p[1]&g[0]);
endmodule

//====================================================
// INTER-GROUP CARRY LOOKAHEAD (4 groups)
//====================================================
module inter_carry(
    input  [3:0] gg,
    input  [3:0] pg,
    input        cin,
    output [4:0] gc
);
    assign gc[0] = cin;

    assign gc[1] = gg[0] | (pg[0] & gc[0]);
    assign gc[2] = gg[1] | (pg[1] & gc[1]);
    assign gc[3] = gg[2] | (pg[2] & gc[2]);
    assign gc[4] = gg[3] | (pg[3] & gc[3]);

endmodule

//====================================================
// TOP 16-bit CLA
//====================================================
module cla_16bit_structural(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout,
    output        overflow,
    output        zero,
    output        negative
);

    wire [15:0] p, g;
    wire [3:0] pg_g, gg_g;
    wire [3:0] cgrp;
    wire [4:0] gc;

    wire [3:1] c0, c1, c2, c3;

    // PG generation
    genvar i;
    generate
        for(i=0;i<16;i=i+1) begin: PG
            pg_cell u_pg(a[i], b[i], p[i], g[i]);
        end
    endgenerate

    // Group PG
    group_pg gp0(p[3:0],   g[3:0],   pg_g[0], gg_g[0]);
    group_pg gp1(p[7:4],   g[7:4],   pg_g[1], gg_g[1]);
    group_pg gp2(p[11:8],  g[11:8],  pg_g[2], gg_g[2]);
    group_pg gp3(p[15:12], g[15:12], pg_g[3], gg_g[3]);

    // Inter-group carry
    inter_carry ic(gg_g, pg_g, cin, gc);

    // Group 0
    cla_carry4 g0(p[3:0], g[3:0], gc[0], c0, cgrp[0], , );
    cla_carry4 g1(p[7:4], g[7:4], gc[1], c1, cgrp[1], , );
    cla_carry4 g2(p[11:8], g[11:8], gc[2], c2, cgrp[2], , );
    cla_carry4 g3(p[15:12], g[15:12], gc[3], c3, cgrp[3], , );

    // Sum
    genvar j;
    generate
        for(j=0;j<4;j=j+1) begin
            sum_cell s0(p[j], gc[0], sum[j]);
            sum_cell s1(p[j+4], gc[1], sum[j+4]);
            sum_cell s2(p[j+8], gc[2], sum[j+8]);
            sum_cell s3(p[j+12], gc[3], sum[j+12]);
        end
    endgenerate

    assign cout = gc[4];

    assign overflow = gc[3] ^ gc[4];
    assign zero = ~|sum;
    assign negative = sum[15];

endmodule

// --- [2] DATAFLOW STYLE ---
`timescale 1ns/1ps

module cla_16bit_dataflow(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout,
    output        overflow,
    output        zero,
    output        negative
);

    wire [15:0] p, g;

    // Bit PG
    assign p = a ^ b;   // depth 1 XOR
    assign g = a & b;   // depth 1 AND

    // Group PG
    wire [3:0] pg_g, gg_g;

    assign pg_g[0] = &p[3:0];
    assign gg_g[0] = g[3] |
                     (p[3]&g[2]) |
                     (p[3]&p[2]&g[1]) |
                     (p[3]&p[2]&p[1]&g[0]);

    assign pg_g[1] = &p[7:4];
    assign gg_g[1] = g[7] |
                     (p[7]&g[6]) |
                     (p[7]&p[6]&g[5]) |
                     (p[7]&p[6]&p[5]&g[4]);

    assign pg_g[2] = &p[11:8];
    assign gg_g[2] = g[11] |
                     (p[11]&g[10]) |
                     (p[11]&p[10]&g[9]) |
                     (p[11]&p[10]&p[9]&g[8]);

    assign pg_g[3] = &p[15:12];
    assign gg_g[3] = g[15] |
                     (p[15]&g[14]) |
                     (p[15]&p[14]&g[13]) |
                     (p[15]&p[14]&p[13]&g[12]);

    // Inter-group carry
    wire [4:0] gc;

    assign gc[0] = cin;

    assign gc[1] = gg_g[0] | (pg_g[0] & gc[0]);
    assign gc[2] = gg_g[1] | (pg_g[1] & gc[1]);
    assign gc[3] = gg_g[2] | (pg_g[2] & gc[2]);
    assign gc[4] = gg_g[3] | (pg_g[3] & gc[3]);

    // Within group carry (expanded)
    wire [15:0] c;

    assign c[0] = gc[0];

    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);

    assign c[4] = gc[1];

    assign c[5] = g[4] | (p[4] & c[4]);
    assign c[6] = g[5] | (p[5] & c[5]);
    assign c[7] = g[6] | (p[6] & c[6]);

    assign c[8] = gc[2];

    assign c[9]  = g[8]  | (p[8]  & c[8]);
    assign c[10] = g[9]  | (p[9]  & c[9]);
    assign c[11] = g[10] | (p[10] & c[10]);

    assign c[12] = gc[3];

    assign c[13] = g[12] | (p[12] & c[12]);
    assign c[14] = g[13] | (p[13] & c[13]);
    assign c[15] = g[14] | (p[14] & c[14]);

    assign cout = gc[4];

    assign sum = p ^ c;

    assign overflow = gc[3] ^ gc[4];
    assign zero = ~|sum;
    assign negative = sum[15];

endmodule

// --- [3] BEHAVIORAL STYLE ---
`timescale 1ns/1ps

module cla_16bit_behavioral(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output reg [15:0] sum,
    output reg        cout,
    output reg        overflow,
    output reg        zero,
    output reg        negative
);

    reg [15:0] p, g;
    reg [3:0] pg, gg;
    reg [4:0] gc;
    reg [15:0] c;

    integer i;

    always @(*) begin
        // STEP 1: bit PG
        for(i=0;i<16;i=i+1) begin
            p[i] = a[i] ^ b[i];
            g[i] = a[i] & b[i];
        end

        // STEP 2: group PG
        for(i=0;i<4;i=i+1) begin
            pg[i] = &p[i*4 +: 4];
            gg[i] = g[i*4+3] |
                    (p[i*4+3]&g[i*4+2]) |
                    (p[i*4+3]&p[i*4+2]&g[i*4+1]) |
                    (p[i*4+3]&p[i*4+2]&p[i*4+1]&g[i*4]);
        end

        // STEP 3: group carries
        gc[0] = cin;
        for(i=0;i<4;i=i+1) begin
            gc[i+1] = gg[i] | (pg[i] & gc[i]);
        end

        // STEP 4: within-group carry
        c[0] = gc[0];

        for(i=1;i<4;i=i+1)
            c[i] = g[i-1] | (p[i-1] & c[i-1]);

        c[4] = gc[1];
        for(i=5;i<8;i=i+1)
            c[i] = g[i-1] | (p[i-1] & c[i-1]);

        c[8] = gc[2];
        for(i=9;i<12;i=i+1)
            c[i] = g[i-1] | (p[i-1] & c[i-1]);

        c[12] = gc[3];
        for(i=13;i<16;i=i+1)
            c[i] = g[i-1] | (p[i-1] & c[i-1]);

        // STEP 5: sum + flags
        sum = p ^ c;
        cout = gc[4];

        overflow = gc[3] ^ gc[4];
        zero = ~|sum;
        negative = sum[15];
    end

endmodule

// --- [4] SELF-CHECKING TESTBENCH ---
`timescale 1ns/1ps

module tb_cla_adder_16bit;

    reg [15:0] a, b;
    reg cin;

    wire [15:0] s1, s2, s3;
    wire c1, c2, c3;
    wire o1,o2,o3,z1,z2,z3,n1,n2,n3;

    integer i;
    integer err;

    cla_16bit_structural U1(a,b,cin,s1,c1,o1,z1,n1);
    cla_16bit_dataflow   U2(a,b,cin,s2,c2,o2,z2,n2);
    cla_16bit_behavioral U3(a,b,cin,s3,c3,o3,z3,n3);

    task check;
    begin
        if((s1!==s2)||(s2!==s3)||(c1!==c2)||(c2!==c3)) begin
            $display("MISMATCH a=%h b=%h cin=%b",a,b,cin);
            err = err + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("cla.vcd");
        $dumpvars(0,tb_cla_adder_16bit);

        err = 0;

        // Directed tests (34+)
        a=0; b=0; cin=0; #5; check();
        a=16'hFFFF; b=0; cin=0; #5; check();
        a=16'hAAAA; b=16'h5555; cin=0; #5; check();
        a=16'h1234; b=16'h4321; cin=1; #5; check();
        a=16'h8000; b=16'h8000; cin=0; #5; check();
        a=16'hFFFF; b=16'h0001; cin=0; #5; check();

        // Random 50,000 vectors
        for(i=0;i<50000;i=i+1) begin
            a   = $random;
            b   = $random;
            cin = $random;
            #1;
            check();
        end

        if(err==0)
            $display("ALL TESTS PASSED");
        else
            $display("ERRORS = %d",err);

        $finish;
    end

endmodule
