// =============================================================================
// PROMPT STRATEGY: ROLE PROMPTING
// =============================================================================
// You are a senior VLSI design engineer with 15 years of experience writing
// synthesizable RTL in Verilog. You follow industry best practices: named port
// connections, no implicit nets, clear signal naming, and always include a
// testbench.
//
// Write a 4-bit ripple carry adder with:
// - A reusable full_adder primitive module
// - A structural ripple_carry_adder_4bit top module using named port instantiation
// - Wire declarations for intermediate carries
// - A self-checking testbench that uses $display to print PASS/FAIL for each vector
// =============================================================================

`timescale 1ns/1ps
`default_nettype none

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module ripple_carry_adder_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire carry_1, carry_2, carry_3;

    full_adder u_fa0 (.a(a[0]), .b(b[0]), .cin(cin),     .sum(sum[0]), .cout(carry_1));
    full_adder u_fa1 (.a(a[1]), .b(b[1]), .cin(carry_1), .sum(sum[1]), .cout(carry_2));
    full_adder u_fa2 (.a(a[2]), .b(b[2]), .cin(carry_2), .sum(sum[2]), .cout(carry_3));
    full_adder u_fa3 (.a(a[3]), .b(b[3]), .cin(carry_3), .sum(sum[3]), .cout(cout));
endmodule

module tb_ripple_carry_adder_4bit;
    reg  [3:0] tb_a, tb_b;
    reg        tb_cin;
    wire [3:0] tb_sum;
    wire       tb_cout;
    reg  [4:0] expected_result;

    ripple_carry_adder_4bit dut (
        .a(tb_a), .b(tb_b), .cin(tb_cin), .sum(tb_sum), .cout(tb_cout)
    );

    task run_test;
        input [3:0] a;
        input [3:0] b;
        input       cin;
        begin
            tb_a = a; tb_b = b; tb_cin = cin;
            #1;
            expected_result = a + b + cin;
            if ({tb_cout, tb_sum} === expected_result)
                $display("PASS : A=%0d B=%0d Cin=%0d --> Sum=%0d Cout=%0d",
                         a, b, cin, tb_sum, tb_cout);
            else
                $display("FAIL : A=%0d B=%0d Cin=%0d --> Expected={Cout=%0d Sum=%0d}, Got={Cout=%0d Sum=%0d}",
                         a, b, cin, expected_result[4], expected_result[3:0], tb_cout, tb_sum);
        end
    endtask

    initial begin
        $display("==============================================");
        $display(" 4-Bit Ripple Carry Adder Verification");
        $display("==============================================");
        run_test(4'd0,  4'd0,  1'b0);
        run_test(4'd5,  4'd3,  1'b0);
        run_test(4'd6,  4'd11, 1'b0);
        run_test(4'd15, 4'd1,  1'b0);
        run_test(4'd15, 4'd15, 1'b1);
        $display("==============================================");
        $finish;
    end
endmodule

`default_nettype wire
