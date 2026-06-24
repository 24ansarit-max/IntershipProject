// ============================================ 
// Module      : shift_reg_16 
// Style       : Dataflow (assign + operators) 
// Target      : xc7a100tcsg324-2 (Nexys A7) 

// PPA Goals   : Area ≤28 LUT | Fmax >100 MHz 
// Loop types  : generate/for (right) | generate/while-style (left) 
// Reset       : Synchronous active-high 
// ============================================ 
 
module shift_reg_16 #( 
 
    // ============================================ 
    // [PARAMETER SECTION] 
    // ============================================ 
 
    parameter WIDTH = 16 // Register width 
)( 
    // ============================================ 
    // [PORT DECLARATION] 
    // ============================================ 
 
    input  wire              clk,        // Input  : System clock 
    input  wire              rst,        // Input  : Synchronous active-high reset 
    input  wire [1:0]        mode,       // Input  : 00=hold 01=right 10=left 11=load 
    input  wire              serial_in,  // Input  : Serial shift input 
    input  wire [WIDTH-1:0]  data_in,    // Input  : Parallel load data 
    output reg  [WIDTH-1:0]  q           // Output : Registered shift-register contents 
); 
 
    // ============================================ 
    // [WIRE DECLARATIONS] 
    // ============================================ 

 
    wire [WIDTH-1:0] r_taps;             // Right-shift tap network, WIDTH nets 
    wire [WIDTH-1:0] l_taps;             // Left-shift tap network, WIDTH nets 
    wire [WIDTH-1:0] next_q;             // Next-state mux output, WIDTH nets 
 
    // ============================================ 
    // [GENERATE BLOCK A — right-shift taps] 
    // ============================================ 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right 
            assign r_taps[i] = q[i+1];   // AREA: wire tap, 0 LUTs | TIMING: 0 logic levels 
        end 
    endgenerate 
 
    assign r_taps[WIDTH-1] = serial_in;  // AREA: wire tap, 0 LUTs | TIMING: 0 logic levels 
 
    // ============================================ 
    // [GENERATE BLOCK B — left-shift taps] 
    // ============================================ 
 
    genvar j; 
 
    generate 
        for (j = WIDTH-1; j > 0; j = j - 1) begin : gen_left 
            assign l_taps[j] = q[j-1];   // AREA: wire tap | TIMING: 0 logic levels 

        end 
    endgenerate 
 
    assign l_taps[0] = serial_in;        // AREA: wire tap | TIMING: 0 logic levels 
 
    // ============================================ 
    // [COMBINATIONAL MUX ASSIGNS] 
    // ============================================ 
 
    assign next_q = 
           (mode == 2'b01) ? r_taps  : 
           (mode == 2'b10) ? l_taps  : 
           (mode == 2'b11) ? data_in : 
                             q; 
    // TIMING: Critical path = mode decode -> mux -> FDRE D input 
 
    // ============================================ 
    // [REGISTERED OUTPUT — ONLY ALWAYS BLOCK ALLOWED] 
    // ============================================ 
 
    always @(posedge clk) begin 
        if (rst) 
            q <= {WIDTH{1'b0}}; 
        else 
            q <= next_q; 
    end 
 
    // ============================================ 

    // [PPA SUMMARY] 
    // ============================================ 
    // ====== PPA ESTIMATE ====== 
    // LUTs   : 16-24 
    // FFs    : 16 
    // Fmax   : >100 MHz 
    // Power  : ~1-3 mW @ 12.5% toggle 
    // ========================== 
 
endmodule