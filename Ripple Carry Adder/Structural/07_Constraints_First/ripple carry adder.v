`timescale 1ns/1ps

module full_adder(
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

    assign sum  = a ^ b ^ cin;

    assign cout = (a & b) |
                  (a & cin) |
                  (b & cin);

endmodule


module rca16(
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
        for(i=0;i<16;i=i+1)
        begin : stage

            full_adder fa_inst(
                .a   (a[i]),
                .b   (b[i]),
                .cin (carry[i]),
                .sum (sum[i]),
                .cout(carry[i+1])
            );

        end
    endgenerate

    assign cout = carry[16];

endmodule
