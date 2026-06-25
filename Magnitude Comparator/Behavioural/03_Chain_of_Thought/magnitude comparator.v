`timescale 1ns / 1ps
//======================================================
// 16-bit Magnitude Comparator
// Target FPGA : Nexys A7 (Artix-7 xc7a100tcsg324-2)
// Tool : Vivado 2023.x
// Style : Behavioral
//======================================================
module mag_comp16 (
    input [15:0] A, // First 16-bit unsigned input
    input [15:0] B, // Second 16-bit unsigned input
    output reg A_gt_B, // High when A > B
    output reg A_lt_B, // High when A < B
    output reg A_eq_B // High when A == B
);
    // Combinational comparison logic
    always @(*) begin
        // Case 1: A is greater than B
        if (A > B) begin
            A_gt_B = 1'b1;
            A_lt_B = 1'b0;
            A_eq_B = 1'b0;
        end
        // Case 2: A is less than B
        else if (A < B) begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b1;
            A_eq_B = 1'b0;
        end
        // Case 3: A equals B
        else begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b0;
            A_eq_B = 1'b1;
        end
    end
endmodule
