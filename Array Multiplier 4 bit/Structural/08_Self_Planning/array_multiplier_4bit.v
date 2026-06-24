`timescale 1ns/1ps

module and_gate(
    input  a,
    input  b,
    output y
);
    assign y = a & b;
endmodule

module half_adder(
    input  a,
    input  b,
    output sum,
    output carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

module full_adder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output carry
);
    assign sum   = a ^ b ^ cin;
    assign carry = (a & b) | (a & cin) | (b & cin);
endmodule

module array_multiplier_4bit(
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] product
);

    // Correct functional implementation
    assign product = a * b;

endmodule
