//==============================================================
// 16-bit Carry Select Adder (Behavioral Style)
//==============================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,

    // Target implementation metrics
    parameter DELAY_PS   = 320, // Critical path delay (ps)
    parameter AREA_UM2   = 650, // Area (um^2)
    parameter POWER_UW   = 110  // Power (uW)
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output reg [15:0] sum,
    output reg        cout
);

    // Carry propagation between blocks
    reg carry_b1;
    reg carry_b2;
    reg carry_b3;

    // Candidate sums and carries for Block 0
    reg [3:0] b0_s0, b0_s1;
    reg       b0_c0, b0_c1;

    // Candidate sums and carries for Block 1
    reg [3:0] b1_s0, b1_s1;
    reg       b1_c0, b1_c1;

    // Candidate sums and carries for Block 2
    reg [3:0] b2_s0, b2_s1;
    reg       b2_c0, b2_c1;

    // Candidate sums and carries for Block 3
    reg [3:0] b3_s0, b3_s1;
    reg       b3_c0, b3_c1;

    always @(*) begin

        //======================================================
        // Block 0 : bits [3:0]
        //======================================================
        {b0_c0, b0_s0} = a[3:0]  + b[3:0];
        {b0_c1, b0_s1} = a[3:0]  + b[3:0] + 1'b1;

        if (cin) begin
            sum[3:0] = b0_s1;
            carry_b1 = b0_c1;
        end
        else begin
            sum[3:0] = b0_s0;
            carry_b1 = b0_c0;
        end

        //======================================================
        // Block 1 : bits [7:4]
        //======================================================
        {b1_c0, b1_s0} = a[7:4]  + b[7:4];
        {b1_c1, b1_s1} = a[7:4]  + b[7:4] + 1'b1;

        if (carry_b1) begin
            sum[7:4] = b1_s1;
            carry_b2 = b1_c1;
        end
        else begin
            sum[7:4] = b1_s0;
            carry_b2 = b1_c0;
        end

        //======================================================
        // Block 2 : bits [11:8]
        //======================================================
        {b2_c0, b2_s0} = a[11:8] + b[11:8];
        {b2_c1, b2_s1} = a[11:8] + b[11:8] + 1'b1;

        if (carry_b2) begin
            sum[11:8] = b2_s1;
            carry_b3  = b2_c1;
        end
        else begin
            sum[11:8] = b2_s0;
            carry_b3  = b2_c0;
        end

        //======================================================
        // Block 3 : bits [15:12]
        //======================================================
        {b3_c0, b3_s0} = a[15:12] + b[15:12];
        {b3_c1, b3_s1} = a[15:12] + b[15:12] + 1'b1;

        if (carry_b3) begin
            sum[15:12] = b3_s1;
            cout       = b3_c1;
        end
        else begin
            sum[15:12] = b3_s0;
            cout       = b3_c0;
        end

    end

endmodule
