`timescale 1ns/1ps 
 
module barrel_shifter16_behavioral 

( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift_amt, 
 
    // 000 = LSL 
    // 001 = LSR 
    // 010 = ASR 
    // 011 = ROL 
    // 100 = ROR 
    input  wire [2:0] mode, 
 
    output reg  [15:0] out 
); 
 
integer i; 
 
always @(*) 
begin 
 
    //------------------------------------------------------ 
    // Expected characteristics: 
    // Area  : Medium 
    // Delay : ~4 mux stages after synthesis 
    // Power : Lowest overall architecture 
    //------------------------------------------------------ 
 
    case(mode) 
 

    //------------------------------------------------------ 
    // LSL 
    // Area  : Low 
    // Delay : Low 
    // Power : Low 
    //------------------------------------------------------ 
    3'b000: 
    begin 
        case(shift_amt) 
            4'd0  : out = in; 
            4'd1  : out = {in[14:0],1'b0}; 
            4'd2  : out = {in[13:0],2'b00}; 
            4'd3  : out = {in[12:0],3'b000}; 
            4'd4  : out = {in[11:0],4'b0000}; 
            4'd5  : out = {in[10:0],5'b00000}; 
            4'd6  : out = {in[9:0],6'b000000}; 
            4'd7  : out = {in[8:0],7'b0000000}; 
            4'd8  : out = {in[7:0],8'h00}; 
            4'd9  : out = {in[6:0],9'h000}; 
            4'd10 : out = {in[5:0],10'h000}; 
            4'd11 : out = {in[4:0],11'h000}; 
            4'd12 : out = {in[3:0],12'h000}; 
            4'd13 : out = {in[2:0],13'h0000}; 
            4'd14 : out = {in[1:0],14'h0000}; 
            default: out = {in[0],15'h0000}; 
        endcase 
    end 
 

    //------------------------------------------------------ 
    // LSR 
    // Area  : Low 
    // Delay : Low 
    // Power : Low 
    //------------------------------------------------------ 
    3'b001: 
        out = in >> shift_amt; 
 
    //------------------------------------------------------ 
    // ASR 
    // Area  : Slightly Higher 
    // Delay : Slightly Higher 
    // Power : Medium 
    //------------------------------------------------------ 
    3'b010: 
        out = $signed(in) >>> shift_amt; 
 
    //------------------------------------------------------ 
    // ROL 
    // Area  : Medium 
    // Delay : Highest 
    // Power : Highest 
    //------------------------------------------------------ 
    3'b011: 
        out = (in << shift_amt) | 
              (in >> (16-shift_amt)); 
 

    //------------------------------------------------------ 
    // ROR 
    // Area  : Medium 
    // Delay : Highest 
    // Power : Highest 
    //------------------------------------------------------ 
    3'b100: 
        out = (in >> shift_amt) | 
              (in << (16-shift_amt)); 
 
    //------------------------------------------------------ 
    // PASS THROUGH 
    //------------------------------------------------------ 
    default: 
        out = in; 
 
    endcase 
 
end 
 
endmodule