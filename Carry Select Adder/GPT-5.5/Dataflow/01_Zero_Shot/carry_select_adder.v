//==============================================================
// 16-bit Carry Select Adder (Dataflow Style Only)
// No always blocks
// No module instantiation
// No generate statements
//==============================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 320,
    parameter AREA_UM2   = 650,
    parameter POWER_UW   = 110
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //==========================================================
    // Block 0 : Bits [3:0]
    //==========================================================
    wire [3:0] sum_b0_c0;
    wire [3:0] sum_b0_c1;
    wire [3:0] sum_b0;

    wire cout_b0_c0;
    wire cout_b0_c1;
    wire carry_b1;

    assign sum_b0_c0 = a[3:0] + b[3:0];
    assign sum_b0_c1 = a[3:0] + b[3:0] + 4'b0001;

    assign cout_b0_c0 = &(a[3:0] + b[3:0]);
    assign cout_b0_c1 = &(a[3:0] + b[3:0] + 4'b0001);

    assign sum_b0   = (cin) ? sum_b0_c1 : sum_b0_c0;
    assign carry_b1 = (cin) ? cout_b0_c1 : cout_b0_c0;

    //==========================================================
    // Block 1 : Bits [7:4]
    //==========================================================
    wire [3:0] sum_b1_c0;
    wire [3:0] sum_b1_c1;
    wire [3:0] sum_b1;

    wire cout_b1_c0;
    wire cout_b1_c1;
    wire carry_b2;

    assign sum_b1_c0 = a[7:4] + b[7:4];
    assign sum_b1_c1 = a[7:4] + b[7:4] + 4'b0001;

    assign cout_b1_c0 = &(a[7:4] + b[7:4]);
    assign cout_b1_c1 = &(a[7:4] + b[7:4] + 4'b0001);

    assign sum_b1   = (carry_b1) ? sum_b1_c1 : sum_b1_c0;
    assign carry_b2 = (carry_b1) ? cout_b1_c1 : cout_b1_c0;

    //==========================================================
    // Block 2 : Bits [11:8]
    //==========================================================
    wire [3:0] sum_b2_c0;
    wire [3:0] sum_b2_c1;
    wire [3:0] sum_b2;

    wire cout_b2_c0;
    wire cout_b2_c1;
    wire carry_b3;

    assign sum_b2_c0 = a[11:8] + b[11:8];
    assign sum_b2_c1 = a[11:8] + b[11:8] + 4'b0001;

    assign cout_b2_c0 = &(a[11:8] + b[11:8]);
    assign cout_b2_c1 = &(a[11:8] + b[11:8] + 4'b0001);

    assign sum_b2   = (carry_b2) ? sum_b2_c1 : sum_b2_c0;
    assign carry_b3 = (carry_b2) ? cout_b2_c1 : cout_b2_c0;

    //==========================================================
    // Block 3 : Bits [15:12]
    //==========================================================
    wire [3:0] sum_b3_c0;
    wire [3:0] sum_b3_c1;
    wire [3:0] sum_b3;

    wire cout_b3_c0;
    wire cout_b3_c1;

    assign sum_b3_c0 = a[15:12] + b[15:12];
    assign sum_b3_c1 = a[15:12] + b[15:12] + 4'b0001;

    assign cout_b3_c0 = &(a[15:12] + b[15:12]);
    assign cout_b3_c1 = &(a[15:12] + b[15:12] + 4'b0001);

    assign sum_b3 = (carry_b3) ? sum_b3_c1 : sum_b3_c0;
    assign cout   = (carry_b3) ? cout_b3_c1 : cout_b3_c0;

    //==========================================================
    // Final Sum Concatenation
    //==========================================================
    assign sum = {sum_b3, sum_b2, sum_b1, sum_b0};

endmodule
