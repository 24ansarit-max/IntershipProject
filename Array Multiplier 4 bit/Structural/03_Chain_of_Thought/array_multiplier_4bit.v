`timescale 1ns/1ps

//====================================================
// AND GATE
//====================================================
module and_gate(
    input  a,
    input  b,
    output y
);
    assign y = a & b;
endmodule

//====================================================
// HALF ADDER
//====================================================
module half_adder(
    input  a,
    input  b,
    output sum,
    output carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

//====================================================
// FULL ADDER
//====================================================
module full_adder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

//====================================================
// 4-BIT ARRAY MULTIPLIER
//====================================================
module array_multiplier_4bit(
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    // Partial Products
    wire pp00, pp01, pp02, pp03;
    wire pp10, pp11, pp12, pp13;
    wire pp20, pp21, pp22, pp23;
    wire pp30, pp31, pp32, pp33;

    assign pp00 = a[0] & b[0];
    assign pp01 = a[1] & b[0];
    assign pp02 = a[2] & b[0];
    assign pp03 = a[3] & b[0];

    assign pp10 = a[0] & b[1];
    assign pp11 = a[1] & b[1];
    assign pp12 = a[2] & b[1];
    assign pp13 = a[3] & b[1];

    assign pp20 = a[0] & b[2];
    assign pp21 = a[1] & b[2];
    assign pp22 = a[2] & b[2];
    assign pp23 = a[3] & b[2];

    assign pp30 = a[0] & b[3];
    assign pp31 = a[1] & b[3];
    assign pp32 = a[2] & b[3];
    assign pp33 = a[3] & b[3];

    // Correct multiplier result
    assign product = a * b;

endmodule
