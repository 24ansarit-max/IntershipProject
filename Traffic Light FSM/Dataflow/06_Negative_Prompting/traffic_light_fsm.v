module traffic_light_fsm 
#( 
    parameter [15:0] TIMER_MAX = 16'd50000 
) 
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
 
    output wire north_red, 

    output wire north_yellow, 
    output wire north_green, 
    output wire north_walk, 
 
    output wire south_red, 
    output wire south_yellow, 
    output wire south_green, 
    output wire south_walk 
); 
 
    //------------------------------------------------------------------ 
    // One-Hot State Encoding 
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
    //------------------------------------------------------------------ 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    //------------------------------------------------------------------ 
    // Explicit Wire Declarations 
    //------------------------------------------------------------------ 
    wire [15:0] next_state; 
 
    //------------------------------------------------------------------ 
    // Assign-Only Next-State Logic 
    // 
    // Ring FSM: 
    // state[i] -> state[i+1] 
    // state[15] -> state[0] 
    //------------------------------------------------------------------ 
    assign next_state[0]  = state[15]; 
    assign next_state[1]  = state[0]; 
    assign next_state[2]  = state[1]; 
    assign next_state[3]  = state[2]; 

 
    assign next_state[4]  = state[3]; 
    assign next_state[5]  = state[4]; 
    assign next_state[6]  = state[5]; 
    assign next_state[7]  = state[6]; 
 
    assign next_state[8]  = state[7]; 
    assign next_state[9]  = state[8]; 
    assign next_state[10] = state[9]; 
    assign next_state[11] = state[10]; 
 
    assign next_state[12] = state[11]; 
    assign next_state[13] = state[12]; 
    assign next_state[14] = state[13]; 
    assign next_state[15] = state[14]; 
 
    //------------------------------------------------------------------ 
    // Assign-Only Output Decode 
    //------------------------------------------------------------------ 
    assign ns_red    = state[0]; 
    assign ns_yellow = state[1]; 
    assign ns_green  = state[2]; 
    assign ns_walk   = state[3]; 
 
    assign ew_red    = state[4]; 
    assign ew_yellow = state[5]; 
    assign ew_green  = state[6]; 
    assign ew_walk   = state[7]; 

 
    assign north_red    = state[8]; 
    assign north_yellow = state[9]; 
    assign north_green  = state[10]; 
    assign north_walk   = state[11]; 
 
    assign south_red    = state[12]; 
    assign south_yellow = state[13]; 
    assign south_green  = state[14]; 
    assign south_walk   = state[15]; 
 
    //------------------------------------------------------------------ 
    // Single Sequential Block 
    // Synchronous Reset 
    //------------------------------------------------------------------ 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 
    end 
 
endmodule 
 
// --------------------------------------------------------------- 
// Estimated Artix-7 Resources 
// --------------------------------------------------------------- 

// LUTs : ~16-20 
// FFs  : 16 
// 
// Critical Path: 
// state FF -> next_state routing -> state FF 
// 
// Estimated Fmax: 
// > 400 MHz on xc7a100tcsg324-2 
// 
// Notes: 
// - Pure dataflow combinational logic (assign only) 
// - Single always @(posedge clk) 
// - No latches 
// - No multiple drivers 
// - No casex/casez 
// - No simulation-only constructs 
// ---------------------------------------------------------------