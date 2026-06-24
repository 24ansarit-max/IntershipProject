`timescale 1ns/1ps 
 
module barrel_shifter16_dataflow ( 
    input  wire [15:0] din, 
    input  wire [3:0]  shamt, 
 
    output wire [15:0] lshift, 
    output wire [15:0] rshift_logical, 
    output wire [15:0] rshift_arith, 
    output wire [15:0] rotate_left, 
    output wire [15:0] rotate_right 
); 
 
///////////////////////////////////////////////////// 
// LOGICAL LEFT SHIFT 
///////////////////////////////////////////////////// 
 
assign lshift = 
       (shamt == 4'd0 ) ? din : 
       (shamt == 4'd1 ) ? {din[14:0],1'b0} : 
       (shamt == 4'd2 ) ? {din[13:0],2'b00} : 
       (shamt == 4'd3 ) ? {din[12:0],3'b000} : 
       (shamt == 4'd4 ) ? {din[11:0],4'b0000} : 

       (shamt == 4'd5 ) ? {din[10:0],5'b00000} : 
       (shamt == 4'd6 ) ? {din[9:0],6'b000000} : 
       (shamt == 4'd7 ) ? {din[8:0],7'b0000000} : 
       (shamt == 4'd8 ) ? {din[7:0],8'h00} : 
       (shamt == 4'd9 ) ? {din[6:0],9'h000} : 
       (shamt == 4'd10) ? {din[5:0],10'h000} : 
       (shamt == 4'd11) ? {din[4:0],11'h000} : 
       (shamt == 4'd12) ? {din[3:0],12'h000} : 
       (shamt == 4'd13) ? {din[2:0],13'h0000} : 
       (shamt == 4'd14) ? {din[1:0],14'h0000} : 
                          {din[0],15'h0000}; 
 
///////////////////////////////////////////////////// 
// LOGICAL RIGHT SHIFT 
///////////////////////////////////////////////////// 
 
assign rshift_logical = 
       (shamt == 4'd0 ) ? din : 
       (shamt == 4'd1 ) ? {1'b0,din[15:1]} : 
       (shamt == 4'd2 ) ? {2'b00,din[15:2]} : 
       (shamt == 4'd3 ) ? {3'b000,din[15:3]} : 
       (shamt == 4'd4 ) ? {4'b0000,din[15:4]} : 
       (shamt == 4'd5 ) ? {5'b00000,din[15:5]} : 
       (shamt == 4'd6 ) ? {6'b000000,din[15:6]} : 
       (shamt == 4'd7 ) ? {7'b0000000,din[15:7]} : 
       (shamt == 4'd8 ) ? {8'h00,din[15:8]} : 
       (shamt == 4'd9 ) ? {9'h000,din[15:9]} : 
       (shamt == 4'd10) ? {10'h000,din[15:10]} : 

       (shamt == 4'd11) ? {11'h000,din[15:11]} : 
       (shamt == 4'd12) ? {12'h000,din[15:12]} : 
       (shamt == 4'd13) ? {13'h0000,din[15:13]} : 
       (shamt == 4'd14) ? {14'h0000,din[15:14]} : 
                          {15'h0000,din[15]}; 
 
///////////////////////////////////////////////////// 
// ARITHMETIC RIGHT SHIFT 
///////////////////////////////////////////////////// 
 
assign rshift_arith = 
       (shamt == 4'd0 ) ? din : 
       (shamt == 4'd1 ) ? {{1{din[15]}},din[15:1]} : 
       (shamt == 4'd2 ) ? {{2{din[15]}},din[15:2]} : 
       (shamt == 4'd3 ) ? {{3{din[15]}},din[15:3]} : 
       (shamt == 4'd4 ) ? {{4{din[15]}},din[15:4]} : 
       (shamt == 4'd5 ) ? {{5{din[15]}},din[15:5]} : 
       (shamt == 4'd6 ) ? {{6{din[15]}},din[15:6]} : 
       (shamt == 4'd7 ) ? {{7{din[15]}},din[15:7]} : 
       (shamt == 4'd8 ) ? {{8{din[15]}},din[15:8]} : 
       (shamt == 4'd9 ) ? {{9{din[15]}},din[15:9]} : 
       (shamt == 4'd10) ? {{10{din[15]}},din[15:10]} : 
       (shamt == 4'd11) ? {{11{din[15]}},din[15:11]} : 
       (shamt == 4'd12) ? {{12{din[15]}},din[15:12]} : 
       (shamt == 4'd13) ? {{13{din[15]}},din[15:13]} : 
       (shamt == 4'd14) ? {{14{din[15]}},din[15:14]} : 
                          {{15{din[15]}},din[15]}; 
 

///////////////////////////////////////////////////// 
// ROTATE LEFT 
///////////////////////////////////////////////////// 
 
assign rotate_left = 
       (shamt == 4'd0 ) ? din : 
       (shamt == 4'd1 ) ? {din[14:0],din[15]} : 
       (shamt == 4'd2 ) ? {din[13:0],din[15:14]} : 
       (shamt == 4'd3 ) ? {din[12:0],din[15:13]} : 
       (shamt == 4'd4 ) ? {din[11:0],din[15:12]} : 
       (shamt == 4'd5 ) ? {din[10:0],din[15:11]} : 
       (shamt == 4'd6 ) ? {din[9:0],din[15:10]} : 
       (shamt == 4'd7 ) ? {din[8:0],din[15:9]} : 
       (shamt == 4'd8 ) ? {din[7:0],din[15:8]} : 
       (shamt == 4'd9 ) ? {din[6:0],din[15:7]} : 
       (shamt == 4'd10) ? {din[5:0],din[15:6]} : 
       (shamt == 4'd11) ? {din[4:0],din[15:5]} : 
       (shamt == 4'd12) ? {din[3:0],din[15:4]} : 
       (shamt == 4'd13) ? {din[2:0],din[15:3]} : 
       (shamt == 4'd14) ? {din[1:0],din[15:2]} : 
                          {din[0],din[15:1]}; 
 
///////////////////////////////////////////////////// 
// ROTATE RIGHT 
///////////////////////////////////////////////////// 
 
assign rotate_right = 
       (shamt == 4'd0 ) ? din : 

       (shamt == 4'd1 ) ? {din[0],din[15:1]} : 
       (shamt == 4'd2 ) ? {din[1:0],din[15:2]} : 
       (shamt == 4'd3 ) ? {din[2:0],din[15:3]} : 
       (shamt == 4'd4 ) ? {din[3:0],din[15:4]} : 
       (shamt == 4'd5 ) ? {din[4:0],din[15:5]} : 
       (shamt == 4'd6 ) ? {din[5:0],din[15:6]} : 
       (shamt == 4'd7 ) ? {din[6:0],din[15:7]} : 
       (shamt == 4'd8 ) ? {din[7:0],din[15:8]} : 
       (shamt == 4'd9 ) ? {din[8:0],din[15:9]} : 
       (shamt == 4'd10) ? {din[9:0],din[15:10]} : 
       (shamt == 4'd11) ? {din[10:0],din[15:11]} : 
       (shamt == 4'd12) ? {din[11:0],din[15:12]} : 
       (shamt == 4'd13) ? {din[12:0],din[15:13]} : 
       (shamt == 4'd14) ? {din[13:0],din[15:14]} : 
                          {din[14:0],din[15]}; 
endmodule