// csa16_df | 16-bit | Carry Select | Dataflow | 4×4-bit blocks

module carry_select_adder #(

    //━━━━━━━━━ PARAMETERS ━━━━━━━━━
    parameter BLOCK_SIZE = 4,      // bits per block
    parameter NUM_BLOCKS = 4,      // total blocks = 16/4
    parameter DELAY_PS   = 320,    // ps — RCA4 + ternary mux worst case
    parameter AREA_UM2   = 650,    // µm² — 2× adder area vs RCA16
    parameter POWER_UW   = 110     // µW — 1GHz, 1V , activity=0.1

)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

    //━━━━━━━━━ WIRE DECLARATIONS ━━━━━━━━━
    // Pattern:
    // wire [3:0] sum_c0_bN, sum_c1_bN;
    // wire cout_c0_bN, cout_c1_bN;
    // wire [3:0] sum_bN;
    // wire carry_bN;

    wire [3:0] sum_c0_b0, sum_c1_b0;
    wire       cout_c0_b0, cout_c1_b0;
    wire [3:0] sum_b0;
    wire       carry_b0;

    wire [3:0] sum_c0_b1, sum_c1_b1;
    wire       cout_c0_b1, cout_c1_b1;
    wire [3:0] sum_b1;
    wire       carry_b1;

    wire [3:0] sum_c0_b2, sum_c1_b2;
    wire       cout_c0_b2, cout_c1_b2;
    wire [3:0] sum_b2;
    wire       carry_b2;

    wire [3:0] sum_c0_b3, sum_c1_b3;
    wire       cout_c0_b3, cout_c1_b3;
    wire [3:0] sum_b3;
    wire       carry_b3;

    //━━━━━━━━━ BLOCK 0 — bits[3:0] ━━━━━━━━━
    assign {cout_c0_b0, sum_c0_b0} = a[3:0] + b[3:0];
    assign {cout_c1_b0, sum_c1_b0} = a[3:0] + b[3:0] + 1'b1;
    assign sum_b0   = cin ? sum_c1_b0  : sum_c0_b0;
    assign carry_b0 = cin ? cout_c1_b0 : cout_c0_b0;

    //━━━━━━━━━ BLOCK 1 — bits[7:4] ━━━━━━━━━
    assign {cout_c0_b1, sum_c0_b1} = a[7:4] + b[7:4];
    assign {cout_c1_b1, sum_c1_b1} = a[7:4] + b[7:4] + 1'b1;
    assign sum_b1   = carry_b0 ? sum_c1_b1  : sum_c0_b1;
    assign carry_b1 = carry_b0 ? cout_c1_b1 : cout_c0_b1;

    //━━━━━━━━━ BLOCK 2 — bits[11:8] ━━━━━━━━━
    assign {cout_c0_b2, sum_c0_b2} = a[11:8] + b[11:8];
    assign {cout_c1_b2, sum_c1_b2} = a[11:8] + b[11:8] + 1'b1;
    assign sum_b2   = carry_b1 ? sum_c1_b2  : sum_c0_b2;
    assign carry_b2 = carry_b1 ? cout_c1_b2 : cout_c0_b2;

    //━━━━━━━━━ BLOCK 3 — bits[15:12] ━━━━━━━━━
    assign {cout_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];
    assign {cout_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1;
    assign sum_b3   = carry_b2 ? sum_c1_b3  : sum_c0_b3;
    assign carry_b3 = carry_b2 ? cout_c1_b3 : cout_c0_b3;

    //━━━━━━━━━ OUTPUT ASSEMBLY ━━━━━━━━━
    assign sum  = {sum_b3, sum_b2, sum_b1, sum_b0};
    assign cout = carry_b3;

    //━━━━━━━━━ SPECIFY BLOCK ━━━━━━━━━
    specify
        specparam tPD = DELAY_PS;
        (a, b, cin *> sum, cout) = tPD;
    endspecify

endmodule
