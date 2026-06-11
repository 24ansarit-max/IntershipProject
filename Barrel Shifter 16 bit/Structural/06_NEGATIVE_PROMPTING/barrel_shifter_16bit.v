//===================================================== 
// 2:1 Multiplexer Cell 
//===================================================== 
module mux2 ( 
    input  a, 
    input  b, 
    input  sel, 
    output y 
); 
    assign y = sel ? b : a; 
endmodule 
 
//===================================================== 
// 16-bit Barrel Shifter (Left Logical) 
// Structural Verilog 

//===================================================== 
module barrel_shifter_16 ( 
    input  [15:0] data_in, 
    input  [3:0]  shift, 
    output [15:0] data_out 
); 
 
wire [15:0] s0; 
wire [15:0] s1; 
wire [15:0] s2; 
wire [15:0] s3; 
 
//----------------------------------------------------- 
// Stage 0 : Shift by 1 
//----------------------------------------------------- 
mux2 m00 (.a(data_in[0]),  .b(1'b0),       .sel(shift[0]), .y(s0[0])); 
mux2 m01 (.a(data_in[1]),  .b(data_in[0]), .sel(shift[0]), .y(s0[1])); 
mux2 m02 (.a(data_in[2]),  .b(data_in[1]), .sel(shift[0]), .y(s0[2])); 
mux2 m03 (.a(data_in[3]),  .b(data_in[2]), .sel(shift[0]), .y(s0[3])); 
mux2 m04 (.a(data_in[4]),  .b(data_in[3]), .sel(shift[0]), .y(s0[4])); 
mux2 m05 (.a(data_in[5]),  .b(data_in[4]), .sel(shift[0]), .y(s0[5])); 
mux2 m06 (.a(data_in[6]),  .b(data_in[5]), .sel(shift[0]), .y(s0[6])); 
mux2 m07 (.a(data_in[7]),  .b(data_in[6]), .sel(shift[0]), .y(s0[7])); 
mux2 m08 (.a(data_in[8]),  .b(data_in[7]), .sel(shift[0]), .y(s0[8])); 
mux2 m09 (.a(data_in[9]),  .b(data_in[8]), .sel(shift[0]), .y(s0[9])); 
mux2 m10 (.a(data_in[10]), .b(data_in[9]), .sel(shift[0]), .y(s0[10])); 
mux2 m11 (.a(data_in[11]), .b(data_in[10]),.sel(shift[0]), .y(s0[11])); 
mux2 m12 (.a(data_in[12]), .b(data_in[11]),.sel(shift[0]), .y(s0[12])); 

mux2 m13 (.a(data_in[13]), .b(data_in[12]),.sel(shift[0]), .y(s0[13])); 
mux2 m14 (.a(data_in[14]), .b(data_in[13]),.sel(shift[0]), .y(s0[14])); 
mux2 m15 (.a(data_in[15]), .b(data_in[14]),.sel(shift[0]), .y(s0[15])); 
 
//----------------------------------------------------- 
// Stage 1 : Shift by 2 
//----------------------------------------------------- 
mux2 m16 (.a(s0[0]),  .b(1'b0), .sel(shift[1]), .y(s1[0])); 
mux2 m17 (.a(s0[1]),  .b(1'b0), .sel(shift[1]), .y(s1[1])); 
mux2 m18 (.a(s0[2]),  .b(s0[0]), .sel(shift[1]), .y(s1[2])); 
mux2 m19 (.a(s0[3]),  .b(s0[1]), .sel(shift[1]), .y(s1[3])); 
mux2 m20 (.a(s0[4]),  .b(s0[2]), .sel(shift[1]), .y(s1[4])); 
mux2 m21 (.a(s0[5]),  .b(s0[3]), .sel(shift[1]), .y(s1[5])); 
mux2 m22 (.a(s0[6]),  .b(s0[4]), .sel(shift[1]), .y(s1[6])); 
mux2 m23 (.a(s0[7]),  .b(s0[5]), .sel(shift[1]), .y(s1[7])); 
mux2 m24 (.a(s0[8]),  .b(s0[6]), .sel(shift[1]), .y(s1[8])); 
mux2 m25 (.a(s0[9]),  .b(s0[7]), .sel(shift[1]), .y(s1[9])); 
mux2 m26 (.a(s0[10]), .b(s0[8]), .sel(shift[1]), .y(s1[10])); 
mux2 m27 (.a(s0[11]), .b(s0[9]), .sel(shift[1]), .y(s1[11])); 
mux2 m28 (.a(s0[12]), .b(s0[10]),.sel(shift[1]), .y(s1[12])); 
mux2 m29 (.a(s0[13]), .b(s0[11]),.sel(shift[1]), .y(s1[13])); 
mux2 m30 (.a(s0[14]), .b(s0[12]),.sel(shift[1]), .y(s1[14])); 
mux2 m31 (.a(s0[15]), .b(s0[13]),.sel(shift[1]), .y(s1[15])); 
 
//----------------------------------------------------- 
// Stage 2 : Shift by 4 
//----------------------------------------------------- 
mux2 m32 (.a(s1[0]), .b(1'b0), .sel(shift[2]), .y(s2[0])); 

mux2 m33 (.a(s1[1]), .b(1'b0), .sel(shift[2]), .y(s2[1])); 
mux2 m34 (.a(s1[2]), .b(1'b0), .sel(shift[2]), .y(s2[2])); 
mux2 m35 (.a(s1[3]), .b(1'b0), .sel(shift[2]), .y(s2[3])); 
mux2 m36 (.a(s1[4]), .b(s1[0]), .sel(shift[2]), .y(s2[4])); 
mux2 m37 (.a(s1[5]), .b(s1[1]), .sel(shift[2]), .y(s2[5])); 
mux2 m38 (.a(s1[6]), .b(s1[2]), .sel(shift[2]), .y(s2[6])); 
mux2 m39 (.a(s1[7]), .b(s1[3]), .sel(shift[2]), .y(s2[7])); 
mux2 m40 (.a(s1[8]), .b(s1[4]), .sel(shift[2]), .y(s2[8])); 
mux2 m41 (.a(s1[9]), .b(s1[5]), .sel(shift[2]), .y(s2[9])); 
mux2 m42 (.a(s1[10]),.b(s1[6]), .sel(shift[2]), .y(s2[10])); 
mux2 m43 (.a(s1[11]),.b(s1[7]), .sel(shift[2]), .y(s2[11])); 
mux2 m44 (.a(s1[12]),.b(s1[8]), .sel(shift[2]), .y(s2[12])); 
mux2 m45 (.a(s1[13]),.b(s1[9]), .sel(shift[2]), .y(s2[13])); 
mux2 m46 (.a(s1[14]),.b(s1[10]),.sel(shift[2]), .y(s2[14])); 
mux2 m47 (.a(s1[15]),.b(s1[11]),.sel(shift[2]), .y(s2[15])); 
 
//----------------------------------------------------- 
// Stage 3 : Shift by 8 
//----------------------------------------------------- 
mux2 m48 (.a(s2[0]), .b(1'b0), .sel(shift[3]), .y(data_out[0])); 
mux2 m49 (.a(s2[1]), .b(1'b0), .sel(shift[3]), .y(data_out[1])); 
mux2 m50 (.a(s2[2]), .b(1'b0), .sel(shift[3]), .y(data_out[2])); 
mux2 m51 (.a(s2[3]), .b(1'b0), .sel(shift[3]), .y(data_out[3])); 
mux2 m52 (.a(s2[4]), .b(1'b0), .sel(shift[3]), .y(data_out[4])); 
mux2 m53 (.a(s2[5]), .b(1'b0), .sel(shift[3]), .y(data_out[5])); 
mux2 m54 (.a(s2[6]), .b(1'b0), .sel(shift[3]), .y(data_out[6])); 
mux2 m55 (.a(s2[7]), .b(1'b0), .sel(shift[3]), .y(data_out[7])); 
mux2 m56 (.a(s2[8]), .b(s2[0]), .sel(shift[3]), .y(data_out[8])); 

mux2 m57 (.a(s2[9]), .b(s2[1]), .sel(shift[3]), .y(data_out[9])); 
mux2 m58 (.a(s2[10]),.b(s2[2]), .sel(shift[3]), .y(data_out[10])); 
mux2 m59 (.a(s2[11]),.b(s2[3]), .sel(shift[3]), .y(data_out[11])); 
mux2 m60 (.a(s2[12]),.b(s2[4]), .sel(shift[3]), .y(data_out[12])); 
mux2 m61 (.a(s2[13]),.b(s2[5]), .sel(shift[3]), .y(data_out[13])); 
mux2 m62 (.a(s2[14]),.b(s2[6]), .sel(shift[3]), .y(data_out[14])); 
mux2 m63 (.a(s2[15]),.b(s2[7]), .sel(shift[3]), .y(data_out[15])); 
 
endmodule