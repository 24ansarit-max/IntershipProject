// =============================================================================
// PROMPT STRATEGY: CHAIN OF THOUGHT
// =============================================================================
// Build a 4-bit ripple carry adder step by step:
// Step 1: Define the full adder (inputs, outputs, Boolean expressions).
// Step 2: Identify how many full adders and how carries connect.
// Step 3: Define top-level ports (a[3:0], b[3:0], cin, sum[3:0], cout).
// Step 4: Declare internal carry wires between stages.
// Step 5: Instantiate and connect all 4 full adders.
// Step 6: Write a testbench with named display output per test case.
// Now write the complete, synthesizable Verilog code following these steps.
// =============================================================================

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

module ripple_carry_adder_4bit(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);
    wire c1, c2, c3;

    full_adder FA0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder FA1 (.a(a[1]), .b(b[1]), .cin(c1),  .sum(sum[1]), .cout(c2));
    full_adder FA2 (.a(a[2]), .b(b[2]), .cin(c2),  .sum(sum[2]), .cout(c3));
    full_adder FA3 (.a(a[3]), .b(b[3]), .cin(c3),  .sum(sum[3]), .cout(cout));
endmodule

`timescale 1ns/1ps
module tb_ripple_carry_adder_4bit;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    ripple_carry_adder_4bit DUT (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $display("------------------------------------------------");
        $display(" a b cin | sum cout");
        $display("------------------------------------------------");

        a = 4'd0;  b = 4'd0;  cin = 0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd5;  b = 4'd3;  cin = 0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd6;  b = 4'd11; cin = 0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd15; b = 4'd1;  cin = 0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd15; b = 4'd15; cin = 1; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);

        $display("------------------------------------------------");
        $finish;
    end
endmodule
