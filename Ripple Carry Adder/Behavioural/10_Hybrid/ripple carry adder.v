`timescale 1ns/1ps 
 
//===================================================================== 
// 16-bit Ripple Carry Adder (Behavioral) 
// Target : xc7a100tcsg324-2 
//===================================================================== 
 
module ripple_carry_adder 
#( 

    //============================================================= 
    // PARAMETER 
    //============================================================= 
    parameter WIDTH = 16 
) 
( 
    //============================================================= 
    // PORTS 
    //============================================================= 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output reg  [WIDTH-1:0] sum, 
    output reg              cout 
); 
 
    //============================================================= 
    // INTERNAL_SIGNALS 
    //============================================================= 
 
    reg [WIDTH:0] carry; 
 
    integer i; 
 
    //============================================================= 
    // FOR_LOOP_BLOCK 
    //============================================================= 

 
    always @(*) begin 
 
        // Initialize combinational outputs 
        sum   = {WIDTH{1'b0}}; 
        cout  = 1'b0; 
        carry = {(WIDTH+1){1'b0}}; 
 
        // Initial carry 
        carry[0] = cin; 
 
        // Ripple carry chain 
        for (i = 0; i < WIDTH; i = i + 1) begin 
 
            // Full-adder sum equation 
            sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // Full-adder carry equation 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
        // Final carry-out 
        cout = carry[WIDTH]; 

 
    end 
 
    //============================================================= 
    // OPTIONAL REGISTER STAGE 
    // 
    // Not included. 
    // Pure combinational implementation. 
    // FF = 0. 
    //============================================================= 
 
endmodule 
 
 
//===================================================================== 
// ITERATIVE PASS 
//===================================================================== 
// 
// Pass 1 : Latch Check 
// --------------------------------- 
// ✓ sum initialized 
// ✓ cout initialized 
// ✓ carry initialized 
// ✓ carry[0] assigned 
// ✓ sum[i] assigned every loop iteration 
// ✓ carry[i+1] assigned every loop iteration 
// ✓ cout assigned before exit 
// ✓ No inferred latches 

// 
// 
// Pass 2 : Parameterization 
// --------------------------------- 
// ✓ WIDTH parameter used 
// ✓ Port widths use WIDTH 
// ✓ carry declared as [WIDTH:0] 
// ✓ Loop bound uses WIDTH 
// ✓ cout uses carry[WIDTH] 
// 
// 
// Pass 3 : CARRY4 Inference Note 
// --------------------------------- 
// This behavioral ripple-carry coding style is compatible with 
// inference of dedicated Xilinx Artix-7 carry-chain resources. 
// For WIDTH=16, synthesis tools commonly map the carry path 
// across four CARRY4 primitives. 
// 
//===================================================================== 
 
 
//===================================================================== 
// PPA SUMMARY 
//===================================================================== 
// 
// Target Device : xc7a100tcsg324-2 
// 
// Design Style  : Behavioral (for-loop) 

// FF            : 0 
// 
// Critical Path : 
//      cin -> carry[1] -> ... -> carry[WIDTH] -> cout 
// 
// Target Goals: 
//      Fmax  > 100 MHz 
//      LUT   <= 18 
//      Dynamic Power < 0.5 mW 
// 
// Exact timing, LUT count, and power depend on synthesis, 
// placement, routing, and operating conditions. 
//=====================================================================