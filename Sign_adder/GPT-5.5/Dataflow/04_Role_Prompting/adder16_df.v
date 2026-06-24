design module.

A junior engineer has asked you to write a reference implementation of a 16-bit signed adder
that strictly follows your team's dataflow-only coding standard.

Write the following as a professional code review submission:

1. Module adder16_df (DATAFLOW ONLY):
   - Inputs: signed [15:0] A, B
   - Output: signed [16:0] sum
   - Use ONLY assign statements
   - Sign-extend inputs before adding: assign sum = {A[15], A} + {B[15], B};
   - Add inline comments explaining sign extension and overflow capture
   - Absolutely NO always blocks or structural instantiation

2. Testbench tb_adder16 (comprehensive):
   - Instantiate adder16_df
   - FOR loop: test all 20 boundary pairs including max positive, max negative,
     overflow cases, zero cases, and mixed sign cases — with #10 delay and PASS/FAIL check
   - WHILE loop: run 100 iterations with $signed($random) for A and B,
     track mismatch count, display PASS or FAIL each iteration
   - REPEAT loop: 50 iterations with $random inputs, $display each result
   - FOREVER loop: toggle clk every 5ns, stopped by $finish at 2000ns in a separate initial block
   - Use $display with %0d signed decimal format throughout

Write clean, professional, commented Verilog with a module-level header comment block.
design module-
//==============================================================================
// Module Name : adder16_df
// Description :
//   16-bit signed adder implemented using DATAFLOW MODELING ONLY.
//
// Coding Standard Compliance:
//   - Continuous assignment (assign) statements only
//   - No always blocks
//   - No structural instantiation
//   - No gate primitives
//   - Fully synthesizable for FPGA/ASIC flows
//
// Function:
//   Adds two signed 16-bit operands and produces a signed 17-bit result.
//   Inputs are sign-extended prior to addition so that the extra MSB captures
//   the mathematical overflow bit of the signed addition.
//==============================================================================

module adder16_df (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output signed [16:0] sum
);

    // Sign-extend both operands from 16 bits to 17 bits.
    // Replicating the sign bit preserves the signed value.
    //
    // Example:
    //   A = 16'h8000 (-32768)
    //   becomes 17'h18000
    //
    // The resulting 17-bit sum captures the full signed result,
    // including any overflow beyond the original 16-bit range.
    assign sum = {A[15], A} + {B[15], B};

