`timescale 1ns/1ps 
 

module barrel_shifter 
#( 
    parameter WIDTH = 16 
) 
( 
    input  wire [WIDTH-1:0] in, 
    input  wire [3:0]       shamt, 
 
    //000 LSL 
    //001 LSR 
    //010 ASR 
    //011 ROL 
    //100 ROR 
    input  wire [2:0] mode, 
 
    output wire [WIDTH-1:0] out 
); 
 
assign out = 
 
(mode == 3'b000) ? 
 
    ((shamt == 4'd0 ) ? in : 
     (shamt == 4'd1 ) ? {in[14:0],1'b0} : 
     (shamt == 4'd2 ) ? {in[13:0],2'b00} : 
     (shamt == 4'd3 ) ? {in[12:0],3'b000} : 
     (shamt == 4'd4 ) ? {in[11:0],4'b0000} : 
     (shamt == 4'd5 ) ? {in[10:0],5'b00000} : 

     (shamt == 4'd6 ) ? {in[9:0],6'b000000} : 
     (shamt == 4'd7 ) ? {in[8:0],7'b0000000} : 
     (shamt == 4'd8 ) ? {in[7:0],8'h00} : 
     (shamt == 4'd9 ) ? {in[6:0],9'h000} : 
     (shamt == 4'd10) ? {in[5:0],10'h000} : 
     (shamt == 4'd11) ? {in[4:0],11'h000} : 
     (shamt == 4'd12) ? {in[3:0],12'h000} : 
     (shamt == 4'd13) ? {in[2:0],13'h0000} : 
     (shamt == 4'd14) ? {in[1:0],14'h0000} : 
                        {in[0],15'h0000}) 
 
: 
 
(mode == 3'b001) ? 
 
    (in >> shamt) 
 
: 
 
(mode == 3'b010) ? 
 
    ($signed(in) >>> shamt) 
 
: 
 
(mode == 3'b011) ? 
 
    ((in << shamt) | (in >> (WIDTH-shamt))) 

 
: 
 
(mode == 3'b100) ? 
 
    ((in >> shamt) | (in << (WIDTH-shamt))) 
 
: 
 
    in; 
 
endmodule