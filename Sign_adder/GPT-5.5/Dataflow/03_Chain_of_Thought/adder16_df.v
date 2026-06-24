design module must use ONLY assign statements. No always blocks,
no structural instantiation, no gate primitives, no behavioral constructs at all.

STEP 1 — UNDERSTAND DATAFLOW MODELING:
Think: What is dataflow modeling in Verilog? It uses only continuous assignment (assign keyword)
and operators (+, -, &, |, ^, ~, {}, ?:, etc.). There are no procedural blocks.
Why is it suitable for adders? Because addition maps directly to a single assign expression.

STEP 2 — UNDERSTAND SIGNED ARITHMETIC:
Think: What does signed [15:0] mean? Range is -32768 to +32767 (two's complement).
Why does the output need 17 bits? Because 32767 + 32767 = 65534 which overflows 16 bits.
How do we sign-extend in dataflow? Use concatenation: {A[15], A} gives 17 bits with sign extended.

STEP 3 — DESIGN THE DATAFLOW MODULE:
Write module adder16_df with:
- input signed [15:0] A, B
- output signed [16:0] sum
- Single assign statement: assign sum = {A[15], A} + {B[15], B};
Explain why this works for signed overflow detection.

STEP 4 — DESIGN THE TESTBENCH:
Think: What are ALL corner cases for 16-bit signed addition?
List them: 0+0, 32767+0, -32768+0, 32767+1 (overflow), -32768+(-1) (overflow),
32767+32767, -32768+(-32768), 32767+(-32768), -1+1, 100+(-100), etc.

Now write a testbench with:
- for loop: 20 explicit corner case pairs listed above
- while loop: 100 iterations using $signed($random), track error count
- repeat loop: 50 iterations with $random, display results
- forever loop: clock toggle every 5ns, $finish at 1000ns
All loops print A, B, expected (use $signed arithmetic in testbench), actual sum, and PASS/FAIL.

STEP 5 — VERIFY:
Re-check: Is assign used everywhere in the design? Is signed keyword on all ports?
Is output 17 bits? Will all 4 loop types run without conflict? Fix any issues found.
design module-`timescale 1ns/1ps

module adder16_df (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output signed [16:0] sum
);

    assign sum = {A[15], A} + {B[15], B};

endmoduletestbench-`timescale 1ns/1ps

module tb_adder16_df;

    reg  signed [15:0] A;
    reg  signed [15:0] B;
    wire signed [16:0] sum;

    integer i;
    integer count;
    integer errors;

    reg clk;

    reg signed [15:0] tcA [0:19];
    reg signed [15:0] tcB [0:19];

    reg signed [16:0] expected;

    adder16_df dut (
        .A(A),
        .B(B),
        .sum(sum)
    );

    //---------------------------------------------------
    // FOREVER LOOP
    //---------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //---------------------------------------------------
    // TEST SEQUENCE
    //---------------------------------------------------

    initial begin

        errors = 0;

        //------------------------------------------------
        // 20 Explicit Corner Cases
        //------------------------------------------------

        tcA[0]  = 0;        tcB[0]  = 0;
        tcA[1]  = 32767;    tcB[1]  = 0;
        tcA[2]  = -32768;   tcB[2]  = 0;
        tcA[3]  = 32767;    tcB[3]  = 1;
        tcA[4]  = -32768;   tcB[4]  = -1;
        tcA[5]  = 32767;    tcB[5]  = 32767;
        tcA[6]  = -32768;   tcB[6]  = -32768;
        tcA[7]  = 32767;    tcB[7]  = -32768;
        tcA[8]  = -1;       tcB[8]  = 1;
        tcA[9]  = 100;      tcB[9]  = -100;
        tcA[10] = 1;        tcB[10] = 1;
        tcA[11] = -1;       tcB[11] = -1;
        tcA[12] = 20000;    tcB[12] = 10000;
        tcA[13] = -20000;   tcB[13] = -10000;
        tcA[14] = 16384;    tcB[14] = 16384;
        tcA[15] = -16384;   tcB[15] = -16384;
        tcA[16] = 12345;    tcB[16] = -12345;
        tcA[17] = 30000;    tcB[17] = -29999;
        tcA[18] = -30000;   tcB[18] = 29999;
        tcA[19] = 42;       tcB[19] = -42;

        //------------------------------------------------
        // FOR LOOP
        //------------------------------------------------

        $display("\n=== FOR LOOP TESTS ===");

        for(i = 0; i < 20; i = i + 1) begin

            A = tcA[i];
            B = tcB[i];

            #10;

            expected = $signed({A[15],A}) +
                       $signed({B[15],B});

            if(sum === expected)
                $display(
                "PASS A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            else begin
                errors = errors + 1;
                $display(
                "FAIL A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            end
        end

        //------------------------------------------------
        // WHILE LOOP (100 random tests)
        //------------------------------------------------

        $display("\n=== WHILE LOOP TESTS ===");

        count = 0;

        while(count < 100) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            expected = $signed({A[15],A}) +
                       $signed({B[15],B});

            if(sum === expected)
                $display(
                "PASS A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            else begin
                errors = errors + 1;
                $display(
                "FAIL A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            end

            count = count + 1;
        end

        //------------------------------------------------
        // REPEAT LOOP (50 random tests)
        //------------------------------------------------

        $display("\n=== REPEAT LOOP TESTS ===");

        repeat(50) begin

            A = $signed($random);
            B = $signed($random);

            #10;

            expected = $signed({A[15],A}) +
                       $signed({B[15],B});

            if(sum === expected)
                $display(
                "PASS A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            else begin
                errors = errors + 1;
                $display(
                "FAIL A=%0d B=%0d EXP=%0d ACT=%0d",
                A,B,expected,sum);
            end
        end

        $display("\nTOTAL ERRORS = %0d", errors);

    end

    //---------------------------------------------------
    // FINISH AT 1000ns
    //---------------------------------------------------

    initial begin
        #1000;
        $display("\nSimulation Complete");
        $finish;
    end

endmodule