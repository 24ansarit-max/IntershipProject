design module.

The design must:
- Accept two 16-bit signed inputs: A and B
- Produce a 17-bit signed output (16-bit sum + 1 overflow/carry bit)
- Handle signed overflow correctly using sign extension via concatenation: {A[15], A} + {B[15], B}
- Use ONLY assign statements inside the module

Also write a testbench that:
- Tests ALL corner cases: max positive + max positive, max negative + max negative,
  max positive + max negative, zero + zero, zero + max, min + max, positive + negative
- Uses a for loop iterating over at least 20 boundary value pairs
- Uses a while loop with $signed($random) inputs for 100 iterations
- Uses a repeat loop for 50 random iterations
- Uses a forever loop for clock toggling, stopped by $finish at 1000ns
- Checks results using $display with signed decimal format and prints PASS or FAIL per test
- Uses $finish to end simulation cleanlyDesign Module-`timescale 1ns/1ps

module signed_adder_16_dataflow (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output signed [16:0] SUM
);

    // Sign-extended addition
    assign SUM = {A[15], A} + {B[15], B};

endmoduleTestbench-`timescale 1ns/1ps

module tb_signed_adder_16_dataflow;

    reg  signed [15:0] A;
    reg  signed [15:0] B;
    wire signed [16:0] SUM;

    integer i;
    integer count;

    reg clk;

    reg signed [16:0] expected;

    // DUT
    signed_adder_16_dataflow dut (
        .A(A),
        .B(B),
        .SUM(SUM)
    );

    // --------------------------------------------------
    // Forever loop clock generation
    // --------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --------------------------------------------------
    // PASS/FAIL task
    // --------------------------------------------------
    task check_result;
        begin
            expected = {A[15],A} + {B[15],B};

            if (SUM === expected)
                $display("PASS : A=%0d B=%0d SUM=%0d",
                         A, B, SUM);
            else
                $display("FAIL : A=%0d B=%0d SUM=%0d EXPECTED=%0d",
                         A, B, SUM, expected);
        end
    endtask

    // --------------------------------------------------
    // Main stimulus
    // --------------------------------------------------
    initial begin

        // ==================================================
        // Required Corner Cases
        // ==================================================

        A = 16'sd32767;   B = 16'sd32767;   #10; check_result();
        A = -16'sd32768;  B = -16'sd32768;  #10; check_result();
        A = 16'sd32767;   B = -16'sd32768;  #10; check_result();
        A = 16'sd0;       B = 16'sd0;       #10; check_result();
        A = 16'sd0;       B = 16'sd32767;   #10; check_result();
        A = -16'sd32768;  B = 16'sd32767;   #10; check_result();
        A = 16'sd1000;    B = -16'sd500;    #10; check_result();

        // ==================================================
        // Boundary-value array (20+ pairs)
        // ==================================================

        reg signed [15:0] boundary [0:19];

        boundary[0]  = -32768;
        boundary[1]  = -32767;
        boundary[2]  = -30000;
        boundary[3]  = -20000;
        boundary[4]  = -16384;
        boundary[5]  = -10000;
        boundary[6]  = -5000;
        boundary[7]  = -1;
        boundary[8]  = 0;
        boundary[9]  = 1;
        boundary[10] = 2;
        boundary[11] = 10;
        boundary[12] = 100;
        boundary[13] = 1000;
        boundary[14] = 5000;
        boundary[15] = 10000;
        boundary[16] = 16384;
        boundary[17] = 20000;
        boundary[18] = 30000;
        boundary[19] = 32767;

        // --------------------------------------------------
        // FOR LOOP (20 iterations)
        // --------------------------------------------------
        for (i = 0; i < 20; i = i + 1) begin
            A = boundary[i];
            B = boundary[19-i];
            #10;
            check_result();
        end

        // --------------------------------------------------
        // WHILE LOOP (100 random iterations)
        // --------------------------------------------------
        count = 0;

        while (count < 100) begin
            A = $signed($random);
            B = $signed($random);

            #10;
            check_result();

            count = count + 1;
        end

        // --------------------------------------------------
        // REPEAT LOOP (50 random iterations)
        // --------------------------------------------------
        repeat (50) begin
            A = $signed($random);
            B = $signed($random);

            #10;
            check_result();
        end

    end

    // --------------------------------------------------
    // Finish simulation at 1000ns
    // --------------------------------------------------
    initial begin
        #1000;
        $display("Simulation Finished");
        $finish;
    end

endmodule