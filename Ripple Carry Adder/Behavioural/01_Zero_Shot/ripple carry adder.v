`timescale 1ns / 1ps 
//============================================================== 
// 16-bit Ripple Carry Adder (Behavioral Style) 
// Target FPGA : xc7a100tcsg324-2 (Artix-7 / Nexys A7) 
// 
// Features: 
// - Pure combinational logic 
// - Behavioral implementation 
// - Carry chain generated using a for loop 
// - No inferred latches 
// - No flip-flops (FF = 0) 
// - Synthesizable RTL 
//============================================================== 
 
module ripple_carry_adder_16 ( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
 
    output reg  [15:0] sum, 
    output reg         cout 
); 
 
    integer i; 
    reg [16:0] carry; 
 
    always @(*) begin 
        // Initialize carry input 

        carry = 17'b0; 
        carry[0] = cin; 
 
        // Default assignments (prevents latch inference) 
        sum  = 16'b0; 
        cout = 1'b0; 
 
        // Generate ripple carry chain 
        for (i = 0; i < 16; i = i + 1) begin 
 
            // Full Adder Equations: 
            // sum[i]      = a[i] ^ b[i] ^ carry[i] 
            // carry[i+1]  = (a[i] & b[i]) | 
            //               (a[i] & carry[i]) | 
            //               (b[i] & carry[i]) 
 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
        end 
 
        // Final carry-out 
        cout = carry[16]; 
    end 
 

endmodule