//===================================================================== 
// 1. MODULE HEADER 
//===================================================================== 
// Module : traffic_light_fsm 
// Author : OpenAI 
// Target : xc7a100tcsg324-2 (Nexys A7, Artix-7) 
// 
// PPA Budget Notes 
// ---------------- 
// Fmax Target : > 100 MHz 
// Critical Path: 

//     state_reg -> next_state case decode -> state_reg 
// 
// LUT Budget  : < 50 LUT 
// Heaviest Logic: 
//     next_state case mux network 
// 
// FF Budget   : ≤ 20 requested by spec 
// Actual: 
//     state[15:0] = 16 FF 
//     timer[15:0] = 16 FF 
//     Total       = 32 FF 
// NOTE: A 16-bit one-hot FSM + 16-bit timer cannot physically 
// meet a ≤20 FF budget. 
// 
// Dynamic Power: 
//     Highest toggle signals: 
//     timer[15:0] 
//     timer_expire 
// 
//===================================================================== 
 
module traffic_light_fsm 
#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
) 
( 
    //============================================================= 
    // 3. PORT DECLARATION 

    //============================================================= 
    input  wire clk,          // system clock 
    input  wire rst,          // synchronous reset 
 
    output reg red_n, 
    output reg yellow_n, 
    output reg green_n, 
    output reg walk_n, 
 
    output reg red_s, 
    output reg yellow_s, 
    output reg green_s, 
    output reg walk_s, 
 
    output reg red_e, 
    output reg yellow_e, 
    output reg green_e, 
    output reg walk_e, 
 
    output reg red_w, 
    output reg yellow_w, 
    output reg green_w, 
    output reg walk_w 
); 
 
    //================================================================= 
    // 8. SYNTHESIS ATTRIBUTES 
    //================================================================= 

    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    (* use_dsp = "no" *) 
    reg [15:0] timer; 
 
    reg [15:0] next_state; 
 
    wire timer_expire; 
 
    //================================================================= 
    // 2. PARAMETERS 
    // One-Hot 16-bit State Encoding 
    //================================================================= 
 
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
 
    assign timer_expire = (timer == 16'd0); 
 
    //================================================================= 
    // 4. STATE REGISTER BLOCK 
    //================================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 
    end 
 
    //================================================================= 
    // 5. NEXT-STATE LOGIC BLOCK 
    // Full Coverage 
    // Default Recovery State 
    //================================================================= 
    always @(*) 
    begin 

        next_state = NS_RED; 
 
        casex (state) 
 
            NS_RED: 
                next_state = timer_expire ? NS_YELLOW : NS_RED; 
 
            NS_YELLOW: 
                next_state = timer_expire ? NS_GREEN : NS_YELLOW; 
 
            NS_GREEN: 
                next_state = timer_expire ? NS_WALK : NS_GREEN; 
 
            NS_WALK: 
                next_state = timer_expire ? EW_RED : NS_WALK; 
 
            EW_RED: 
                next_state = timer_expire ? EW_YELLOW : EW_RED; 
 
            EW_YELLOW: 
                next_state = timer_expire ? EW_GREEN : EW_YELLOW; 
 
            EW_GREEN: 
                next_state = timer_expire ? EW_WALK : EW_GREEN; 
 
            EW_WALK: 
                next_state = timer_expire ? N_RED : EW_WALK; 
 

            N_RED: 
                next_state = timer_expire ? N_YELLOW : N_RED; 
 
            N_YELLOW: 
                next_state = timer_expire ? N_GREEN : N_YELLOW; 
 
            N_GREEN: 
                next_state = timer_expire ? N_WALK : N_GREEN; 
 
            N_WALK: 
                next_state = timer_expire ? S_RED : N_WALK; 
 
            S_RED: 
                next_state = timer_expire ? S_YELLOW : S_RED; 
 
            S_YELLOW: 
                next_state = timer_expire ? S_GREEN : S_YELLOW; 
 
            S_GREEN: 
                next_state = timer_expire ? S_WALK : S_GREEN; 
 
            S_WALK: 
                next_state = timer_expire ? NS_RED : S_WALK; 
 
            default: 
                next_state = NS_RED; 
 
        endcase 

    end 
 
    //================================================================= 
    // 6. OUTPUT DECODE BLOCK 
    // Fully Assigned 
    // No Latches 
    //================================================================= 
    always @(*) 
    begin 
 
        red_n    = 1'b0; 
        yellow_n = 1'b0; 
        green_n  = 1'b0; 
        walk_n   = 1'b0; 
 
        red_s    = 1'b0; 
        yellow_s = 1'b0; 
        green_s  = 1'b0; 
        walk_s   = 1'b0; 
 
        red_e    = 1'b0; 
        yellow_e = 1'b0; 
        green_e  = 1'b0; 
        walk_e   = 1'b0; 
 
        red_w    = 1'b0; 
        yellow_w = 1'b0; 
        green_w  = 1'b0; 

        walk_w   = 1'b0; 
 
        case (state) 
 
            NS_RED:    red_n    = 1'b1; 
            NS_YELLOW: yellow_n = 1'b1; 
            NS_GREEN:  green_n  = 1'b1; 
            NS_WALK:   walk_n   = 1'b1; 
 
            EW_RED:    red_e    = 1'b1; 
            EW_YELLOW: yellow_e = 1'b1; 
            EW_GREEN:  green_e  = 1'b1; 
            EW_WALK:   walk_e   = 1'b1; 
 
            N_RED:     red_n    = 1'b1; 
            N_YELLOW:  yellow_n = 1'b1; 
            N_GREEN:   green_n  = 1'b1; 
            N_WALK:    walk_n   = 1'b1; 
 
            S_RED:     red_s    = 1'b1; 
            S_YELLOW:  yellow_s = 1'b1; 
            S_GREEN:   green_s  = 1'b1; 
            S_WALK:    walk_s   = 1'b1; 
 
            default: 
            begin 
                red_n = 1'b1; 
                red_s = 1'b1; 

                red_e = 1'b1; 
                red_w = 1'b1; 
            end 
 
        endcase 
    end 
 
    //================================================================= 
    // 7. TIMER BLOCK 
    // 16-bit Countdown Timer 
    // Generates timer_expire pulse 
    //================================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= PHASE_TIME; 
 
        else if (timer_expire) 
            timer <= PHASE_TIME; 
 
        else 
            timer <= timer - 16'd1; 
    end 
 
endmodule