`timescale 1ns/1ps 
 
//=====================================================================
= 
// 1. MODULE HEADER 
// 
// Module : ripple_carry_adder_16 
// Author : ChatGPT 
// Target : xc7a100tcsg324-2 (Nexys A7 / Artix-7) 
// Style  : Behavioral RTL (always @(*) + for loop) 
// 
// PPA Budget (Design Intent) 
//   - Fmax Target : > 100 MHz 
//   - LUT Budget  : <= 16 (tool/device dependent) 
//   - FF Budget   : 0 (17 only if optional output register is used) 
//   - Dynamic Power Target : < 0.5 mW (depends on activity/routing) 
//=====================================================================
= 
 
module ripple_carry_adder_16 
( 
    //================================================================== 
    // 2. PORT DECLARATION 
    //================================================================== 
 
    // 16-bit operand A 

    input  wire [15:0] a, 
 
    // 16-bit operand B 
    input  wire [15:0] b, 
 
    // Carry input 
    input  wire        cin, 
 
    // 16-bit sum output 
    output reg  [15:0] sum, 
 
    // Carry output 
    output reg         cout 
); 
 
    //================================================================== 
    // 3. INTERNAL SIGNALS 
    //================================================================== 
 
    // 17-bit carry chain: 
    // carry[0]  = cin 
    // carry[16] = final carry-out 
    reg [16:0] carry; 
 
    // Loop index 
    integer i; 
 
    //================================================================== 

    // 4. COMBINATIONAL FOR-LOOP BLOCK 
    //================================================================== 
    // 
    // Pure combinational logic. 
    // No latches: 
    //   - carry initialized 
    //   - sum initialized 
    //   - cout initialized 
    //   - every loop iteration assigns sum[i] and carry[i+1] 
    // 
    // Critical timing path: 
    //   cin -> carry[0] -> ... -> carry[16] -> cout 
    // 
    //================================================================== 
 
    always @(*) begin 
 
        // Default assignments 
        sum   = 16'b0; 
        cout  = 1'b0; 
        carry = 17'b0; 
 
        // Initial carry 
        carry[0] = cin; 
 
        // 16 ripple-carry stages 
        for (i = 0; i < 16; i = i + 1) begin 
 

            // Full-adder sum 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            // Full-adder carry 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
        // Final carry output 
        cout = carry[16]; 
 
    end 
 
    //================================================================== 
    // 5. OPTIONAL REGISTERED OUTPUT BLOCK 
    //================================================================== 
    // 
    // Example only. 
    // Not active in this module because clk/rst ports are omitted. 
    // 
    // To use: 
    //   - add clk and rst to the module ports 
    //   - declare: 
    //         reg [15:0] sum_reg; 
    //         reg        cout_reg; 

    // 
    // always @(posedge clk) begin 
    //     if (rst) begin 
    //         sum_reg  <= 16'b0; 
    //         cout_reg <= 1'b0; 
    //     end 
    //     else begin 
    //         sum_reg  <= sum; 
    //         cout_reg <= cout; 
    //     end 
    // end 
    // 
    //================================================================== 
 
    //================================================================== 
    // 6. SYNTHESIS ATTRIBUTES (Comments) 
    //================================================================== 
    // 
    // Vivado typically recognizes this arithmetic pattern and 
    // infers dedicated Artix-7 CARRY4 carry-chain resources. 
    // 
    // 16-bit ripple carry: 
    //     4 x CARRY4 blocks 
    // 
    // The for-loop is an RTL description only and is unrolled 
    // during synthesis into combinational hardware. 
    // 
    //================================================================== 

 
    //================================================================== 
    // 7. PPA SUMMARY (Design Intent) 
    //================================================================== 
    // 
    // LUT   = <=16 target (implementation dependent) 
    // FF    = 0 
    // Fmax  = >100 MHz target 
    // Power = <0.5 mW dynamic target (activity dependent) 
    // 
    // Critical Path: 
    //     cin --> carry chain --> cout 
    // 
    // Ripple-carry structures may exhibit internal switching 
    // activity during carry propagation; actual dynamic power 
    // depends on input activity, routing, voltage, and timing. 
    // 
    //================================================================== 
 
endmodule