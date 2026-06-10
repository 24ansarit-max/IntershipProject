//=====================================================================
// csa16_beh
// 16-bit Carry Select Adder (CSA)
// Behavioral Verilog Reference Model
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
// Behavioral Style:
//   - Single always @(*)
//   - Explicitly unrolled blocks
//   - Two candidate computations per block
//   - if/else carry-select logic
//   - Zero latch inference
//=====================================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,
    parameter DELAY_PS   = 300, // ps
    parameter AREA_UM2   = 648, // um^2
    parameter POWER_UW   = 110  // uW
)(
    //==================================================================
    // Section 2: Port Declaration
    //==================================================================
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output reg [15:0] sum,
    output reg        cout
);

    //==================================================================
    // Section 3: Intermediate Reg Declarations
    //==================================================================

    // Block 0 candidate sums/carries
    reg [3:0] sum_c0_b0;
    reg [3:0] sum_c1_b0;
    reg       carry_c0_b0;
    reg       carry_c1_b0;

    // Block 1 candidate sums/carries
    reg [3:0] sum_c0_b1;
    reg [3:0] sum_c1_b1;
    reg       carry_c0_b1;
    reg       carry_c1_b1;

    // Block 2 candidate sums/carries
    reg [3:0] sum_c0_b2;
    reg [3:0] sum_c1_b2;
    reg       carry_c0_b2;
    reg       carry_c1_b2;

    // Block 3 candidate sums/carries
    reg [3:0] sum_c0_b3;
    reg [3:0] sum_c1_b3;
    reg       carry_c0_b3;
    reg       carry_c1_b3;

    // Carry-chain registers
    reg carry_b0;
    reg carry_b1;
    reg carry_b2;
    reg carry_b3;

    //==================================================================
    // Section 4: always @(*) Body
    //==================================================================

    always @(*) begin

        //==============================================================
        // 4a: Default Assignments (Latch Prevention)
        //==============================================================

        sum = 16'h0000;
        cout = 1'b0;

        sum_c0_b0 = 4'h0;
        sum_c1_b0 = 4'h0;
        carry_c0_b0 = 1'b0;
        carry_c1_b0 = 1'b0;

        sum_c0_b1 = 4'h0;
        sum_c1_b1 = 4'h0;
        carry_c0_b1 = 1'b0;
        carry_c1_b1 = 1'b0;

        sum_c0_b2 = 4'h0;
        sum_c1_b2 = 4'h0;
        carry_c0_b2 = 1'b0;
        carry_c1_b2 = 1'b0;

        sum_c0_b3 = 4'h0;
        sum_c1_b3 = 4'h0;
        carry_c0_b3 = 1'b0;
        carry_c1_b3 = 1'b0;

        carry_b0 = 1'b0;
        carry_b1 = 1'b0;
        carry_b2 = 1'b0;
        carry_b3 = 1'b0;

        //==============================================================
        // 4b: Block 0 : bits[3:0], carry_in = cin
        //==============================================================

        {carry_c0_b0, sum_c0_b0} = a[3:0] + b[3:0];
        {carry_c1_b0, sum_c1_b0} = a[3:0] + b[3:0] + 1'b1;

        if (cin) begin
            sum[3:0] = sum_c1_b0;
            carry_b0 = carry_c1_b0;
        end
        else begin
            sum[3:0] = sum_c0_b0;
            carry_b0 = carry_c0_b0;
        end

        //==============================================================
        // 4c: Block 1 : bits[7:4], carry_in = carry_b0
        //==============================================================

        {carry_c0_b1, sum_c0_b1} = a[7:4] + b[7:4];
        {carry_c1_b1, sum_c1_b1} = a[7:4] + b[7:4] + 1'b1;

        if (carry_b0) begin
            sum[7:4] = sum_c1_b1;
            carry_b1 = carry_c1_b1;
        end
        else begin
            sum[7:4] = sum_c0_b1;
            carry_b1 = carry_c0_b1;
        end

        //==============================================================
        // 4d: Block 2 : bits[11:8], carry_in = carry_b1
        //==============================================================

        {carry_c0_b2, sum_c0_b2} = a[11:8] + b[11:8];
        {carry_c1_b2, sum_c1_b2} = a[11:8] + b[11:8] + 1'b1;

        if (carry_b1) begin
            sum[11:8] = sum_c1_b2;
            carry_b2  = carry_c1_b2;
        end
        else begin
            sum[11:8] = sum_c0_b2;
            carry_b2  = carry_c0_b2;
        end

        //==============================================================
        // 4e: Block 3 : bits[15:12], carry_in = carry_b2
        //==============================================================

        {carry_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];
        {carry_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1;

        if (carry_b2) begin
            sum[15:12] = sum_c1_b3;
            carry_b3   = carry_c1_b3;
        end
        else begin
            sum[15:12] = sum_c0_b3;
            carry_b3   = carry_c0_b3;
        end
        //==============================================================
        // 4f: Final Carry-Out
        //==============================================================
        cout = carry_b3;
    end
endmodule