endmodule
testbench-`timescale 1ns/1ps

//==============================================================================
// Module Name : tb_adder16
// Description :
//   Comprehensive verification testbench for adder16_df.
//
// Coverage Includes:
//   1. FOR loop:
//      - 20 directed boundary test pairs
//      - Overflow cases
//      - Underflow cases
//      - Zero cases
//      - Mixed-sign cases
//
//   2. WHILE loop:
//      - 100 random signed tests
//      - PASS/FAIL comparison against reference model
//
//   3. REPEAT loop:
//      - 50 random stimulus iterations
//      - Result display
//
//   4. FOREVER loop:
//      - Free-running clock generation (5 ns half-period)
//
//   5. Simulation stop:
//      - Separate initial block
//      - $finish at 2000 ns
//==============================================================================

module tb_adder16;

    reg  signed [15:0] A;
    reg  signed [15:0] B;
    wire signed [16:0] sum;

    reg clk;

    integer i;
    integer mismatch_count;

    reg signed [15:0] testA [0:19];
    reg signed [15:0] testB [0:19];

    reg signed [16:0] expected;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    adder16_df dut (
        .A(A),
        .B(B),
        .sum(sum)
    );

    //--------------------------------------------------------------------------
    // FOREVER LOOP : Clock Generation
    //--------------------------------------------------------------------------

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    //--------------------------------------------------------------------------
    // Stop Simulation at 2000 ns
    //--------------------------------------------------------------------------

    initial begin
        #2000;
        $display("\nSimulation finished at %0t ns", $time);
        $finish;
    end

    //--------------------------------------------------------------------------
    // Main Stimulus
    //--------------------------------------------------------------------------

    initial begin

        mismatch_count = 0;

        //----------------------------------------------------------------------
        // Directed Boundary Test Set (20 Pairs)
        //----------------------------------------------------------------------

        testA[0]  = 16'sd0;       testB[0]  = 16'sd0;
        testA[1]  = 16'sd1;       testB[1]  = 16'sd1;
        testA[2]  = -16'sd1;      testB[2]  = -16'sd1;
        testA[3]  = 16'sd32767;   testB[3]  = 16'sd1;
        testA[4]  = -16'sd32768;  testB[4]  = -16'sd1;
        testA[5]  = 16'sd32767;   testB[5]  = 16'sd32767;
        testA[6]  = -16'sd32768;  testB[6]  = -16'sd32768;
        testA[7]  = 16'sd32767;   testB[7]  = -16'sd32768;
        testA[8]  = -16'sd32768;  testB[8]  = 16'sd32767;
        testA[9]  = 16'sd100;     testB[9]  = -16'sd100;
        testA[10] = -16'sd100;    testB[10] = 16'sd100;
        testA[11] = 16'sd12345;   testB[11] = 16'sd2222;
        testA[12] = -16'sd12345;  testB[12] = -16'sd2222;
        testA[13] = 16'sd30000;   testB[13] = 16'sd3000;
        testA[14] = -16'sd30000;  testB[14] = -16'sd3000;
        testA[15] = 16'sd20000;   testB[15] = -16'sd15000;
        testA[16] = -16'sd20000;  testB[16] = 16'sd15000;
        testA[17] = 16'sd32767;   testB[17] = 16'sd0;
        testA[18] = -16'sd32768;  testB[18] = 16'sd0;
        testA[19] = 16'sd5555;    testB[19] = -16'sd4444;

        $display("\n=================================================");
        $display("DIRECTED BOUNDARY TESTS (FOR LOOP)");
        $display("=================================================\n");

        //----------------------------------------------------------------------
        // FOR LOOP
        //----------------------------------------------------------------------

        for (i = 0; i < 20; i = i + 1) begin

            A = testA[i];
            B = testB[i];

            #10;

            expected = {A[15], A} + {B[15], B};

            if (sum === expected)
                $display(
                    "PASS : A=%0d B=%0d SUM=%0d",
                    A, B, sum
                );
            else begin
                $display(
                    "FAIL : A=%0d B=%0d EXP=%0d GOT=%0d",
                    A, B, expected, sum
                );
                mismatch_count = mismatch_count + 1;
            end
        end

        //----------------------------------------------------------------------
        // WHILE LOOP
        //----------------------------------------------------------------------

        $display("\n=================================================");
        $display("RANDOM TESTS (WHILE LOOP)");
        $display("=================================================\n");

        i = 0;

        while (i < 100) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            expected = {A[15], A} + {B[15], B};

            if (sum === expected)
                $display(
                    "PASS [%0d] A=%0d B=%0d SUM=%0d",
                    i, A, B, sum
                );
            else begin
                $display(
                    "FAIL [%0d] A=%0d B=%0d EXP=%0d GOT=%0d",
                    i, A, B, expected, sum
                );
                mismatch_count = mismatch_count + 1;
            end

            i = i + 1;
        end

        //----------------------------------------------------------------------
        // REPEAT LOOP
        //----------------------------------------------------------------------

        $display("\n=================================================");
        $display("REPEAT LOOP RANDOM STIMULUS");
        $display("=================================================\n");

        repeat (50) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            $display(
                "A=%0d B=%0d SUM=%0d",
                A, B, sum
            );
        end

        //----------------------------------------------------------------------
        // Summary
        //----------------------------------------------------------------------

        $display("\n=================================================");
        $display("TEST SUMMARY");
        $display("=================================================");
        $display("Total mismatches = %0d", mismatch_count);

        if (mismatch_count == 0)
            $display("OVERALL RESULT : PASS");
        else
            $display("OVERALL RESULT : FAIL");

    end

endmodule