`timescale 1ns / 1ps
//============================================================
// Module Name : mag_comp16
// Description : 16-bit Unsigned Magnitude Comparator
// Target : Nexys A7 (xc7a100tcsg324-2)
// Tool : Vivado 2023.x
//
// Outputs:
// A_gt_B = 1 when A > B
// A_lt_B = 1 when A < B
// A_eq_B = 1 when A == B
//
// Coding Style:
// Behavioral Verilog using a single combinational always block
//============================================================
module mag_comp16 (
    input [15:0] A, // First 16-bit unsigned input
    input [15:0] B, // Second 16-bit unsigned input
    // Outputs are declared as reg because they are assigned
    // inside an always block. This does NOT imply flip-flops.
    output reg A_gt_B,
    output reg A_lt_B,
    output reg A_eq_B
);
    //--------------------------------------------------------------------------
    // Combinational Logic Block
    //
    // always @(*) automatically includes every signal read inside the block
    // in the sensitivity list. This prevents simulation mismatches caused by
    // forgetting to add signals manually.
    //
    // A magnitude comparator is purely combinational:
    // outputs depend only on the current values of A and B.
    // Therefore always @(*) is the correct choice.
    //--------------------------------------------------------------------------
    always @(*) begin
        //----------------------------------------------------------------------
        // Case 1 : A is greater than B
        //
        // All three outputs are assigned.
        // This guarantees no storage elements are inferred.
        //----------------------------------------------------------------------
        if (A > B) begin
            A_gt_B = 1'b1;
            A_lt_B = 1'b0;
            A_eq_B = 1'b0;
        end
        //----------------------------------------------------------------------
        // Case 2 : A is less than B
        //
        // Again, all outputs are assigned explicit values.
        //----------------------------------------------------------------------
        else if (A < B) begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b1;
            A_eq_B = 1'b0;
        end
        //----------------------------------------------------------------------
        // Case 3 : A equals B
        //
        // All outputs are assigned here as well.
        //----------------------------------------------------------------------
        else begin
            A_gt_B = 1'b0;
            A_lt_B = 1'b0;
            A_eq_B = 1'b1;
        end
        //----------------------------------------------------------------------
        // Why assign all outputs in every branch?
        //
        // If even one output were left unassigned in a branch, the synthesis
        // tool would need to preserve its previous value.
        //
        // Example (BAD):
        //
        // if (A > B)
        // A_gt_B = 1'b1;
        //
        // In all other cases A_gt_B would retain its old value, causing
        // Vivado to infer a latch.
        //
        // Latches are generally undesirable in FPGA combinational logic and
        // often generate synthesis warnings.
        //
        // By assigning every output in every branch, the logic remains purely
        // combinational and no latches are inferred.
        //----------------------------------------------------------------------
    end
endmodule
