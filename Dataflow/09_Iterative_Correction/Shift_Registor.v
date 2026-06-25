module shift_reg_16 #( 
    parameter WIDTH = 16 
)( 
    input  wire              clk, 
    input  wire              rst, 
    input  wire [1:0]        mode,       // 00=hold 01=right 10=left 11=load 
    input  wire              serial_in, 
    input  wire [WIDTH-1:0]  data_in, 
    output reg  [WIDTH-1:0]  q 
); 
 
    // ============================================================ 
    // ITERATION 1 — Dataflow baseline (right-shift, assign operator) 
    // ============================================================ 
    // wire [WIDTH-1:0] iter1_next_q; 
    // assign iter1_next_q = {serial_in, q[WIDTH-1:1]}; 
    // TIMING: routing + register setup path 
 
    // ============================================================ 
    // ITERATION 2 — Generate/for right-tap wires 
    // ============================================================ 
 
    wire [WIDTH-1:0] r_tap;              // AREA: wire-only right-shift network 
 
    genvar i; 
 
    generate 

        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right 
            assign r_tap[i] = q[i+1];    // AREA: direct wire, 0 LUTs 
        end 
    endgenerate 
 
    assign r_tap[WIDTH-1] = serial_in;   // AREA: direct wire, 0 LUTs 
 
    // ============================================================ 
    // ITERATION 3 — Generate/for descending left-shift wires 
    // ============================================================ 
 
    wire [WIDTH-1:0] l_tap;              // AREA: wire-only left-shift network 
 
    genvar j; 
 
    generate 
        for (j = WIDTH-1; j > 0; j = j - 1) begin : gen_left 
            assign l_tap[j] = q[j-1];    // AREA: direct wire, 0 LUTs 
        end 
    endgenerate 
 
    assign l_tap[0] = serial_in;         // AREA: direct wire, 0 LUTs 
 
    // TIMING: bidirectional select would be: 
    // assign next_q = dir ? l_tap : r_tap; 
 
    // ============================================================ 
    // ITERATION 4 — 4-mode mux + PPA annotations 

    // ============================================================ 
 
    wire [WIDTH-1:0] next_q;             // TIMING: mux output to FDRE D-input 
    wire             ce;                 // POWER: CE inference signal 
 
    assign next_q = 
           (mode == 2'b01) ? r_tap   :   // TIMING: mux level 
           (mode == 2'b10) ? l_tap   :   // TIMING: mux level 
           (mode == 2'b11) ? data_in :   // TIMING: mux level 
                             q;          // TIMING: hold path 
 
    assign ce = (mode != 2'b00);         // POWER: disable register updates in hold mode 
 
    // AREA: estimated LUT usage ≈ 16-24 LUTs 
    // TIMING: critical path = mode mux depth + FDRE setup 
 
    // ============================================================ 
    // ITERATION 5 — Final reviewed implementation 
    // ============================================================ 
    // Checked: 
    // - No latches 
    // - No asynchronous reset 
    // - No blocking assignments in clocked logic 
    // - All mux arms defined 
    // - Single always block only 
 
    always @(posedge clk) begin 
        if (rst) 

            q <= {WIDTH{1'b0}}; 
        else if (ce)                     // POWER: CE guard 
            q <= next_q; 
    end 
 
endmodule