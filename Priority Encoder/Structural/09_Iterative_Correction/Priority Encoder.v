// Strategy: 09 Iterative Correction
// Style: Structural
`timescale 1ns/1ps

// 4-to-2 Priority Encoder Cell
module pe4_structural (
    input  wire [3:0] r,
    output wire [1:0] code,
    output wire       valid
);
    wire not_r2;
    wire and_r1_not_r2;
    
    or  (valid, r[3], r[2], r[1], r[0]);
    or  (code[1], r[3], r[2]);
    not (not_r2, r[2]);
    and (and_r1_not_r2, r[1], not_r2);
    or  (code[0], r[3], and_r1_not_r2);
endmodule

// 4-to-1 2-bit Multiplexer
module mux4_2bit (
    input  wire [1:0] sel,
    input  wire [1:0] d0,
    input  wire [1:0] d1,
    input  wire [1:0] d2,
    input  wire [1:0] d3,
    output wire [1:0] y
);
    wire not_sel1, not_sel0;
    not (not_sel1, sel[1]);
    not (not_sel0, sel[0]);
    
    wire [3:0] w0, w1;
    
    // bit 0 logic
    and (w0[0], not_sel1, not_sel0, d0[0]);
    and (w0[1], not_sel1, sel[0], d1[0]);
    and (w0[2], sel[1], not_sel0, d2[0]);
    and (w0[3], sel[1], sel[0], d3[0]);
    or  (y[0], w0[0], w0[1], w0[2], w0[3]);
    
    // bit 1 logic
    and (w1[0], not_sel1, not_sel0, d0[1]);
    and (w1[1], not_sel1, sel[0], d1[1]);
    and (w1[2], sel[1], not_sel0, d2[1]);
    and (w1[3], sel[1], sel[0], d3[1]);
    or  (y[1], w1[0], w1[1], w1[2], w1[3]);
endmodule

// 16-to-4 Structural Priority Encoder
module priority_encoder_16 (
    input  wire [15:0] in,
    output wire [3:0]  out,
    output wire        valid
);
    wire [1:0] code0, code1, code2, code3;
    wire valid0, valid1, valid2, valid3;
    wire [1:0] group_code;

    // Instantiate 4-to-2 PE for each 4-bit group
    pe4_structural pe0 (.r(in[3:0]),   .code(code0), .valid(valid0));
    pe4_structural pe1 (.r(in[7:4]),   .code(code1), .valid(valid1));
    pe4_structural pe2 (.r(in[11:8]),  .code(code2), .valid(valid2));
    pe4_structural pe3 (.r(in[15:12]), .code(code3), .valid(valid3));

    // Instantiate 4-to-2 PE for the group valids to determine high-order bits
    pe4_structural pe_group (.r({valid3, valid2, valid1, valid0}), .code(group_code), .valid(valid));

    assign out[3:2] = group_code;

    // Instantiate mux to select lower bits based on active group
    mux4_2bit mux (.sel(group_code), .d0(code0), .d1(code1), .d2(code2), .d3(code3), .y(out[1:0]));

endmodule
