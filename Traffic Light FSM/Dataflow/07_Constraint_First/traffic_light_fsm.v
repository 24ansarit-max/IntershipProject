module traffic_light_fsm 
( 
    input  wire clk, 
    input  wire rst, 
 
    output wire ns_red, 
    output wire ns_yellow, 
    output wire ns_green, 
    output wire ns_walk, 
 

    output wire ew_red, 
    output wire ew_yellow, 
    output wire ew_green, 
    output wire ew_walk, 
 
    output wire n_red, 
    output wire n_yellow, 
    output wire n_green, 
    output wire n_walk, 
 
    output wire s_red, 
    output wire s_yellow, 
    output wire s_green, 
    output wire s_walk 
); 
 
    //------------------------------------------------------------------ 
    // [C4] 16-bit One-Hot State Encoding 
    //------------------------------------------------------------------ 
    localparam [15:0] 
        NS_RED    = 16'h0001, 
        NS_YELLOW = 16'h0002, 
        NS_GREEN  = 16'h0004, 
        NS_WALK   = 16'h0008, 
 
        EW_RED    = 16'h0010, 
        EW_YELLOW = 16'h0020, 
        EW_GREEN  = 16'h0040, 

        EW_WALK   = 16'h0080, 
 
        N_RED     = 16'h0100, 
        N_YELLOW  = 16'h0200, 
        N_GREEN   = 16'h0400, 
        N_WALK    = 16'h0800, 
 
        S_RED     = 16'h1000, 
        S_YELLOW  = 16'h2000, 
        S_GREEN   = 16'h4000, 
        S_WALK    = 16'h8000; 
 
    //------------------------------------------------------------------ 
    // State Register 
    // [C5] Synchronous active-high reset 
    // [C7] Single sequential block 
    //------------------------------------------------------------------ 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    wire [15:0] next_state; 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 

    end 
 
    //------------------------------------------------------------------ 
    // Next-State Logic 
    // Ring FSM 
    // [C1] depth=1 LUT6 
    // [C2] one LUT shared per bit route 
    //------------------------------------------------------------------ 
    assign next_state[0]  = state[15]; // [C1] depth=1 LUT6 
    assign next_state[1]  = state[0];  // [C1] depth=1 LUT6 
    assign next_state[2]  = state[1];  // [C1] depth=1 LUT6 
    assign next_state[3]  = state[2];  // [C1] depth=1 LUT6 
 
    assign next_state[4]  = state[3];  // [C1] depth=1 LUT6 
    assign next_state[5]  = state[4];  // [C1] depth=1 LUT6 
    assign next_state[6]  = state[5];  // [C1] depth=1 LUT6 
    assign next_state[7]  = state[6];  // [C1] depth=1 LUT6 
 
    assign next_state[8]  = state[7];  // [C1] depth=1 LUT6 
    assign next_state[9]  = state[8];  // [C1] depth=1 LUT6 
    assign next_state[10] = state[9];  // [C1] depth=1 LUT6 
    assign next_state[11] = state[10]; // [C1] depth=1 LUT6 
 
    assign next_state[12] = state[11]; // [C1] depth=1 LUT6 
    assign next_state[13] = state[12]; // [C1] depth=1 LUT6 
    assign next_state[14] = state[13]; // [C1] depth=1 LUT6 
    assign next_state[15] = state[14]; // [C1] depth=1 LUT6 
 

    //------------------------------------------------------------------ 
    // Output Decode 
    // [C1] direct bit decode, depth=0/1 LUT 
    // [C2] no duplicated decode logic 
    //------------------------------------------------------------------ 
    assign ns_red    = state[0];  // [C1] depth=0 route 
    assign ns_yellow = state[1];  // [C1] depth=0 route 
    assign ns_green  = state[2];  // [C1] depth=0 route 
    assign ns_walk   = state[3];  // [C1] depth=0 route 
 
    assign ew_red    = state[4];  // [C1] depth=0 route 
    assign ew_yellow = state[5];  // [C1] depth=0 route 
    assign ew_green  = state[6];  // [C1] depth=0 route 
    assign ew_walk   = state[7];  // [C1] depth=0 route 
 
    assign n_red     = state[8];  // [C1] depth=0 route 
    assign n_yellow  = state[9];  // [C1] depth=0 route 
    assign n_green   = state[10]; // [C1] depth=0 route 
    assign n_walk    = state[11]; // [C1] depth=0 route 
 
    assign s_red     = state[12]; // [C1] depth=0 route 
    assign s_yellow  = state[13]; // [C1] depth=0 route 
    assign s_green   = state[14]; // [C1] depth=0 route 
    assign s_walk    = state[15]; // [C1] depth=0 route 
 
endmodule 
 
// -------------------------------------------------------------------- 

// Constraint-Oriented Notes 
// -------------------------------------------------------------------- 
// [C1] Critical path: 
//      state FF -> routing -> state FF 
//      Single LUT level maximum. 
// 
// [C2] Estimated LUT6: 
//      ~16 LUTs (routing may optimize further) 
//      Well below 48 LUT target. 
// 
// [C3] Dynamic power: 
//      Only one state bit toggles off and one toggles on each cycle. 
//      One-hot ring minimizes switching activity. 
// 
// [C4] State encoding: 
//      16-bit one-hot localparam encoding. 
// 
// [C5] Reset: 
//      Synchronous active-high. 
// 
// [C6] No latches: 
//      No combinational always blocks. 
// 
// [C7] Style: 
//      Assign-only combinational logic. 
//      Single always @(posedge clk) state register. 
// --------------------------------------------------------------------