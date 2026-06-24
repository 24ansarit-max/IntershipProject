`timescale 1ns/1ps

//=====================================================================
// 16-bit Ripple Carry Adder
// Style  : Dataflow (generate-for + assign only)
// Target : xc7a100tcsg324-2 (Artix-7)
//=====================================================================

module ripple_carry_adder_16
(
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,

    output wire [15:0] sum,
    output wire        cout
);

    wire [16:0] carry;

    assign carry[0] = cin;

    genvar i;

    generate
        for (i = 0; i < 16; i = i + 1) begin : carry_stage

            assign sum[i] =
                a[i] ^ b[i] ^ carry[i];

            assign carry[i+1] =
                (a[i] & b[i]) |
                (a[i] & carry[i]) |
                (b[i] & carry[i]);

        end
    endgenerate

    assign cout = carry[16];

endmodule
