`timescale 1ns/1ps 
 
//------------------------------------------------------------ 
// 16-bit Behavioral Barrel Shifter 
// 
// opcode: 
// 3'b000 : Logical Left Shift 
// 3'b001 : Logical Right Shift 
// 3'b010 : Arithmetic Right Shift 
// 3'b011 : Rotate Left 
// 3'b100 : Rotate Right 
//------------------------------------------------------------ 
 
module barrel_shifter16_behavioral 
( 
    input  wire [15:0] din, 
    input  wire [3:0]  shamt, 
    input  wire [2:0]  opcode, 
    output reg  [15:0] dout 
); 
 
always @(*) 
begin 
    dout = 16'h0000; 
 
    case(opcode) 
 
    //-------------------------------------------------------- 

    // Logical Left Shift 
    //-------------------------------------------------------- 
    3'b000: 
    begin 
        case(shamt) 
            4'd0 : dout = din; 
            4'd1 : dout = {din[14:0],1'b0}; 
            4'd2 : dout = {din[13:0],2'b00}; 
            4'd3 : dout = {din[12:0],3'b000}; 
            4'd4 : dout = {din[11:0],4'b0000}; 
            4'd5 : dout = {din[10:0],5'b00000}; 
            4'd6 : dout = {din[9:0],6'b000000}; 
            4'd7 : dout = {din[8:0],7'b0000000}; 
            4'd8 : dout = {din[7:0],8'h00}; 
            4'd9 : dout = {din[6:0],9'h000}; 
            4'd10: dout = {din[5:0],10'h000}; 
            4'd11: dout = {din[4:0],11'h000}; 
            4'd12: dout = {din[3:0],12'h000}; 
            4'd13: dout = {din[2:0],13'h0000}; 
            4'd14: dout = {din[1:0],14'h0000}; 
            4'd15: dout = {din[0],15'h0000}; 
        endcase 
    end 
 
    //-------------------------------------------------------- 
    // Logical Right Shift 
    //-------------------------------------------------------- 
    3'b001: 

    begin 
        case(shamt) 
            4'd0 : dout = din; 
            4'd1 : dout = {1'b0,din[15:1]}; 
            4'd2 : dout = {2'b00,din[15:2]}; 
            4'd3 : dout = {3'b000,din[15:3]}; 
            4'd4 : dout = {4'b0000,din[15:4]}; 
            4'd5 : dout = {5'b00000,din[15:5]}; 
            4'd6 : dout = {6'b000000,din[15:6]}; 
            4'd7 : dout = {7'b0000000,din[15:7]}; 
            4'd8 : dout = {8'h00,din[15:8]}; 
            4'd9 : dout = {9'h000,din[15:9]}; 
            4'd10: dout = {10'h000,din[15:10]}; 
            4'd11: dout = {11'h000,din[15:11]}; 
            4'd12: dout = {12'h000,din[15:12]}; 
            4'd13: dout = {13'h0000,din[15:13]}; 
            4'd14: dout = {14'h0000,din[15:14]}; 
            4'd15: dout = {15'h0000,din[15]}; 
        endcase 
    end 
 
    //-------------------------------------------------------- 
    // Arithmetic Right Shift 
    //-------------------------------------------------------- 
    3'b010: 
    begin 
        case(shamt) 
            4'd0 : dout = din; 

            4'd1 : dout = {{1{din[15]}},din[15:1]}; 
            4'd2 : dout = {{2{din[15]}},din[15:2]}; 
            4'd3 : dout = {{3{din[15]}},din[15:3]}; 
            4'd4 : dout = {{4{din[15]}},din[15:4]}; 
            4'd5 : dout = {{5{din[15]}},din[15:5]}; 
            4'd6 : dout = {{6{din[15]}},din[15:6]}; 
            4'd7 : dout = {{7{din[15]}},din[15:7]}; 
            4'd8 : dout = {{8{din[15]}},din[15:8]}; 
            4'd9 : dout = {{9{din[15]}},din[15:9]}; 
            4'd10: dout = {{10{din[15]}},din[15:10]}; 
            4'd11: dout = {{11{din[15]}},din[15:11]}; 
            4'd12: dout = {{12{din[15]}},din[15:12]}; 
            4'd13: dout = {{13{din[15]}},din[15:13]}; 
            4'd14: dout = {{14{din[15]}},din[15:14]}; 
            4'd15: dout = {{15{din[15]}},din[15]}; 
        endcase 
    end 
 
    //-------------------------------------------------------- 
    // Rotate Left 
    //-------------------------------------------------------- 
    3'b011: 
    begin 
        case(shamt) 
            4'd0 : dout = din; 
            4'd1 : dout = {din[14:0],din[15]}; 
            4'd2 : dout = {din[13:0],din[15:14]}; 
            4'd3 : dout = {din[12:0],din[15:13]}; 

            4'd4 : dout = {din[11:0],din[15:12]}; 
            4'd5 : dout = {din[10:0],din[15:11]}; 
            4'd6 : dout = {din[9:0],din[15:10]}; 
            4'd7 : dout = {din[8:0],din[15:9]}; 
            4'd8 : dout = {din[7:0],din[15:8]}; 
            4'd9 : dout = {din[6:0],din[15:7]}; 
            4'd10: dout = {din[5:0],din[15:6]}; 
            4'd11: dout = {din[4:0],din[15:5]}; 
            4'd12: dout = {din[3:0],din[15:4]}; 
            4'd13: dout = {din[2:0],din[15:3]}; 
            4'd14: dout = {din[1:0],din[15:2]}; 
            4'd15: dout = {din[0],din[15:1]}; 
        endcase 
    end 
 
    //-------------------------------------------------------- 
    // Rotate Right 
    //-------------------------------------------------------- 
    3'b100: 
    begin 
        case(shamt) 
            4'd0 : dout = din; 
            4'd1 : dout = {din[0],din[15:1]}; 
            4'd2 : dout = {din[1:0],din[15:2]}; 
            4'd3 : dout = {din[2:0],din[15:3]}; 
            4'd4 : dout = {din[3:0],din[15:4]}; 
            4'd5 : dout = {din[4:0],din[15:5]}; 
            4'd6 : dout = {din[5:0],din[15:6]}; 

            4'd7 : dout = {din[6:0],din[15:7]}; 
            4'd8 : dout = {din[7:0],din[15:8]}; 
            4'd9 : dout = {din[8:0],din[15:9]}; 
            4'd10: dout = {din[9:0],din[15:10]}; 
            4'd11: dout = {din[10:0],din[15:11]}; 
            4'd12: dout = {din[11:0],din[15:12]}; 
            4'd13: dout = {din[12:0],din[15:13]}; 
            4'd14: dout = {din[13:0],din[15:14]}; 
            4'd15: dout = {din[14:0],din[15]}; 
        endcase 
    end 
 
    default: 
        dout = 16'h0000; 
 
    endcase 
end 
 
endmodule