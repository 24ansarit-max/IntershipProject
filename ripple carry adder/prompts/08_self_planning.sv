// =============================================================================
// PROMPT STRATEGY: SELF PLANNING
// =============================================================================
// PPA targets: Area <= 50 gates | Power <= 0.5 mW @ 100 MHz | Timing <= 8 gate delays
//
// Before Verilog, create a design plan:
// PHASE 1: Requirements — I/O widths, critical path (carry chain), hardest constraint
// PHASE 2: Architecture — compare structural vs behavioral; pick best for PPA
// PHASE 3: Module decomposition — block diagram with carry chain
// PHASE 4: PPA pre-estimate — area, timing per stage, power/switching
// PHASE 5: Implementation — full_adder, ripple_carry_adder_4bit, TB with 6 vectors
// =============================================================================

module full_adder (
    input  wire a, b, cin,
    output wire sum, cout
);
    wire xor_ab, and_ab, and_xor_cin;

    assign xor_ab      = a ^ b;          // Gate #1
    assign sum         = xor_ab ^ cin;   // Gate #2
    assign and_ab      = a & b;          // Gate #3
    assign and_xor_cin = xor_ab & cin;   // Gate #4
    assign cout        = and_ab | and_xor_cin; // Gate #5
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

`timescale 1ns/1ps
module ripple_carry_adder_4bit_tb;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    ripple_carry_adder_4bit dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $display("------------------------------------------------");
        $display(" A B Cin | Sum Cout");
        $display("------------------------------------------------");

        a=0;  b=0;  cin=0; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);
        a=5;  b=3;  cin=0; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);
        a=6;  b=11; cin=0; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);
        a=15; b=1;  cin=0; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);
        a=15; b=15; cin=1; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);
        a=7;  b=8;  cin=0; #10; $display("%2d %2d %b | %2d %b", a, b, cin, sum, cout);

        $display("------------------------------------------------");
        $finish;
    end
endmodule
