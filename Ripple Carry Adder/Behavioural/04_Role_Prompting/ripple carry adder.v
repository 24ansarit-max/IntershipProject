`timescale 1ns/1ps 

//=====================================================================
= 
// 16-bit Ripple Carry Adder (Behavioral RTL) 
// Target Device : xc7a100tcsg324-2 (Artix-7) 
// 
// Features: 
//   - Pure combinational implementation 
//   - Behavioral coding style 
//   - for-loop inside always @(*) 
//   - No inferred latches 
//   - No flip-flops (FF = 0) 
// 
// Vivado Notes: 
//   * The for-loop is an RTL description convenience only. 
//     Synthesis unrolls it into 16 combinational stages. 
//   * Vivado typically infers dedicated CARRY4 resources 
//     automatically for arithmetic carry propagation. 
//   * A 16-bit ripple carry path generally maps across 
//     four CARRY4 blocks. 
// 
// Timing Notes: 
//   * Critical path is the carry propagation chain. 
//   * Longest logical path: 
//         carry[0] -> ... -> carry[15] -> carry[16] 
//     with the final carry generation occurring at bit 15. 
// 
//=====================================================================
= 
 

module ripple_carry_adder_16 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output reg  [15:0] sum, 
    output reg         cout 
); 
 
    // Internal carry chain 
    reg [16:0] carry; 
 
    integer i; 
 
    // ----------------------------------------------------------------- 
    // Pure combinational logic 
    // ----------------------------------------------------------------- 
    always @(*) begin 
 
        // Fully initialize outputs to prevent latch inference 
        sum   = 16'b0; 
        cout  = 1'b0; 
        carry = 17'b0; 
 
        // Initial carry input 
        carry[0] = cin; 
 

        // 16 ripple-carry stages 
        // 
        // Synthesis expands this loop into 16 full-adder stages. 
        for (i = 0; i < 16; i = i + 1) begin 
 
            // Full-adder SUM 
            // 
            // sum[i] = a[i] ^ b[i] ^ carry[i] 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            // Full-adder CARRY 
            // 
            // carry[i+1] = 
            //      (a[i] & b[i]) 
            //    | (a[i] & carry[i]) 
            //    | (b[i] & carry[i]) 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
            // Bit 15 produces the final carry[16] and lies on the 
            // longest ripple-carry timing path. 
        end 
 
        // Final carry output 
        cout = carry[16]; 
 

    end 
 
endmodule 
 
//=====================================================================
= 
// Optional registered output stage (not instantiated) 
// 
// Uncomment and instantiate separately if pipelining is desired. 
// This version would add 17 FFs (16 sum + 1 cout). 
//=====================================================================
= 
/* 
module rca16_output_register 
( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] sum_in, 
    input  wire        cout_in, 
 
    output reg  [15:0] sum_out, 
    output reg         cout_out 
); 
 
always @(posedge clk) begin 
    if (rst) begin 
        sum_out  <= 16'b0; 
        cout_out <= 1'b0; 
    end 

    else begin 
        sum_out  <= sum_in; 
        cout_out <= cout_in; 
    end 
end 
 
endmodule 
*/