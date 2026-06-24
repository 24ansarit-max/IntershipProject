//===================================================================== 
// SECTION 1: State Encoding Table 
//===================================================================== 
// 

// State Name   | 16-bit Value         | Meaning 
// --------------------------------------------------------------- 
// NS_RED       | 16'b0000_0000_0000_0001 | North/South RED 
// NS_YELLOW    | 16'b0000_0000_0000_0010 | North/South YELLOW 
// NS_GREEN     | 16'b0000_0000_0000_0100 | North/South GREEN 
// NS_WALK      | 16'b0000_0000_0000_1000 | North/South WALK 
// 
// EW_RED       | 16'b0000_0000_0001_0000 | East/West RED 
// EW_YELLOW    | 16'b0000_0000_0010_0000 | East/West YELLOW 
// EW_GREEN     | 16'b0000_0000_0100_0000 | East/West GREEN 
// EW_WALK      | 16'b0000_0000_1000_0000 | East/West WALK 
// 
// N_RED        | 16'b0000_0001_0000_0000 | North RED 
// N_YELLOW     | 16'b0000_0010_0000_0000 | North YELLOW 
// N_GREEN      | 16'b0000_0100_0000_0000 | North GREEN 
// N_WALK       | 16'b0000_1000_0000_0000 | North WALK 
// 
// S_RED        | 16'b0001_0000_0000_0000 | South RED 
// S_YELLOW     | 16'b0010_0000_0000_0000 | South YELLOW 
// S_GREEN      | 16'b0100_0000_0000_0000 | South GREEN 
// S_WALK       | 16'b1000_0000_0000_0000 | South WALK 
// 
//===================================================================== 
// SECTION 2: Boolean Equation Table 
//===================================================================== 
// 
// Signal         | Equation                                  | LUT Est. 
// -------------------------------------------------------------------- 

// timer_expire   | (timer == TIMER_MAX)                      | 4-8 
// nt             | ~timer_expire                             | 0 
// 
// next[0]        | state[0]&nt  | state[15]&timer_expire     | 1 
// next[1]        | state[1]&nt  | state[0]&timer_expire      | 1 
// next[2]        | state[2]&nt  | state[1]&timer_expire      | 1 
// ... 
// next[15]       | state[15]&nt | state[14]&timer_expire     | 1 
// 
// ns_red         | state[0]                                 | 0 
// ns_yellow      | state[1]                                 | 0 
// ns_green       | state[2]                                 | 0 
// ns_walk        | state[3]                                 | 0 
// 
// ew_red         | state[4]                                 | 0 
// ew_yellow      | state[5]                                 | 0 
// ew_green       | state[6]                                 | 0 
// ew_walk        | state[7]                                 | 0 
// 
// north_red      | state[8]                                 | 0 
// north_yellow   | state[9]                                 | 0 
// north_green    | state[10]                                | 0 
// north_walk     | state[11]                                | 0 
// 
// south_red      | state[12]                                | 0 
// south_yellow   | state[13]                                | 0 
// south_green    | state[14]                                | 0 
// south_walk     | state[15]                                | 0 

// 
//===================================================================== 
// SECTION 3: Verilog Module 
//===================================================================== 
 
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
 
    //----------------------------------------------------------------- 
    // One-Hot State Constants 
    //----------------------------------------------------------------- 
 
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
 
    //----------------------------------------------------------------- 
    // Registers 
    //----------------------------------------------------------------- 
 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    (* use_dsp = "no" *) 
    reg [15:0] timer; 
 
    wire [15:0] next_state; 
 
    //----------------------------------------------------------------- 
    // Timer Expire Equation 
    // Ref: EQ-T0 
    //----------------------------------------------------------------- 
 
    wire timer_expire; 
    wire nt; 
 
    assign timer_expire = (timer == TIMER_MAX);   // EQ-T0 
    assign nt           = ~timer_expire;          // EQ-T1 
 
    //----------------------------------------------------------------- 
    // Next-State Equations 

    // Ref: EQ-Nx 
    //----------------------------------------------------------------- 
 
    assign next_state[0]  = (state[0]  & nt) | (state[15] & timer_expire); // EQ-N0 
    assign next_state[1]  = (state[1]  & nt) | (state[0]  & timer_expire); // EQ-N1 
    assign next_state[2]  = (state[2]  & nt) | (state[1]  & timer_expire); // EQ-N2 
    assign next_state[3]  = (state[3]  & nt) | (state[2]  & timer_expire); // EQ-N3 
 
    assign next_state[4]  = (state[4]  & nt) | (state[3]  & timer_expire); // EQ-N4 
    assign next_state[5]  = (state[5]  & nt) | (state[4]  & timer_expire); // EQ-N5 
    assign next_state[6]  = (state[6]  & nt) | (state[5]  & timer_expire); // EQ-N6 
    assign next_state[7]  = (state[7]  & nt) | (state[6]  & timer_expire); // EQ-N7 
 
    assign next_state[8]  = (state[8]  & nt) | (state[7]  & timer_expire); // EQ-N8 
    assign next_state[9]  = (state[9]  & nt) | (state[8]  & timer_expire); // EQ-N9 
    assign next_state[10] = (state[10] & nt) | (state[9]  & timer_expire); // EQ-N10 
    assign next_state[11] = (state[11] & nt) | (state[10] & timer_expire); // EQ-N11 
 
    assign next_state[12] = (state[12] & nt) | (state[11] & timer_expire); // EQ-N12 
    assign next_state[13] = (state[13] & nt) | (state[12] & timer_expire); // EQ-N13 
    assign next_state[14] = (state[14] & nt) | (state[13] & timer_expire); // EQ-N14 
    assign next_state[15] = (state[15] & nt) | (state[14] & timer_expire); // EQ-N15 
 
    //----------------------------------------------------------------- 
    // Output Decode Equations 
    //----------------------------------------------------------------- 
 
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
 
    //----------------------------------------------------------------- 
    // Sequential Logic 
    // Only FF Stage 
    //----------------------------------------------------------------- 
 
    always @(posedge clk) 
    begin 
        if (rst) 
        begin 

            state <= NS_RED; 
            timer <= 16'd0; 
        end 
        else 
        begin 
            state <= next_state; 
 
            if (timer_expire) 
                timer <= 16'd0; 
            else 
                timer <= timer + 16'd1; 
        end 
    end 
 
endmodule 
 
//===================================================================== 
// SECTION 4: PPA SUMMARY 
//===================================================================== 
// 
// Estimated LUT : 28-40 
// Estimated FF  : 32 
//     state[15:0] = 16 FF 
//     timer[15:0] = 16 FF 
// 
// Estimated Fmax : 200-400 MHz (Artix-7 -2) 
// 
// Critical Path: 

//     state -> next_state mux -> state FF 
// 
// Highest Toggle Nets: 
//     timer[15:0] 
//     timer_expire 
// 
// LUT Budget (<60)      : PASS 
// Fmax (>100 MHz)       : PASS 
// No Latches            : PASS 
// Sync Reset            : PASS 
// 
// NOTE: 
// A true 16-bit one-hot FSM plus a 16-bit timer requires 
// a minimum of 32 FFs; therefore an FF budget below 32 
// is not achievable with this architecture. 
//=====================================================================