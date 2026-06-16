`timescale 1ns/1ps 
 
module barrel_shifter16_behav ( 
    input  wire [15:0] in, 
    input  wire [3:0]  shift, 
    output reg  [15:0] out 
); 
 
always @(*) begin 
 
    // Default to avoid latches (critical for verification correctness) 
    out = 16'h0000; 
 
    case (shift) 
 
        4'b0000: begin 
            out = in; 
            // No shift: out = in 
        end 
 
        4'b0001: begin 
            out = {in[14:0], 1'b0}; 
            // Shift left by 1 
        end 

 
        4'b0010: begin 
            out = {in[13:0], 2'b00}; 
            // Shift left by 2 
        end 
 
        4'b0011: begin 
            out = {in[12:0], 3'b000}; 
            // Shift left by 3 
        end 
 
        4'b0100: begin 
            out = {in[11:0], 4'b0000}; 
            // Shift left by 4 
        end 
 
        4'b0101: begin 
            out = {in[10:0], 5'b00000}; 
            // Shift left by 5 
        end 
 
        4'b0110: begin 
            out = {in[9:0], 6'b000000}; 
            // Shift left by 6 
        end 
 
        4'b0111: begin 
            out = {in[8:0], 7'b0000000}; 

            // Shift left by 7 
        end 
 
        4'b1000: begin 
            out = {in[7:0], 8'b00000000}; 
            // Shift left by 8 
        end 
 
        4'b1001: begin 
            out = {in[6:0], 9'b000000000}; 
            // Shift left by 9 
        end 
 
        4'b1010: begin 
            out = {in[5:0], 10'b0000000000}; 
            // Shift left by 10 
        end 
 
        4'b1011: begin 
            out = {in[4:0], 11'b00000000000}; 
            // Shift left by 11 
        end 
 
        4'b1100: begin 
            out = {in[3:0], 12'b000000000000}; 
            // Shift left by 12 
        end 
 

        4'b1101: begin 
            out = {in[2:0], 13'b0000000000000}; 
            // Shift left by 13 
        end 
 
        4'b1110: begin 
            out = {in[1:0], 14'b00000000000000}; 
            // Shift left by 14 
        end 
 
        4'b1111: begin 
            out = {in[0], 15'b000000000000000}; 
            // Shift left by 15 
        end 
 
        default: begin 
            out = 16'h0000; 
            // Safe fallback — no latch inference 
        end 
 
    endcase 
end 
 
endmodule