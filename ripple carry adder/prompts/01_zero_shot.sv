// =============================================================================
// PROMPT STRATEGY: ZERO SHOT
// =============================================================================
// Write Verilog code for a 4-bit ripple carry adder.
// Add a testbench that verifies at least 5 cases including overflow.
// =============================================================================

// Full Adder Module
module full_adder(
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// 4-bit Ripple Carry Adder
module ripple_carry_adder_4bit(
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);
    wire c1, c2, c3;

    full_adder FA0(A[0], B[0], Cin, Sum[0], c1);
    full_adder FA1(A[1], B[1], c1,  Sum[1], c2);
    full_adder FA2(A[2], B[2], c2,  Sum[2], c3);
    full_adder FA3(A[3], B[3], c3,  Sum[3], Cout);
endmodule

// Testbench
`timescale 1ns/1ps
module tb_ripple_carry_adder_4bit;
    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] Sum;
    wire       Cout;

    ripple_carry_adder_4bit DUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        $display("Time\tA\tB\tCin\tSum\tCout");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b", $time, A, B, Cin, Sum, Cout);

        // Test Case 1: 0 + 0
        A = 4'b0000; B = 4'b0000; Cin = 0;
        #10;
        // Test Case 2: 5 + 3 = 8
        A = 4'b0101; B = 4'b0011; Cin = 0;
        #10;
        // Test Case 3: 9 + 6 = 15
        A = 4'b1001; B = 4'b0110; Cin = 0;
        #10;
        // Test Case 4: 7 + 8 + Cin = 16 (overflow)
        A = 4'b0111; B = 4'b1000; Cin = 1;
        #10;
        // Test Case 5: 15 + 15 = 30 (overflow)
        A = 4'b1111; B = 4'b1111; Cin = 0;
        #10;

        $finish;
    end
endmodule
