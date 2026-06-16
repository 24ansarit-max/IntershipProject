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
 
    //---------------------------------------------------------- 
    // Vivado Hint: 
    // (* fsm_encoding = "one_hot" *) 
    // 
    // Resource Estimate (Artix-7): 
    // State FFs : 16 
    // Timer FFs : 16 
    // Total FFs : 32 
    // LUTs      : ~20-40 
    // 
    // Critical Path: 
    // state_reg -> case decode -> next_state mux -> state_reg 
    // Expected Fmax > 200 MHz on xc7a100tcsg324-2 
    //---------------------------------------------------------- 
 
    localparam [15:0] 
        NS_RED    = 16'b0000_0000_0000_0001, 
        NS_YELLOW = 16'b0000_0000_0000_0010, 

        NS_GREEN  = 16'b0000_0000_0000_0100, 
        NS_WALK   = 16'b0000_0000_0000_1000, 
 
        EW_RED    = 16'b0000_0000_0001_0000, 
        EW_YELLOW = 16'b0000_0000_0010_0000, 
        EW_GREEN  = 16'b0000_0000_0100_0000, 
        EW_WALK   = 16'b0000_0000_1000_0000, 
 
        N_RED     = 16'b0000_0001_0000_0000, 
        N_YELLOW  = 16'b0000_0010_0000_0000, 
        N_GREEN   = 16'b0000_0100_0000_0000, 
        N_WALK    = 16'b0000_1000_0000_0000, 
 
        S_RED     = 16'b0001_0000_0000_0000, 
        S_YELLOW  = 16'b0010_0000_0000_0000, 
        S_GREEN   = 16'b0100_0000_0000_0000, 
        S_WALK    = 16'b1000_0000_0000_0000; 
 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
    reg [15:0] next_state; 
 
    reg [15:0] timer; 
 
    wire timer_done; 
 
    assign timer_done = (timer == 16'd0); 
 

    //---------------------------------------------------------- 
    // State Register 
    //---------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 
    end 
 
    //---------------------------------------------------------- 
    // 16-bit Countdown Timer 
    //---------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= PHASE_TIME; 
        else if (timer_done) 
            timer <= PHASE_TIME; 
        else 
            timer <= timer - 16'd1; 
    end 
 
    //---------------------------------------------------------- 
    // Next-State Logic 
    // Full coverage 
    // No latches 

    //---------------------------------------------------------- 
    always @(*) 
    begin 
        next_state = state; 
 
        case (state) 
 
            NS_RED: 
                if (timer_done) next_state = NS_YELLOW; 
 
            NS_YELLOW: 
                if (timer_done) next_state = NS_GREEN; 
 
            NS_GREEN: 
                if (timer_done) next_state = NS_WALK; 
 
            NS_WALK: 
                if (timer_done) next_state = EW_RED; 
 
            EW_RED: 
                if (timer_done) next_state = EW_YELLOW; 
 
            EW_YELLOW: 
                if (timer_done) next_state = EW_GREEN; 
 
            EW_GREEN: 
                if (timer_done) next_state = EW_WALK; 
 

            EW_WALK: 
                if (timer_done) next_state = N_RED; 
 
            N_RED: 
                if (timer_done) next_state = N_YELLOW; 
 
            N_YELLOW: 
                if (timer_done) next_state = N_GREEN; 
 
            N_GREEN: 
                if (timer_done) next_state = N_WALK; 
 
            N_WALK: 
                if (timer_done) next_state = S_RED; 
 
            S_RED: 
                if (timer_done) next_state = S_YELLOW; 
 
            S_YELLOW: 
                if (timer_done) next_state = S_GREEN; 
 
            S_GREEN: 
                if (timer_done) next_state = S_WALK; 
 
            S_WALK: 
                if (timer_done) next_state = NS_RED; 
 
            default: 

                next_state = NS_RED; 
 
        endcase 
    end 
 
    //---------------------------------------------------------- 
    // Output Decode 
    // Fully specified 
    // No latch inference 
    //---------------------------------------------------------- 
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
 
            default: begin 
                red_n = 1'b1; 

                red_s = 1'b1; 
                red_e = 1'b1; 
                red_w = 1'b1; 
            end 
 
        endcase 
    end 
 
endmodule