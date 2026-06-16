`timescale 1ns/1ps

module testbench;

reg signed [15:0] A;
reg signed [15:0] B;

wire signed [16:0] sum;

//====================================================
// CHANGE ONLY THIS INSTANCE NAME
//====================================================

//adder16_beh dut(
//    .A(A),
//    .B(B),
//    .sum(sum)
//);

//adder16_df dut(
//    .A(A),
//    .B(B),
//    .sum(sum)
//);

adder16_struct dut(
    .A(A),
    .B(B),
    .sum(sum)
);

//====================================================
// REFERENCE MODEL
//====================================================

reg signed [16:0] expected;

integer total_tests;
integer total_errors;
integer i;

//====================================================
// SELF CHECK TASK
//====================================================

task automatic check;
begin
    #1;

    expected = $signed({A[15],A}) +
               $signed({B[15],B});

    total_tests = total_tests + 1;

    if(sum !== expected)
    begin
        total_errors = total_errors + 1;

        if(total_errors <= 20)
        begin
            $display("");
            $display("================================");
            $display("MISMATCH DETECTED");
            $display("================================");
            $display("TEST     = %0d", total_tests);
            $display("A        = %0d (%h)", A, A);
            $display("B        = %0d (%h)", B, B);
            $display("Expected = %0d (%h)", expected, expected);
            $display("Actual   = %0d (%h)", sum, sum);
        end
    end
end
endtask

//====================================================
// MAIN TEST
//====================================================

initial begin

    total_tests  = 0;
    total_errors = 0;

    $display("Running Directed Tests...");

    // Basic
    A=0;        B=0;         check();
    A=1;        B=1;         check();
    A=-1;       B=-1;        check();
    A=10;       B=20;        check();
    A=-10;      B=-20;       check();
    A=100;      B=-50;       check();

    // Boundary
    A=32767;    B=0;         check();
    A=32767;    B=1;         check();
    A=32767;    B=32767;     check();

    A=-32768;   B=0;         check();
    A=-32768;   B=-1;        check();
    A=-32768;   B=-32768;    check();

    A=32767;    B=-32768;    check();
    A=-32768;   B=32767;     check();

    // Carry propagation
    A=16'h000F; B=16'h0001;  check();
    A=16'h00FF; B=16'h0001;  check();
    A=16'h0FFF; B=16'h0001;  check();
    A=16'h7FFF; B=16'h0001;  check();

    // Zero-result
    A=12345;    B=-12345;    check();
    A=30000;    B=-30000;    check();
    A=-20000;   B=20000;     check();

    // Random stress
    $display("Running 50000 Random Tests...");

    for(i=0; i<50000; i=i+1)
    begin
        A = $random;
        B = $random;
        check();
    end

    //================================================
    // ERROR TAXONOMY SUMMARY
    //================================================

    $display("");
    $display("================================");
    $display("ERROR TAXONOMY SUMMARY");
    $display("================================");
    $display("Total Tests  : %0d", total_tests);
    $display("Total Errors : %0d", total_errors);
    $display("================================");

    if(total_errors == 0)
        $display("FINAL RESULT : PASS");
    else
        $display("FINAL RESULT : FAIL");

    $finish;

end

endmodule
