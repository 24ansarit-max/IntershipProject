`timescale 1ns/1ps 
 
module barrel_shifter16_dataflow ( 
    input  wire [15:0] in, 
    input  wire [3:0]  shamt, 
    input  wire [2:0]  mode, 
    output wire [15:0] out 
); 
 
assign out = 
 
    // Logical Shift Left (LSL) 
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
 
    // Logical Shift Right (LSR) 
    (mode == 3'b001) ? 
        ((shamt == 4'd0 ) ? in : 
         (shamt == 4'd1 ) ? {1'b0,in[15:1]} : 
         (shamt == 4'd2 ) ? {2'b00,in[15:2]} : 
         (shamt == 4'd3 ) ? {3'b000,in[15:3]} : 
         (shamt == 4'd4 ) ? {4'b0000,in[15:4]} : 
         (shamt == 4'd5 ) ? {5'b00000,in[15:5]} : 
         (shamt == 4'd6 ) ? {6'b000000,in[15:6]} : 
         (shamt == 4'd7 ) ? {7'b0000000,in[15:7]} : 
         (shamt == 4'd8 ) ? {8'h00,in[15:8]} : 
         (shamt == 4'd9 ) ? {9'h000,in[15:9]} : 
         (shamt == 4'd10) ? {10'h000,in[15:10]} : 
         (shamt == 4'd11) ? {11'h000,in[15:11]} : 
         (shamt == 4'd12) ? {12'h000,in[15:12]} : 
         (shamt == 4'd13) ? {13'h0000,in[15:13]} : 
         (shamt == 4'd14) ? {14'h0000,in[15:14]} : 
                            {15'h0000,in[15]}) 
 

    : 
 
    // Arithmetic Shift Right (ASR) 
    (mode == 3'b010) ? 
        ((shamt == 4'd0 ) ? in : 
         (shamt == 4'd1 ) ? {{1{in[15]}},in[15:1]} : 
         (shamt == 4'd2 ) ? {{2{in[15]}},in[15:2]} : 
         (shamt == 4'd3 ) ? {{3{in[15]}},in[15:3]} : 
         (shamt == 4'd4 ) ? {{4{in[15]}},in[15:4]} : 
         (shamt == 4'd5 ) ? {{5{in[15]}},in[15:5]} : 
         (shamt == 4'd6 ) ? {{6{in[15]}},in[15:6]} : 
         (shamt == 4'd7 ) ? {{7{in[15]}},in[15:7]} : 
         (shamt == 4'd8 ) ? {{8{in[15]}},in[15:8]} : 
         (shamt == 4'd9 ) ? {{9{in[15]}},in[15:9]} : 
         (shamt == 4'd10) ? {{10{in[15]}},in[15:10]} : 
         (shamt == 4'd11) ? {{11{in[15]}},in[15:11]} : 
         (shamt == 4'd12) ? {{12{in[15]}},in[15:12]} : 
         (shamt == 4'd13) ? {{13{in[15]}},in[15:13]} : 
         (shamt == 4'd14) ? {{14{in[15]}},in[15:14]} : 
                            {{15{in[15]}},in[15]}) 
 
    : 
 
    // Rotate Left (ROL) 
    (mode == 3'b011) ? 
        ((in << shamt) | (in >> (16 - shamt))) 
 
    : 

 
    // Rotate Right (ROR) 
    (mode == 3'b100) ? 
        ((in >> shamt) | (in << (16 - shamt))) 
 
    : 
 
    16'h0000; 
endmodule