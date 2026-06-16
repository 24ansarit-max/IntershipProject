`timescale 1ns/1ps 
 
//============================================================== 
// SECTION: Parameter + Port Declaration 
//============================================================== 
 
module ripple_carry_adder 
#( 
    parameter WIDTH = 16    // iter2: parameterized 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output wire [WIDTH-1:0] sum, 
    output wire             cout 
); 
 
    //========================================================== 

    // SECTION: Carry Wire Declaration 
    //========================================================== 
 
    // iter2: parameterized 
    wire [WIDTH:0] carry; 
 
    //========================================================== 
    // SECTION: cin/cout Boundary Ties 
    //========================================================== 
 
    assign carry[0] = cin; 
    assign cout     = carry[WIDTH]; 
 
    //========================================================== 
    // SECTION: generate-for Assign Block 
    //========================================================== 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_stage 
 
            // Pass 1: Functional correctness 
            assign sum[i] = 
                a[i] ^ b[i] ^ carry[i]; 
 
            // Pass 1: Functional correctness 
            assign carry[i+1] = 

                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
    endgenerate 
 
    //========================================================== 
    // Pass 3 
    // iter3: power/glitch note 
    // 
    // In the worst case, an input transition may cause the carry 
    // to ripple through all WIDTH stages before the outputs settle. 
    // 
    // This coding style is intended to allow synthesis tools to 
    // infer the dedicated Xilinx Artix-7 CARRY4 carry chain. 
    // 
    // Actual power depends on switching activity, routing, 
    // implementation, voltage, and operating conditions. 
    //========================================================== 
 
endmodule 
 
//============================================================== 
// SECTION: PPA Summary 
//============================================================== 
// 
// Device Target: 

//   xc7a100tcsg324-2 
// 
// RTL Style: 
//   Pure dataflow 
//   generate-for with genvar 
//   assign-only 
// 
// Resource Targets: 
//   FF   = 0 
//   LUT  <= 16 (implementation dependent) 
// 
// Critical Path: 
//   cin -> carry[1] -> ... -> carry[WIDTH] -> cout 
// 
// Target Goals: 
//   Fmax > 100 MHz 
//   Dynamic Power < 0.4 mW 
// 
// Notes: 
//   - No always blocks 
//   - No implicit wire declarations 
//   - Single driver for every carry bit 
//   - Parameterized by WIDTH 
//   - Carry chain is compatible with CARRY4 inference on 
//     Xilinx Artix-7 synthesis tools 
//==============================================================