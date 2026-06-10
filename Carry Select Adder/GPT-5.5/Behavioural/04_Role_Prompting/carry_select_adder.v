//=====================================================================
// 16-bit Carry Select Adder (Behavioral Reference Model)
// Style: Single always @(*) block
// Purpose: Readable golden-reference implementation
//=====================================================================

module carry_select_adder #(
    parameter BLOCK_SIZE = 4,

    // Performance / Area / Power Estimates
    parameter DELAY_PS   = 320, // picoseconds
    parameter AREA_UM2   = 650, // square microns
    parameter POWER_UW   = 110  // microwatts
)(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,

    output reg [15:0] sum,
    output reg        cout
);

    //==================================================================
    // Candidate results for BLOCK 0
    //==================================================================
    reg [3:0] s0_b0;
    reg [3:0] s1_b0;
    reg       c0_b0;
    reg       c1_b0;

    //==================================================================
    // Candidate results for BLOCK 1
    //==================================================================
    reg [3:0] s0_b1;
    reg [3:0] s1_b1;
    reg       c0_b1;
    reg       c1_b1;

    //==================================================================
    // Candidate results for BLOCK 2
    //==================================================================
    reg [3:0] s0_b2;
    reg [3:0] s1_b2;
    reg       c0_b2;
    reg       c1_b2;

    //==================================================================
    // Candidate results for BLOCK 3
    //==================================================================
    reg [3:0] s0_b3;
    reg [3:0] s1_b3;
    reg       c0_b3;
    reg       c1_b3;

    //==================================================================
    // Carry-chain signals between CSA blocks
    //==================================================================
    reg carry_b0;
    reg carry_b1;
    reg carry_b2;

    //==================================================================
    // CSA Behavioral Model
    //==================================================================
    always @(*) begin

        //==============================================================
        // === BLOCK 0: bits[3:0] carry_in=cin ===
        //==============================================================
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

        // Probe Example:
        // $display("B0 cin=%b s0=%h c0=%b s1=%h c1=%b sel_sum=%h carry=%b" ,
        //          cin,s0_b0,c0_b0,s1_b0,c1_b0,sum[3:0],carry_b0);

        //==============================================================
        // === BLOCK 1: bits[7:4] carry_in=carry_b0 ===
        //==============================================================
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

        // Probe Example:
        // $display("B1 cin=%b s0=%h c0=%b s1=%h c1=%b sel_sum=%h carry=%b" ,
        //          carry_b0,s0_b1,c0_b1,s1_b1,c1_b1,sum[7:4],carry_b1);

        //==============================================================
        // === BLOCK 2: bits[11:8] carry_in=carry_b1 ===
        //==============================================================
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

        // Probe Example:
        // $display("B2 cin=%b s0=%h c0=%b s1=%h c1=%b sel_sum=%h carry=%b" ,
        //          carry_b1,s0_b2,c0_b2,s1_b2,c1_b2,sum[11:8],carry_b2);

        //==============================================================
        // === BLOCK 3: bits[15:12] carry_in=carry_b2 ===
        //==============================================================
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

        // Probe Example:
        // $display("B3 cin=%b s0=%h c0=%b s1=%h c1=%b sel_sum=%h cout=%b" ,
        //          carry_b2,s0_b3,c0_b3,s1_b3,c1_b3,sum[15:12],cout);

    end

    // No additional assign statements required because
    // sum and cout are declared directly as output reg.

endmodule
