design modules.
NO always blocks. NO structural instantiation. NO gate primitives. NO behavioral constructs.

EXAMPLE 1 — 4-bit dataflow adder:
module adder4_df(input signed [3:0] A, B, output signed [4:0] sum);
  assign sum = {A[3], A} + {B[3], B};
endmodule

EXAMPLE 2 — 8-bit dataflow adder with carry:
module adder8_df(input signed [7:0] A, B, output signed [8:0] sum);
  assign sum = {A[7], A} + {B[7], B};
endmodule

EXAMPLE 3 — Simple testbench for loop:
initial begin
  for (i = 0; i < 16; i = i + 1) begin
    A = i; B = ~i + 1;
    #10;
    $display("A=%0d B=%0d Sum=%0d", $signed(A), $signed(B), $signed(sum));
  end
end

NOW DO THE FOLLOWING:
1. Scale EXAMPLE 1 and EXAMPLE 2 to a 16-bit signed dataflow adder (adder16_df) with 17-bit signed output.
   Use sign extension via concatenation: assign sum = {A[15], A} + {B[15], B};
   Only assign statements allowed inside the module.

2. Build a testbench based on EXAMPLE 3 but with ALL of these loop types:
   - A for loop iterating through exactly 20 boundary value pairs covering all corner cases
   - A while loop running $signed($random) inputs for 100 iterations with mismatch tracking
   - A repeat loop applying random values for 50 iterations
   - A forever loop toggling a clk every 5ns, stopped by $finish at 1000ns
   Include $display output and PASS/FAIL checking in every loop.
design module-`timescale 1ns/1ps

module adder16_df (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output signed [16:0] sum
);

    assign sum = {A[15], A} + {B[15], B};

endmodule
testbench-`timescale 1ns/1ps

module tb_adder16_df;

    reg  signed [15:0] A;
    reg  signed [15:0] B;
    wire signed [16:0] sum;

    integer i;
    integer count;
    integer mismatches;

    reg clk;

    reg signed [15:0] boundaryA [0:19];
    reg signed [15:0] boundaryB [0:19];

    reg signed [16:0] expected;

    adder16_df dut (
        .A(A),
        .B(B),
        .sum(sum)
    );

    // --------------------------------------------------
    // Forever loop clock generation
    // --------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --------------------------------------------------
    // Main stimulus
    // --------------------------------------------------
    initial begin

        mismatches = 0;

        // 20 boundary/corner-case pairs

        boundaryA[0]  =  32767;   boundaryB[0]  =  32767;
        boundaryA[1]  = -32768;   boundaryB[1]  = -32768;
        boundaryA[2]  =  32767;   boundaryB[2]  = -32768;
        boundaryA[3]  =  0;       boundaryB[3]  =  0;
        boundaryA[4]  =  0;       boundaryB[4]  =  32767;
        boundaryA[5]  = -32768;   boundaryB[5]  =  32767;
        boundaryA[6]  =  1;       boundaryB[6]  = -1;
        boundaryA[7]  = -1;       boundaryB[7]  =  1;
        boundaryA[8]  =  100;     boundaryB[8]  =  200;
        boundaryA[9]  = -100;     boundaryB[9]  = -200;
        boundaryA[10] =  1234;    boundaryB[10] = -1234;
        boundaryA[11] =  30000;   boundaryB[11] =  2000;
        boundaryA[12] = -30000;   boundaryB[12] = -2000;
        boundaryA[13] =  16384;   boundaryB[13] =  16384;
        boundaryA[14] = -16384;   boundaryB[14] = -16384;
        boundaryA[15] =  32767;   boundaryB[15] = -1;
        boundaryA[16] = -32768;   boundaryB[16] =  1;
        boundaryA[17] =  5000;    boundaryB[17] = -3000;
        boundaryA[18] = -5000;    boundaryB[18] =  3000;
        boundaryA[19] =  42;      boundaryB[19] = -42;

        // --------------------------------------------------
        // FOR LOOP (exactly 20 boundary pairs)
        // --------------------------------------------------

        $display("\n===== FOR LOOP TESTS =====");

        for (i = 0; i < 20; i = i + 1) begin

            A = boundaryA[i];
            B = boundaryB[i];

            #10;

            expected = {A[15],A} + {B[15],B};

            if (sum === expected)
                $display("PASS  A=%0d B=%0d SUM=%0d",
                         A, B, sum);
            else begin
                mismatches = mismatches + 1;
                $display("FAIL  A=%0d B=%0d SUM=%0d EXP=%0d",
                         A, B, sum, expected);
            end
        end

        // --------------------------------------------------
        // WHILE LOOP (100 random iterations)
        // --------------------------------------------------

        $display("\n===== WHILE LOOP TESTS =====");

        count = 0;

        while (count < 100) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            expected = {A[15],A} + {B[15],B};

            if (sum === expected)
                $display("PASS  A=%0d B=%0d SUM=%0d",
                         A, B, sum);
            else begin
                mismatches = mismatches + 1;
                $display("FAIL  A=%0d B=%0d SUM=%0d EXP=%0d",
                         A, B, sum, expected);
            end

            count = count + 1;
        end

        // --------------------------------------------------
        // REPEAT LOOP (50 random iterations)
        // --------------------------------------------------

        $display("\n===== REPEAT LOOP TESTS =====");

        repeat (50) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            expected = {A[15],A} + {B[15],B};

            if (sum === expected)
                $display("PASS  A=%0d B=%0d SUM=%0d",
                         A, B, sum);
            else begin
                mismatches = mismatches + 1;
                $display("FAIL  A=%0d B=%0d SUM=%0d EXP=%0d",
                         A, B, sum, expected);
            end
        end

        $display("\nTOTAL MISMATCHES = %0d", mismatches);

    end

    // --------------------------------------------------
    // End simulation at 1000 ns
    // --------------------------------------------------

    initial begin
        #1000;
        $display("\nSimulation Finished");
        $finish;
    end

endmodule