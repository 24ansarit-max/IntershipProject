module traffic_light_fsm 

#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
 
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
    // State Encoding Section 
    // 16-bit One-Hot FSM 
    //================================================================= 
    localparam [15:0] 
        N_RED    = 16'h0001, 
        N_YELLOW = 16'h0002, 
        N_GREEN  = 16'h0004, 
        N_WALK   = 16'h0008, 
 
        S_RED    = 16'h0010, 
        S_YELLOW = 16'h0020, 
        S_GREEN  = 16'h0040, 
        S_WALK   = 16'h0080, 
 
        E_RED    = 16'h0100, 
        E_YELLOW = 16'h0200, 
        E_GREEN  = 16'h0400, 
        E_WALK   = 16'h0800, 
 
        W_RED    = 16'h1000, 
        W_YELLOW = 16'h2000, 
        W_GREEN  = 16'h4000, 
        W_WALK   = 16'h8000; 
 
    //================================================================= 
    // State Register 
    // Estimated FFs: 

    //   state[15:0] = 16 FF 
    //================================================================= 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
    reg [15:0] next_state; 
 
    //================================================================= 
    // Timer Section 
    // Estimated FFs: 
    //   timer[15:0] = 16 FF 
    // 
    // Total Estimated FF Count ≈ 32 
    //================================================================= 
    reg [15:0] timer; 
    wire timer_expire; 
 
    assign timer_expire = (timer == 16'd0); 
 
    //================================================================= 
    // State Register Block 
    // Critical Path: 
    // state_reg -> next_state_logic -> state_reg 
    //================================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= N_RED; 
        else 

            state <= next_state; 
    end 
 
    //================================================================= 
    // Timer Register Block 
    // Countdown timer 
    // Reloads automatically on state transition 
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
 
    //================================================================= 
    // Next-State Logic Section 
    // Default assignment prevents latch inference 
    // Full case coverage with default branch 
    //================================================================= 
    always @(*) 
    begin 
        next_state = N_RED; 
 
        case (state) 

 
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
                next_state = timer_expire ? E_RED : S_WALK; 
 
            E_RED: 
                next_state = timer_expire ? E_YELLOW : E_RED; 
 

            E_YELLOW: 
                next_state = timer_expire ? E_GREEN : E_YELLOW; 
 
            E_GREEN: 
                next_state = timer_expire ? E_WALK : E_GREEN; 
 
            E_WALK: 
                next_state = timer_expire ? W_RED : E_WALK; 
 
            W_RED: 
                next_state = timer_expire ? W_YELLOW : W_RED; 
 
            W_YELLOW: 
                next_state = timer_expire ? W_GREEN : W_YELLOW; 
 
            W_GREEN: 
                next_state = timer_expire ? W_WALK : W_GREEN; 
 
            W_WALK: 
                next_state = timer_expire ? N_RED : W_WALK; 
 
            default: 
                next_state = N_RED; 
 
        endcase 
    end 
 
    //================================================================= 

    // Output Decode Section 
    // Defaults assigned first to guarantee no latches 
    // Full case coverage with default branch 
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
 

            N_RED:    red_n    = 1'b1; 
            N_YELLOW: yellow_n = 1'b1; 
            N_GREEN:  green_n  = 1'b1; 
            N_WALK:   walk_n   = 1'b1; 
 
            S_RED:    red_s    = 1'b1; 
            S_YELLOW: yellow_s = 1'b1; 
            S_GREEN:  green_s  = 1'b1; 
            S_WALK:   walk_s   = 1'b1; 
 
            E_RED:    red_e    = 1'b1; 
            E_YELLOW: yellow_e = 1'b1; 
            E_GREEN:  green_e  = 1'b1; 
            E_WALK:   walk_e   = 1'b1; 
 
            W_RED:    red_w    = 1'b1; 
            W_YELLOW: yellow_w = 1'b1; 
            W_GREEN:  green_w  = 1'b1; 
            W_WALK:   walk_w   = 1'b1; 
 
            default: 
            begin 
                red_n = 1'b1; 
                red_s = 1'b1; 
                red_e = 1'b1; 
                red_w = 1'b1; 
            end 
 

        endcase 
    end 
 
    //============================================================= 
    // Estimated Artix-7 Resource Summary 
    // 
    // FF Count: 
    //   State Register : 16 
    //   Timer Register : 16 
    //   Total          : ~32 FF 
    // 
    // LUT Count: 
    //   Next-State FSM : ~16-24 LUT6 
    //   Output Decode  : ~8-16 LUT6 
    //   Total          : ~24-40 LUT6 
    // 
    // Expected Fmax: 
    //   >100 MHz on xc7a100tcsg324-2 
    // 
    // Expected Critical Path: 
    //   state_reg -> next_state_logic -> state_reg 
    //============================================================= 
 
endmodule