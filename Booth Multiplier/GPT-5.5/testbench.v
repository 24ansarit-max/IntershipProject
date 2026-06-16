///// Note :- Check instantiation name before execution 1

`timescale 1ns/1ps

module tb_booth_multiplier;

    reg  signed [15:0] multiplicand;
    reg  signed [15:0] multiplier;

    wire signed [31:0] product;

    reg signed [31:0] expected;

    integer total_tests;
    integer pass_count;
    integer fail_count;

    // Store failures for printing after summary
    reg signed [15:0] fail_A   [0:102010];
    reg signed [15:0] fail_B   [0:102010];
    reg signed [31:0] fail_exp [0:102010];
    reg signed [31:0] fail_got [0:102010];

    integer i;

    both_multiplier_16bit dut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );

    //--------------------------------------------------
    // Self-checking task
    //--------------------------------------------------
    task check_result;
    begin
        #1;

        expected = multiplicand * multiplier;
        total_tests = total_tests + 1;

        if (product !== expected)
        begin
            fail_A[fail_count]   = multiplicand;
            fail_B[fail_count]   = multiplier;
            fail_exp[fail_count] = expected;
            fail_got[fail_count] = product;

            fail_count = fail_count + 1;
        end
        else
        begin
            pass_count = pass_count + 1;
        end
    end
    endtask

    //--------------------------------------------------
    // Main Test Sequence
    //--------------------------------------------------
    initial begin

        total_tests = 0;
        pass_count  = 0;
        fail_count  = 0;

        //--------------------------------------------------
        // Corner Cases
        //--------------------------------------------------

        multiplicand = 0;
        multiplier   = 0;
        check_result();

        multiplicand = 1;
        multiplier   = 1;
        check_result();

        multiplicand = -1;
        multiplier   = 1;
        check_result();

        multiplicand = 1;
        multiplier   = -1;
        check_result();

        multiplicand = -1;
        multiplier   = -1;
        check_result();

        multiplicand = 16'sh7FFF;
        multiplier   = 16'sh7FFF;
        check_result();

        multiplicand = 16'sh8000;
        multiplier   = 16'sh8000;
        check_result();

        multiplicand = 16'sh8000;
        multiplier   = 16'sh7FFF;
        check_result();

        multiplicand = 16'sh7FFF;
        multiplier   = 16'sh8000;
        check_result();

        multiplicand = 0;
        multiplier   = -32768;
        check_result();

        multiplicand = -32768;
        multiplier   = 0;
        check_result();

        //--------------------------------------------------
        // Additional Directed Cases
        //--------------------------------------------------

        multiplicand = 16'hAAAA;
        multiplier   = 16'h5555;
        check_result();

        multiplicand = 16'hFFFF;
        multiplier   = 16'h8000;
        check_result();

        multiplicand = 16'h8000;
        multiplier   = 16'hFFFF;
        check_result();

        //--------------------------------------------------
        // Directed Patterns
        //--------------------------------------------------

        for(i=0; i<1000; i=i+1)
        begin
            multiplicand = i;
            multiplier   = 1;
            check_result();
        end

        for(i=0; i<1000; i=i+1)
        begin
            multiplicand = i;
            multiplier   = -1;
            check_result();
        end

        //--------------------------------------------------
        // Random Stress Test
        //--------------------------------------------------

        for(i=0; i<100000; i=i+1)
        begin
            multiplicand = $random;
            multiplier   = $random;
            check_result();
        end

        //--------------------------------------------------
        // Summary First
        //--------------------------------------------------

        $display("\n");
        $display("======================================");
        $display("TOTAL TESTS : %0d", total_tests);
        $display("PASSED      : %0d", pass_count);
        $display("FAILED      : %0d", fail_count);
        $display("======================================");

        if(fail_count == 0)
        begin
            $display("DUT PASSED ALL TESTS");
        end
        else
        begin
            $display("\nFailure Details:\n");

            for(i=0; i<fail_count; i=i+1)
            begin
                $display("------------------------------------------------");
                $display("FAIL");
                $display("A        = %d (0x%h)", fail_A[i], fail_A[i]);
                $display("B        = %d (0x%h)", fail_B[i], fail_B[i]);
                $display("Expected = %d (0x%h)", fail_exp[i], fail_exp[i]);
                $display("Got      = %d (0x%h)", fail_got[i], fail_got[i]);
                $display("------------------------------------------------");
            end
        end

        $finish;

    end

endmodule

