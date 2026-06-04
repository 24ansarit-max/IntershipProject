// =============================================================================
// PROMPT STRATEGY: INSTRUCTION + FORMAT
// =============================================================================
// Generate Verilog for a 4-bit ripple carry adder. Structure output as:
// Section 1 — full_adder (a, b, cin -> sum, cout; assign only)
// Section 2 — ripple_carry_adder_4bit (a[3:0], b[3:0], cin; wires c1,c2,c3;
//              named port connections)
// Section 3 — testbench ripple_carry_adder_4bit_tb (`timescale, 6+ vectors,
//              overflow and cin=1, table $display, $finish)
// Do not include any explanation outside the code blocks.
// =============================================================================

module full_adder (
    input  a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_carry_adder_4bit (
    input  [3:0] a, b,
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
module ripple_carry_adder_4bit_tb;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    ripple_carry_adder_4bit DUT (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $display("-----------------------------------------------------");
        $display(" A B Cin | Sum Cout");
        $display("-----------------------------------------------------");

        a = 4'd0;  b = 4'd0;  cin = 1'b0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd5;  b = 4'd3;  cin = 1'b0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd6;  b = 4'd11; cin = 1'b0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd9;  b = 4'd4;  cin = 1'b0; #10;
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd15; b = 4'd1;  cin = 1'b0; #10; // Overflow
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);
        a = 4'd15; b = 4'd15; cin = 1'b1; #10; // Overflow + Cin
        $display("%4d %4d %b | %4d %b", a, b, cin, sum, cout);

        $display("-----------------------------------------------------");
        $finish;
    end
endmodule
