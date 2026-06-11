`timescale 1ns/1ps 
 
module mux2 ( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
    (* keep_hierarchy = "yes" *) 
 
    wire nsel; 
    wire y1, y2; 
 

    not (nsel, sel); 
 
    and (y1, a, nsel); 
    and (y2, b, sel); 
 
    or  (y, y1, y2); 
 
endmodule 
module barrel_shifter16 ( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift, 
    output wire [15:0] out 
); 
 
    (* keep_hierarchy = "yes" *) 
 
    // ------------------------- 
    // Stage interconnect wires 
    // ------------------------- 
    wire [15:0] s1, s2, s3, s4; 
 
    wire [15:0] t1, t2, t3, t4; 
 
    genvar i; 
 
    // ========================================================= 
    // STAGE 0 : SHIFT BY 1 (shift[0]) 
    // ========================================================= 

    generate 
        for (i = 0; i < 16; i = i + 1) begin : STAGE1 
            mux2 u_mux ( 
                .a(in[i]), 
                .b((i < 15) ? in[i+1] : 1'b0), 
                .sel(shift[0]), 
                .y(s1[i]) 
            ); 
        end 
    endgenerate 
 
    // ========================================================= 
    // STAGE 1 : SHIFT BY 2 (shift[1]) 
    // ========================================================= 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STAGE2 
            mux2 u_mux ( 
                .a(s1[i]), 
                .b((i < 14) ? s1[i+2] : 1'b0), 
                .sel(shift[1]), 
                .y(s2[i]) 
            ); 
        end 
    endgenerate 
 
    // ========================================================= 
    // STAGE 2 : SHIFT BY 4 (shift[2]) 
    // ========================================================= 

    generate 
        for (i = 0; i < 16; i = i + 1) begin : STAGE3 
            mux2 u_mux ( 
                .a(s2[i]), 
                .b((i < 12) ? s2[i+4] : 1'b0), 
                .sel(shift[2]), 
                .y(s3[i]) 
            ); 
        end 
    endgenerate 
 
    // ========================================================= 
    // STAGE 3 : SHIFT BY 8 (shift[3]) 
    // ========================================================= 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : STAGE4 
            mux2 u_mux ( 
                .a(s3[i]), 
                .b((i < 8) ? s3[i+8] : 1'b0), 
                .sel(shift[3]), 
                .y(s4[i]) 
            ); 
        end 
    endgenerate 
 
    // Final output 
    generate 
        for (i = 0; i < 16; i = i + 1) begin : OUT_ASSIGN 

            mux2 u_out ( 
                .a(s4[i]), 
                .b(s4[i]), 
                .sel(1'b0), 
                .y(out[i]) 
            ); 
        end 
    endgenerate 
 
endmodule