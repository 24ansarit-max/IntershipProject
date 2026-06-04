// =============================================================================
// PROMPT STRATEGY: CONSTRAINTS FIRST
// =============================================================================
// Satisfy ALL constraints before writing Verilog:
// [AREA] Total gate count <= 50; each FA <= 12 gates (2 XOR + 2 AND + 1 OR)
// [POWER] Dynamic power <= 0.5 mW @ 1.8V, 100 MHz; use assign, minimize switching
// [TIMING] Critical path <= 8 gate delays (2 per FA x 4 stages); no extra carry logic
//
// Design task: 4-bit ripple carry adder. Response order:
// 1. Constraint acknowledgment  2. full_adder (gate count in comments)
// 3. ripple_carry_adder_4bit  4. Timing annotation  5. Power note  6. Area summary
// 7. Testbench: 0+0, 5+3, 6+11(overflow), 15+15+cin=1, 7+8
// =============================================================================

// Gate Count per FA: XOR=2, AND=2, OR=1 => 5 gates; x4 = 20 gates total (< 50)

module full_adder (
    input  wire a, b, cin,
    output wire sum, cout
);
    wire xor_ab, and_ab, and_xor_cin;

    assign xor_ab       = a ^ b;           // XOR #1 — delay 2
    assign sum          = xor_ab ^ cin;    // XOR #2
    assign and_ab       = a & b;           // AND #1
    assign and_xor_cin  = xor_ab & cin;    // AND #2
    assign cout         = and_ab | and_xor_cin; // OR #1 — carry out stage delay ~2
endmodule

module ripple_carry_adder_4bit (
    input  wire [3:0] a, b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire c1, c2, c3; // Carry chain: Cin->c1 (~2gd), c1->c2 (~4gd), c2->c3 (~6gd), c3->cout (~8gd)

    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(c1),  .sum(sum[1]), .cout(c2));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(c2),  .sum(sum[2]), .cout(c3));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(c3),  .sum(sum[3]), .cout(cout));
endmodule

`timescale 1ns/1ps
module ripple_carry_adder_4bit_tb;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;
    reg  [4:0] expected;

    ripple_carry_adder_4bit dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    task run_test;
        input [3:0] ta, tb;
        input       tcin;
        begin
            a = ta; b = tb; cin = tcin;
            expected = ta + tb + tcin;
            #10;
            if ({cout, sum} == expected)
                $display("PASS A=%2d B=%2d Cin=%b -> Sum=%2d Cout=%b", ta, tb, tcin, sum, cout);
            else
                $display("FAIL A=%2d B=%2d Cin=%b -> Expected=%2d Got={%b,%d}",
                         ta, tb, tcin, expected, cout, sum);
        end
    endtask

    initial begin
        $display("--------------------------------------------");
        $display("4-Bit Ripple Carry Adder Verification");
        $display("--------------------------------------------");
        run_test(4'd0,  4'd0,  1'b0);
        run_test(4'd5,  4'd3,  1'b0);
        run_test(4'd6,  4'd11, 1'b0);
        run_test(4'd15, 4'd15, 1'b1);
        run_test(4'd7,  4'd8,  1'b0);
        $display("--------------------------------------------");
        $finish;
    end
endmodule
