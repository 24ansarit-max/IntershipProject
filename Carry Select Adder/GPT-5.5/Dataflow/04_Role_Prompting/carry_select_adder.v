//=====================================================================
// 16-bit Carry Select Adder (CSA)
// Style      : Pure Dataflow (assign-only)
// Compatibility:
//   - Synopsys Design Compiler
//   - Cadence Genus
//   - Verilog-2001
//
// PPA Parameters:
//   DELAY_PS : Estimated critical-path delay (picoseconds)
//   AREA_UM2 : Estimated area (square microns)
//   POWER_UW : Estimated dynamic power (microwatts)
//=====================================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 320, // ps
    parameter AREA_UM2   = 650, // um^2
    parameter POWER_UW   = 110  // uW
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //==================================================================
    // BLOCK 0 : Bits [3:0]
    //==================================================================

    wire [3:0] sum_c0_b0;
    wire [3:0] sum_c1_b0;
    wire       cout_c0_b0;
    wire       cout_c1_b0;

    wire [3:0] sum_b0;
    wire       carry_b0;

    assign {cout_c0_b0, sum_c0_b0} = a[3:0] + b[3:0];        // Block0 c0
    assign {cout_c1_b0, sum_c1_b0} = a[3:0] + b[3:0] + 1'b1; // Block0 c1

    assign sum_b0   = (cin) ? sum_c1_b0  : sum_c0_b0;        // Block0 mux
    assign carry_b0 = (cin) ? cout_c1_b0 : cout_c0_b0;       // Block0 carry

    // Engineer Note:
    // Dual-compute removes carry propagation beyond 4 bits.
    // Area doubles locally, but timing improves significantly.

    //==================================================================
    // BLOCK 1 : Bits [7:4]
    //==================================================================

    wire [3:0] sum_c0_b1;
    wire [3:0] sum_c1_b1;
    wire       cout_c0_b1;
    wire       cout_c1_b1;

    wire [3:0] sum_b1;
    wire       carry_b1;

    assign {cout_c0_b1, sum_c0_b1} = a[7:4] + b[7:4];        // Block1 c0
    assign {cout_c1_b1, sum_c1_b1} = a[7:4] + b[7:4] + 1'b1; // Block1 c1

    assign sum_b1   = (carry_b0) ? sum_c1_b1  : sum_c0_b1;   // Block1 mux
    assign carry_b1 = (carry_b0) ? cout_c1_b1 : cout_c0_b1;  // Block1 carry

    // Engineer Note:
    // Both carry assumptions are precomputed in parallel.
    // Critical path becomes mux-selection instead of ripple carry.

    //==================================================================
    // BLOCK 2 : Bits [11:8]
    //==================================================================

    wire [3:0] sum_c0_b2;
    wire [3:0] sum_c1_b2;
    wire       cout_c0_b2;
    wire       cout_c1_b2;

    wire [3:0] sum_b2;
    wire       carry_b2;

    assign {cout_c0_b2, sum_c0_b2} = a[11:8] + b[11:8];        // Block2 c0
    assign {cout_c1_b2, sum_c1_b2} = a[11:8] + b[11:8] + 1'b1; // Block2 c1

    assign sum_b2   = (carry_b1) ? sum_c1_b2  : sum_c0_b2;     // Block2 mux
    assign carry_b2 = (carry_b1) ? cout_c1_b2 : cout_c0_b2;    // Block2 carry

    // Engineer Note:
    // Carry-select logic limits carry dependency to mux depth.
    // Improves Fmax at the expense of duplicated arithmetic logic.

    //==================================================================
    // BLOCK 3 : Bits [15:12]
    //==================================================================

    wire [3:0] sum_c0_b3;
    wire [3:0] sum_c1_b3;
    wire       cout_c0_b3;
    wire       cout_c1_b3;

    wire [3:0] sum_b3;
    wire       carry_b3;

    assign {cout_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];        // Block3 c0
    assign {cout_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1; // Block3 c1

    assign sum_b3   = (carry_b2) ? sum_c1_b3  : sum_c0_b3;       // Block3 mux
    assign carry_b3 = (carry_b2) ? cout_c1_b3 : cout_c0_b3;      // Block3 carry

    // Engineer Note:
    // Final CSA stage preserves constant 4-bit adder depth.
    // Overall delay ≈ adder4 + mux chain, not 16-bit ripple carry.

    //==================================================================
    // OUTPUT ASSEMBLY
    //==================================================================

    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

    //==================================================================
    // Timing Specification
    //==================================================================

    specify
        specparam tPD = DELAY_PS;

        (a   *> sum ) = tPD;
        (b   *> sum ) = tPD;
        (cin *> sum ) = tPD;

        (a   *> cout) = tPD;
        (b   *> cout) = tPD;
        (cin *> cout) = tPD;
    endspecify

endmodule
