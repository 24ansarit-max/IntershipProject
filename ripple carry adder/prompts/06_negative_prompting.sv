// =============================================================================
// PROMPT STRATEGY: NEGATIVE PROMPTING
// =============================================================================
// Write Verilog for a 4-bit ripple carry adder with testbench.
// Do NOT use the + operator in the design (testbench OK).
// Do NOT use always blocks in full_adder or top — assign only.
// Do NOT use positional port connections — named only.
// Do NOT skip intermediate carry wires — declare c1, c2, c3 explicitly.
// Do NOT write a single combined module — keep full_adder and top separate.
// Do NOT omit the cout port from the top module.
// Do NOT use implicit wire declarations — declare all wires explicitly.
// =============================================================================

`timescale 1ns/1ps
`default_nettype none

module full_adder (
    input  wire a, b, cin,
    output wire sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_carry_adder_4bit (
    input  wire [3:0] a, b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire c1, c2, c3;

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c1),  .sum(sum[1]), .cout(c2));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c2),  .sum(sum[2]), .cout(c3));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c3),  .sum(sum[3]), .cout(cout));
endmodule

module ripple_carry_adder_4bit_tb;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;
    reg  [4:0] expected;

    ripple_carry_adder_4bit dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $display("----------------------------------------------------");
        $display(" A B Cin | Sum Cout | Expected | Result");
        $display("----------------------------------------------------");

        a = 4'd0;  b = 4'd0;  cin = 1'b0; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");
        a = 4'd5;  b = 4'd3;  cin = 1'b0; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");
        a = 4'd6;  b = 4'd11; cin = 1'b0; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");
        a = 4'd15; b = 4'd1;  cin = 1'b0; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");
        a = 4'd15; b = 4'd15; cin = 1'b0; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");
        a = 4'd15; b = 4'd15; cin = 1'b1; expected = a + b + cin; #10;
        $display("%2d %2d %b | %2d %b | %2d | %s", a, b, cin, sum, cout, expected,
                 ({cout,sum} == expected) ? "PASS" : "FAIL");

        $display("----------------------------------------------------");
        $finish;
    end
endmodule

`default_nettype wire
