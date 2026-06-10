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
    // Carry chain registers
    //==========================================================
    reg carry_b0;
    reg carry_b1;
    reg carry_b2;

    //==========================================================
    // Block 0 candidate sums/carries
    //==========================================================
    reg [3:0] s0_b0, s1_b0;
    reg       c0_b0, c1_b0;

    //==========================================================
    // Block 1 candidate sums/carries
    //==========================================================
    reg [3:0] s0_b1, s1_b1;
    reg       c0_b1, c1_b1;

    //==========================================================
    // Block 2 candidate sums/carries
    //==========================================================
    reg [3:0] s0_b2, s1_b2;
    reg       c0_b2, c1_b2;

    //==========================================================
    // Block 3 candidate sums/carries
    //==========================================================
    reg [3:0] s0_b3, s1_b3;
    reg       c0_b3, c1_b3;

    always @(*) begin

        //======================================================
        // Block 0 : bits [3:0]
        // carry_in = cin
        //======================================================
        {c0_b0, s0_b0} = a[3:0] + b[3:0];
        {c1_b0, s1_b0} = a[3:0] + b[3:0] + 1'b1;

        if (cin) begin
            sum[3:0] = s1_b0;
            carry_b0 = c1_b0;
        end
        else begin
            sum[3:0] = s0_b0;
            carry_b0 = c0_b0;
        end

        //======================================================
        // Block 1 : bits [7:4]
        // carry_in = carry_b0
        //======================================================
        {c0_b1, s0_b1} = a[7:4] + b[7:4];
        {c1_b1, s1_b1} = a[7:4] + b[7:4] + 1'b1;

        if (carry_b0) begin
            sum[7:4] = s1_b1;
            carry_b1 = c1_b1;
        end
        else begin
            sum[7:4] = s0_b1;
            carry_b1 = c0_b1;
        end

        //======================================================
        // Block 2 : bits [11:8]
        // carry_in = carry_b1
        //======================================================
        {c0_b2, s0_b2} = a[11:8] + b[11:8];
        {c1_b2, s1_b2} = a[11:8] + b[11:8] + 1'b1;

        if (carry_b1) begin
            sum[11:8] = s1_b2;
            carry_b2  = c1_b2;
        end
        else begin
            sum[11:8] = s0_b2;
            carry_b2  = c0_b2;
        end

        //======================================================
        // Block 3 : bits [15:12]
        // carry_in = carry_b2
        //======================================================
        {c0_b3, s0_b3} = a[15:12] + b[15:12];
        {c1_b3, s1_b3} = a[15:12] + b[15:12] + 1'b1;

        if (carry_b2) begin
            sum[15:12] = s1_b3;
            cout       = c1_b3;
        end
        else begin
            sum[15:12] = s0_b3;
            cout       = c0_b3;
        end

    end

endmodule
