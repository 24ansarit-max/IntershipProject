`timescale 1ns/1ps 
 
//=====================================================================
= 
// ITERATION 1: 
// 16-bit Ripple Carry Adder (Dataflow) 
// - generate-for with genvar 
// - assign-only implementation 
//=====================================================================
= 
 
module ripple_carry_adder 
#( 
    parameter WIDTH = 16      // iter3: parameterized 
) 
( 
    input  wire [WIDTH-1:0] a,    // iter3: parameterized 
    input  wire [WIDTH-1:0] b,    // iter3: parameterized 
    input  wire             cin, 
 
    output wire [WIDTH-1:0] sum,  // iter3: parameterized 
    output wire             cout 
); 
 
    // iter3: parameterized 
    wire [WIDTH:0] carry; 
 
    // Boundary condition 

    assign carry[0] = cin; 
 
    // iter3: parameterized 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : rca_stage 
 
            //========================================================== 
            // ITERATION 2 - Equation review 
            //========================================================== 
 
            // iter2: simplified 
            // 3-input XOR implementation 
            assign sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            // iter2: simplified 
            // Majority function: 
            // (a&b) | (a&carry) | (b&carry) 
            assign carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    // Final carry-out 

    assign cout = carry[WIDTH]; 
 
    //============================================================== 
    // ITERATION 4 - Power / Glitch Note 
    //============================================================== 
    // 
    // iter4: power/glitch note 
    // 
    // A ripple-carry adder can exhibit worst-case transient 
    // switching when a carry propagates through all WIDTH stages 
    // during certain input transitions. 
    // 
    // This RTL is intentionally written in a carry-chain-friendly 
    // form so synthesis tools can infer dedicated FPGA carry 
    // resources. Actual dynamic power depends on implementation, 
    // routing, voltage, activity factor, and operating conditions. 
    // 
    // Target design intent: 
    //   - FF = 0 
    //   - Fmax > 100 MHz 
    //   - LUT <= 16 (implementation dependent) 
    //   - Dynamic power target < 0.4 mW at the specified 
    //     operating conditions 
    // 
    //============================================================== 
 
endmodule