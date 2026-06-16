`timescale 1ns/1ps 
 
// ======================================================= 
// 1-bit MUX (leaf primitive built structurally) 
// ======================================================= 
module mux2 ( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
 
    wire nsel; 
    wire a1, b1; 
 
    not (nsel, sel); 
 
    and (a1, a, nsel); 
    and (b1, b, sel); 
    or  (y, a1, b1); 
 
endmodule 
 
 
// ======================================================= 
// 16-bit Barrel Shifter (Structural, Left Logical Shift) 
// ======================================================= 

module barrel_shifter16 ( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift, 
    output wire [15:0] out 
); 
 
    (* keep_hierarchy = "yes" *) 
 
    wire [15:0] s0, s1, s2, s3; 
    wire [15:0] t0, t1, t2, t3; 
 
    genvar i; 
 
    // =================================================== 
    // STAGE 0: shift by 1 
    // =================================================== 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STG0 
            mux2 u0 ( 
                .a(in[i]), 
                .b((i < 15) ? in[i+1] : 1'b0), 
                .sel(shift[0]), 
                .y(s0[i]) 
            ); 
        end 
    endgenerate 
 
    // =================================================== 

    // STAGE 1: shift by 2 
    // =================================================== 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STG1 
            mux2 u1 ( 
                .a(s0[i]), 
                .b((i < 14) ? s0[i+2] : 1'b0), 
                .sel(shift[1]), 
                .y(s1[i]) 
            ); 
        end 
    endgenerate 
 
    // =================================================== 
    // STAGE 2: shift by 4 
    // =================================================== 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STG2 
            mux2 u2 ( 
                .a(s1[i]), 
                .b((i < 12) ? s1[i+4] : 1'b0), 
                .sel(shift[2]), 
                .y(s2[i]) 
            ); 
        end 
    endgenerate 
 
    // =================================================== 

    // STAGE 3: shift by 8 
    // =================================================== 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STG3 
            mux2 u3 ( 
                .a(s2[i]), 
                .b((i < 8) ? s2[i+8] : 1'b0), 
                .sel(shift[3]), 
                .y(s3[i]) 
            ); 
        end 
    endgenerate 
 
    // Final output stage (buffer mux form for strict structural purity) 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : OUT 
            mux2 u4 ( 
                .a(s3[i]), 
                .b(s3[i]), 
                .sel(1'b0), 
                .y(out[i]) 
            ); 
        end 
    endgenerate 
 
endmodule