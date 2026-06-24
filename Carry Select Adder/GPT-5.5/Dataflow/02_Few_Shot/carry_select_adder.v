//==============================================================
// 16-bit Carry Select Adder (Pure Dataflow Style)
// No always blocks
// No module instantiation
// Pure assign-based implementation
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
    wire [3:0] sum_c0_b0, sum_c1_b0;
    wire       cout_c0_b0, cout_c1_b0;

    assign {cout_c0_b0, sum_c0_b0} = a[3:0] + b[3:0];
    assign {cout_c1_b0, sum_c1_b0} = a[3:0] + b[3:0] + 1'b1;

    wire [3:0] sum_b0;
    wire       carry_b0;

    assign sum_b0   = cin ? sum_c1_b0  : sum_c0_b0;
    assign carry_b0 = cin ? cout_c1_b0 : cout_c0_b0;

    //==========================================================
    // Block 1 : Bits [7:4]
    //==========================================================
    wire [3:0] sum_c0_b1, sum_c1_b1;
    wire       cout_c0_b1, cout_c1_b1;

    assign {cout_c0_b1, sum_c0_b1} = a[7:4] + b[7:4];
    assign {cout_c1_b1, sum_c1_b1} = a[7:4] + b[7:4] + 1'b1;

    wire [3:0] sum_b1;
    wire       carry_b1;

    assign sum_b1   = carry_b0 ? sum_c1_b1  : sum_c0_b1;
    assign carry_b1 = carry_b0 ? cout_c1_b1 : cout_c0_b1;

    //==========================================================
    // Block 2 : Bits [11:8]
    //==========================================================
    wire [3:0] sum_c0_b2, sum_c1_b2;
    wire       cout_c0_b2, cout_c1_b2;

    assign {cout_c0_b2, sum_c0_b2} = a[11:8] + b[11:8];
    assign {cout_c1_b2, sum_c1_b2} = a[11:8] + b[11:8] + 1'b1;

    wire [3:0] sum_b2;
    wire       carry_b2;

    assign sum_b2   = carry_b1 ? sum_c1_b2  : sum_c0_b2;
    assign carry_b2 = carry_b1 ? cout_c1_b2 : cout_c0_b2;

    //==========================================================
    // Block 3 : Bits [15:12]
    //==========================================================
    wire [3:0] sum_c0_b3, sum_c1_b3;
    wire       cout_c0_b3, cout_c1_b3;

    assign {cout_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];
    assign {cout_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1;

    wire [3:0] sum_b3;
    wire       carry_b3;

    assign sum_b3   = carry_b2 ? sum_c1_b3  : sum_c0_b3;
    assign carry_b3 = carry_b2 ? cout_c1_b3 : cout_c0_b3;

    //==========================================================
    // Final Outputs
    //==========================================================
    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

endmodule
