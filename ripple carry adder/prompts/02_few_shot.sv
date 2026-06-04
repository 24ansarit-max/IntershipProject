// =============================================================================
// PROMPT STRATEGY: FEW SHOT
// =============================================================================
// Here are two Verilog module examples for reference:
//
// Example 1 — Half adder:
//   module half_adder(input a, b, output sum, cout);
//     assign sum = a ^ b;
//     assign cout = a & b;
//   endmodule
//
// Example 2 — 2-to-1 MUX:
//   module mux2to1(input a, b, sel, output y);
//     assign y = sel ? b : a;
//   endmodule
//
// Following the same clean, modular style:
// 1. Write a full_adder module with inputs a, b, cin and outputs sum, cout.
// 2. Write a ripple_carry_adder_4bit module that instantiates 4 full adders.
// 3. Write a testbench: 0+0, 5+3, 6+11, 15+1, and 15+15+cin=1.
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

    full_adder FA0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder FA1(.a(a[1]), .b(b[1]), .cin(c1),  .sum(sum[1]), .cout(c2));
    full_adder FA2(.a(a[2]), .b(b[2]), .cin(c2),  .sum(sum[2]), .cout(c3));
    full_adder FA3(.a(a[3]), .b(b[3]), .cin(c3),  .sum(sum[3]), .cout(cout));
endmodule

`timescale 1ns/1ps
module tb_ripple_carry_adder_4bit;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    ripple_carry_adder_4bit DUT (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $display("Time\t a\t b\t cin\t sum\t cout");
        $monitor("%0t\t %d\t %d\t %b\t %d\t %b", $time, a, b, cin, sum, cout);

        a = 4'd0;  b = 4'd0;  cin = 1'b0; #10;
        a = 4'd5;  b = 4'd3;  cin = 1'b0; #10;
        a = 4'd6;  b = 4'd11; cin = 1'b0; #10;
        a = 4'd15; b = 4'd1;  cin = 1'b0; #10;
        a = 4'd15; b = 4'd15; cin = 1'b1; #10;

        $finish;
    end
endmodule
