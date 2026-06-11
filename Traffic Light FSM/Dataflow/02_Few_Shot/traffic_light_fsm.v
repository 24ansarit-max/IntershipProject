`timescale 1ns/1ps 
//============================================================= 
// 16-State Traffic Light FSM 
// Dataflow Next-State Logic (assign/ternary style) 
// Target : xc7a100tcsg324-2 (Nexys A7) 
// 
// Architecture 
// ------------ 
// - 16-bit one-hot state encoding 
// - Single sequential always block (state register only) 
// - All combinational logic implemented using assign 
// - 4 intersections (I0..I3) 
// - Each intersection has Red/Yellow/Green outputs 
// - Synchronous reset 
// 
// State Sequence 
// -------------- 
// I0_R -> I0_Y -> I0_G -> 
// I1_R -> I1_Y -> I1_G -> 
// I2_R -> I2_Y -> I2_G -> 
// I3_R -> I3_Y -> I3_G -> 
// back to I0_R 
// 
// One-hot encoding minimizes decode logic. 
// Most outputs reduce directly to state bits. 
//============================================================= 
 

module traffic_light_fsm_dataflow 
( 
    input  wire       clk, 
    input  wire       rst, 
 
    output wire [3:0] red, 
    output wire [3:0] yellow, 
    output wire [3:0] green 
); 
 
    //--------------------------------------------------------- 
    // 16-bit One-Hot State Encoding 
    //--------------------------------------------------------- 
    localparam [15:0] I0_R = 16'h0001; 
    localparam [15:0] I0_Y = 16'h0002; 
    localparam [15:0] I0_G = 16'h0004; 
 
    localparam [15:0] I1_R = 16'h0008; 
    localparam [15:0] I1_Y = 16'h0010; 
    localparam [15:0] I1_G = 16'h0020; 
 
    localparam [15:0] I2_R = 16'h0040; 
    localparam [15:0] I2_Y = 16'h0080; 
    localparam [15:0] I2_G = 16'h0100; 
 
    localparam [15:0] I3_R = 16'h0200; 
    localparam [15:0] I3_Y = 16'h0400; 
    localparam [15:0] I3_G = 16'h0800; 

 
    // Spare states (unused but defined) 
    localparam [15:0] S12  = 16'h1000; 
    localparam [15:0] S13  = 16'h2000; 
    localparam [15:0] S14  = 16'h4000; 
    localparam [15:0] S15  = 16'h8000; 
 
    //--------------------------------------------------------- 
    // State Register 
    //--------------------------------------------------------- 
    reg  [15:0] state; 
    wire [15:0] next_state; 
 
    //--------------------------------------------------------- 
    // State Register FF Stage 
    // Only sequential logic in design 
    //--------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= I0_R; 
        else 
            state <= next_state; 
    end 
 
    //--------------------------------------------------------- 
    // Next-State Logic 
    // 

    // Ternary chain maps directly to cascaded muxes. 
    // One-hot encoding allows synthesis to optimize 
    // comparisons into single-bit tests. 
    //--------------------------------------------------------- 
    assign next_state = 
           (state == I0_R) ? I0_Y : 
           (state == I0_Y) ? I0_G : 
           (state == I0_G) ? I1_R : 
 
           (state == I1_R) ? I1_Y : 
           (state == I1_Y) ? I1_G : 
           (state == I1_G) ? I2_R : 
 
           (state == I2_R) ? I2_Y : 
           (state == I2_Y) ? I2_G : 
           (state == I2_G) ? I3_R : 
 
           (state == I3_R) ? I3_Y : 
           (state == I3_Y) ? I3_G : 
           (state == I3_G) ? I0_R : 
 
                             I0_R; 
 
    //--------------------------------------------------------- 
    // Output Decode 
    // 
    // Boolean Reduction Opportunity: 
    // Since states are one-hot, outputs can be formed 

    // as ORs of state bits rather than full equality 
    // comparisons. 
    // 
    // Example: 
    // red[0] = state[I0_R_bit] 
    // 
    // This minimizes LUT depth and routing. 
    //--------------------------------------------------------- 
 
    // Intersection 0 
    assign red[0]    = state[0]; 
    assign yellow[0] = state[1]; 
    assign green[0]  = state[2]; 
 
    // Intersection 1 
    assign red[1]    = state[3]; 
    assign yellow[1] = state[4]; 
    assign green[1]  = state[5]; 
 
    // Intersection 2 
    assign red[2]    = state[6]; 
    assign yellow[2] = state[7]; 
    assign green[2]  = state[8]; 
 
    // Intersection 3 
    assign red[3]    = state[9]; 
    assign yellow[3] = state[10]; 
    assign green[3]  = state[11]; 

 
    //--------------------------------------------------------- 
    // Additional Reduction Notes 
    // 
    // 1. Output decode becomes pure wiring because 
    //    each output maps directly to a one-hot state bit. 
    // 
    // 2. Synthesis may replace equality tests with 
    //    single-bit checks due to one-hot encoding. 
    // 
    // 3. Critical path: 
    //      state FF -> next_state mux -> FF 
    // 
    // 4. Artix-7 implementation typically fits in 
    //    < 30 LUTs and 16 FFs. 
    // 
    // 5. Expected Fmax: 
    //      200-400 MHz on xc7a100tcsg324-2. 
    //--------------------------------------------------------- 
 
endmodule