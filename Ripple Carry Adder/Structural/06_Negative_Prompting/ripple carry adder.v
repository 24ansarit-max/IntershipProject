`timescale 1ns/1ps 
 
//============================================================== 
// 1-Bit Full Adder 
//============================================================== 
module full_adder 
( 
    input  wire a, 

    input  wire b, 
    input  wire cin, 
    output wire sum, 
    output wire cout 
); 
 
    // Combinational dataflow implementation 
    assign sum  = a ^ b ^ cin; 
    assign cout = (a & b) | 
                  (a & cin) | 
                  (b & cin); 
 
endmodule 
 
 
//============================================================== 
// 16-Bit Ripple Carry Adder (Structural) 
// Target : xc7a100tcsg324-2 
// 
// - Pure combinational 
// - FF = 0 
// - 16 full_adder instances generated with generate-for 
// - Named port connections only 
// - 17-bit carry chain 
//============================================================== 
module rca16 
( 
    input  wire [15:0] a, 

    input  wire [15:0] b, 
    input  wire        cin, 
    output wire [15:0] sum, 
    output wire        cout 
); 
 
    // 17-bit carry chain 
    wire [16:0] carry; 
 
    genvar i; 
 
    generate 
        begin : fa_gen 
 
            // Drive initial carry 
            assign carry[0] = cin; 
 
            // Generate 16 ripple-carry stages 
            for (i = 0; i < 16; i = i + 1) begin : stage 
 
                full_adder fa_inst 
                ( 
                    .a   (a[i]), 
                    .b   (b[i]), 
                    .cin (carry[i]), 
                    .sum (sum[i]), 
                    .cout(carry[i+1]) 
                ); 

 
            end 
 
            // Drive final carry-out 
            assign cout = carry[16]; 
 
        end 
    endgenerate 
 
endmodule