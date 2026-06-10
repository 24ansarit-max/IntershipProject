//=====================================================================
// csa16_df
// 16-bit Carry Select Adder (CSA)
// Dataflow Verilog
//
// Timing : DELAY_PS = 300 ps
// Area   : AREA_UM2 = 648 um^2
// Power  : POWER_UW = 110 uW
//
// Architecture:
//   Block 0 : bits [3:0]
//   Block 1 : bits [7:4]
//   Block 2 : bits [11:8]
//   Block 3 : bits [15:12]
//
// Carry Chain:
//   cin -> carry_b0 -> carry_b1 -> carry_b2 -> carry_b3 -> cout
//
// Assign Count:
//   8 candidate-compute assigns
//   8 mux-select assigns
//   2 output assigns
//   Total = 18 assigns
//=====================================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 300, // ps
    parameter AREA_UM2   = 648, // um^2
    parameter POWER_UW   = 110  // uW
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //==================================================================
    // Section 2: Wire Declarations
    //==================================================================

    // Block 0 candidate results
    wire [3:0] sum_c0_b0, sum_c1_b0;
    wire       cout_c0_b0, cout_c1_b0;
    wire [3:0] sum_b0;
    wire       carry_b0;

    // Block 1 candidate results
    wire [3:0] sum_c0_b1, sum_c1_b1;
    wire       cout_c0_b1, cout_c1_b1;
    wire [3:0] sum_b1;
    wire       carry_b1;

    // Block 2 candidate results
    wire [3:0] sum_c0_b2, sum_c1_b2;
    wire       cout_c0_b2, cout_c1_b2;
    wire [3:0] sum_b2;
    wire       carry_b2;

    // Block 3 candidate results
    wire [3:0] sum_c0_b3, sum_c1_b3;
    wire       cout_c0_b3, cout_c1_b3;
    wire [3:0] sum_b3;
    wire       carry_b3;

    //==================================================================
    // Section 3: Block 0  (bits[3:0])
    // Select input = cin
    //==================================================================

    assign {cout_c0_b0, sum_c0_b0} = a[3:0] + b[3:0];
    assign {cout_c1_b0, sum_c1_b0} = a[3:0] + b[3:0] + 1'b1;
    assign sum_b0                  = cin ? sum_c1_b0  : sum_c0_b0;
    assign carry_b0                = cin ? cout_c1_b0 : cout_c0_b0;

    //==================================================================
    // Section 4: Block 1  (bits[7:4])
    // Select input = carry_b0
    //==================================================================

    assign {cout_c0_b1, sum_c0_b1} = a[7:4] + b[7:4];
    assign {cout_c1_b1, sum_c1_b1} = a[7:4] + b[7:4] + 1'b1;
    assign sum_b1                  = carry_b0 ? sum_c1_b1  : sum_c0_b1;
    assign carry_b1                = carry_b0 ? cout_c1_b1 : cout_c0_b1;

    //==================================================================
    // Section 5: Block 2  (bits[11:8])
    // Select input = carry_b1
    //==================================================================

    assign {cout_c0_b2, sum_c0_b2} = a[11:8] + b[11:8];
    assign {cout_c1_b2, sum_c1_b2} = a[11:8] + b[11:8] + 1'b1;
    assign sum_b2                  = carry_b1 ? sum_c1_b2  : sum_c0_b2;
    assign carry_b2                = carry_b1 ? cout_c1_b2 : cout_c0_b2;

    //==================================================================
    // Section 6: Block 3  (bits[15:12])
    // Select input = carry_b2
    //==================================================================

    assign {cout_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];
    assign {cout_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1;
    assign sum_b3                  = carry_b2 ? sum_c1_b3  : sum_c0_b3;
    assign carry_b3                = carry_b2 ? cout_c1_b3 : cout_c0_b3;

    //==================================================================
    // Section 7: Output Assembly
    //==================================================================

    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

    //==================================================================
    // Section 8: Specify / Specparam Block
    //==================================================================

    specify
        specparam tPD = DELAY_PS;
        (a, b, cin *> sum, cout) = tPD;
    endspecify

endmodule
