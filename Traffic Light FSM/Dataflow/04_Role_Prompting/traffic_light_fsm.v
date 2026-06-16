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
 
    //========================================================== 
    // One-Hot State Encoding 
    // Vivado Hint: 
    // (* fsm_encoding = "one_hot" *) 
    // 
    // Ring ordering minimizes simultaneous switching: 
    // only two state bits toggle on transition. 
    //========================================================== 
 
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
 
    //---------------------------------------------------------- 
    // Registers 
    //---------------------------------------------------------- 
 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    reg [15:0] timer; 
 
    //---------------------------------------------------------- 
    // Timer Expire 
    // 
    // Shared term used by all next-state equations. 
    // Vivado typically routes this through dedicated carry/LUT 
    // logic and shares the inversion globally. 
    //---------------------------------------------------------- 
 
    wire timer_expire; 
    wire timer_not_expire; 
 
    assign timer_expire     = (timer == TIMER_MAX); 

    assign timer_not_expire = ~timer_expire; 
 
    //---------------------------------------------------------- 
    // Next-State Logic 
    // 
    // Each equation: 
    // next[i] = state[i] & ~expire 
    //         | prev_state & expire 
    // 
    // Maps efficiently into LUT6 as a 2:1 mux. 
    // Expected ~16 LUT6 total. 
    //---------------------------------------------------------- 
 
    wire [15:0] next_state; 
 
    assign next_state[0]  = (state[0]  & timer_not_expire) | (state[15] & timer_expire); 
    assign next_state[1]  = (state[1]  & timer_not_expire) | (state[0]  & timer_expire); 
    assign next_state[2]  = (state[2]  & timer_not_expire) | (state[1]  & timer_expire); 
    assign next_state[3]  = (state[3]  & timer_not_expire) | (state[2]  & timer_expire); 
 
    assign next_state[4]  = (state[4]  & timer_not_expire) | (state[3]  & timer_expire); 
    assign next_state[5]  = (state[5]  & timer_not_expire) | (state[4]  & timer_expire); 
    assign next_state[6]  = (state[6]  & timer_not_expire) | (state[5]  & timer_expire); 
    assign next_state[7]  = (state[7]  & timer_not_expire) | (state[6]  & timer_expire); 
 
    assign next_state[8]  = (state[8]  & timer_not_expire) | (state[7]  & timer_expire); 
    assign next_state[9]  = (state[9]  & timer_not_expire) | (state[8]  & timer_expire); 
    assign next_state[10] = (state[10] & timer_not_expire) | (state[9]  & timer_expire); 

    assign next_state[11] = (state[11] & timer_not_expire) | (state[10] & timer_expire); 
 
    assign next_state[12] = (state[12] & timer_not_expire) | (state[11] & timer_expire); 
    assign next_state[13] = (state[13] & timer_not_expire) | (state[12] & timer_expire); 
    assign next_state[14] = (state[14] & timer_not_expire) | (state[13] & timer_expire); 
    assign next_state[15] = (state[15] & timer_not_expire) | (state[14] & timer_expire); 
 
    //---------------------------------------------------------- 
    // Output Decode 
    // 
    // Direct state-bit extraction. 
    // No decode tree. 
    // Usually absorbed into routing with near-zero LUT cost. 
    //---------------------------------------------------------- 
 
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
 
    //---------------------------------------------------------- 
    // State Register 
    // 
    // Critical Path: 
    // state FF -> LUT mux -> state FF 
    // 
    // Artix-7 estimate: 
    // ~2 ns to 3 ns 
    // Fmax > 250 MHz typical 
    //---------------------------------------------------------- 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 
    end 
 
    //---------------------------------------------------------- 
    // 16-bit Timer Register 

    // 
    // Carry-chain implementation. 
    // Timer reload occurs only on phase boundary. 
    //---------------------------------------------------------- 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= 16'd0; 
        else if (timer_expire) 
            timer <= 16'd0; 
        else 
            timer <= timer + 16'd1; 
    end 
 
    //---------------------------------------------------------- 
    // Estimated Artix-7 Resources 
    // 
    // State FFs : 16 
    // Timer FFs : 16 
    // Total FFs : 32 
    // 
    // Next-State LUTs : ~16 
    // Timer Compare   : ~8-16 
    // Misc Routing    : ~4-8 
    // 
    // Total LUT6      : ~28-40 
    // 

    // Estimated Fmax  : >200 MHz 
    // Meets 105 MHz target comfortably 
    //---------------------------------------------------------- 
 
endmodule