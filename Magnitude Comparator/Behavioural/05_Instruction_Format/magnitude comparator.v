`timescale 1ns / 1ps
//============================================================
// 16-bit Magnitude Comparator
// Target FPGA : Nexys A7 (Artix-7 xc7a100tcsg324-2)
// Tool : Vivado 2023.x
// Modeling : Behavioral
//============================================================
module mag_comp16 (
    input [15:0] A,
    input [15:0] B,
    output reg A_gt_B,
    output reg A_lt_B,
    output reg A_eq_B
);
    always @(*) begin
        if (A > B) begin
            A_gt_B = 1'b1;
            A_lt_B = 1'b0;
            A_eq_B = 1'b0;
        end
        else if (A < B) begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b1;
            A_eq_B = 1'b0;
        end
        else begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b0;
            A_eq_B = 1'b1;
        end
    end
endmodule
