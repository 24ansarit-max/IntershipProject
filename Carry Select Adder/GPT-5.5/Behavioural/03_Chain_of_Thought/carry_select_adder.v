//==============================================================
// 16-bit Carry Select Adder (Behavioral Style)
//--------------------------------------------------------------
// PPA Estimates
//   DELAY_PS = 320
//     ≈ one 4-bit adder delay + carry-select mux delay
//
//   AREA_UM2 = 650
//     ≈ 2x logic duplication versus ripple-carry
//
//   POWER_UW = 110
//     α = 0.1, VDD = 1.0V , Freq = 1GHz
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
    output reg [15:0] sum,
    output reg        cout
);

    //==========================================================
    // Candidate sums/carries : cin = 0
    //==========================================================
    reg [3:0] sum_c0_b0;
    reg [3:0] sum_c0_b1;
    reg [3:0] sum_c0_b2;
    reg [3:0] sum_c0_b3;

    reg carry_c0_b0;
    reg carry_c0_b1;
    reg carry_c0_b2;
    reg carry_c0_b3;

    //==========================================================
    // Candidate sums/carries : cin = 1
    //==========================================================
    reg [3:0] sum_c1_b0;
    reg [3:0] sum_c1_b1;
    reg [3:0] sum_c1_b2;
    reg [3:0] sum_c1_b3;

    reg carry_c1_b0;
    reg carry_c1_b1;
    reg carry_c1_b2;
    reg carry_c1_b3;

    //==========================================================
    // Carry chain registers
    //==========================================================
    reg carry_b0;
    reg carry_b1;
    reg carry_b2;

    //==========================================================
    // Carry Select Logic
    //==========================================================
    always @(*) begin

        //------------------------------------------------------
        // Block 0 : bits [3:0]
        // carry_in = cin
        //------------------------------------------------------
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

        //------------------------------------------------------
        // Block 1 : bits [7:4]
        // carry_in = carry_b0
        //------------------------------------------------------
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

        //------------------------------------------------------
        // Block 2 : bits [11:8]
        // carry_in = carry_b1
        //------------------------------------------------------
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

        //------------------------------------------------------
        // Block 3 : bits [15:12]
        // carry_in = carry_b2
        //------------------------------------------------------
        {carry_c0_b3, sum_c0_b3} = a[15:12] + b[15:12];
        {carry_c1_b3, sum_c1_b3} = a[15:12] + b[15:12] + 1'b1;

        if (carry_b2) begin
            sum[15:12] = sum_c1_b3;
            cout        = carry_c1_b3;
        end
        else begin
            sum[15:12] = sum_c0_b3;
            cout        = carry_c0_b3;
        end

    end

endmodule
