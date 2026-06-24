module mux2( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
assign y = sel ? b : a; 
endmodule 
 
module barrel_shifter_16( 
    input  wire [15:0] data_in, 
    input  wire [3:0]  shift, 
    output wire [15:0] data_out 
); 
 
wire [15:0] s0, s1, s2; 
 
/* Stage-0: shift by 1 */ 
/* 16 muxes */ 
 
/* Stage-1: shift by 2 */ 
/* 16 muxes */ 

 
/* Stage-2: shift by 4 */ 
/* 16 muxes */ 
 
/* Stage-3: shift by 8 */ 
/* 16 muxes */ 
 
endmodule