//===================================================================== 
// Module : traffic_light_fsm 
// Target : xc7a100tcsg324-2 (Artix-7) 

// Style  : Behavioral FSM 
// 
// Notes: 
// - Synchronous reset only 
// - No latches 
// - No initial blocks 
// - No delays 
// - Full case coverage 
// - One-hot state encoding 
// 
// Estimated Resources: 
//   FFs  : 32 (16 state + 16 timer) 
//   LUTs : ~25-40 
//   Fmax : >200 MHz (Artix-7 -2) 
//===================================================================== 
 
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
 
    //----------------------------------------------------------------- 
    // One-Hot State Encoding 
    //----------------------------------------------------------------- 
 
    localparam [15:0] 
        NS_RED    = 16'h0001, // North/South RED 
        NS_YELLOW = 16'h0002, // North/South YELLOW 
        NS_GREEN  = 16'h0004, // North/South GREEN 
        NS_WALK   = 16'h0008, // North/South WALK 
 
        EW_RED    = 16'h0010, // East/West RED 

        EW_YELLOW = 16'h0020, // East/West YELLOW 
        EW_GREEN  = 16'h0040, // East/West GREEN 
        EW_WALK   = 16'h0080, // East/West WALK 
 
        N_RED     = 16'h0100, // North RED 
        N_YELLOW  = 16'h0200, // North YELLOW 
        N_GREEN   = 16'h0400, // North GREEN 
        N_WALK    = 16'h0800, // North WALK 
 
        S_RED     = 16'h1000, // South RED 
        S_YELLOW  = 16'h2000, // South YELLOW 
        S_GREEN   = 16'h4000, // South GREEN 
        S_WALK    = 16'h8000; // South WALK 
 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
    reg [15:0] next_state; 
 
    reg [15:0] timer; 
 
    wire timer_expire; 
 
    assign timer_expire = (timer == 16'd0); 
 
    //----------------------------------------------------------------- 
    // State Register 
    //----------------------------------------------------------------- 
    always @(posedge clk) 

    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= next_state; 
    end 
 
    //----------------------------------------------------------------- 
    // Timer Register 
    //----------------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= PHASE_TIME; 
        else if (timer_expire) 
            timer <= PHASE_TIME; 
        else 
            timer <= timer - 16'd1; 
    end 
 
    //----------------------------------------------------------------- 
    // Next-State Logic 
    // Default assignment prevents latch inference 
    //----------------------------------------------------------------- 
    always @(*) 
    begin 
        next_state = NS_RED; 
 

        case (state) 
 
            // North/South sequence 
            NS_RED: 
                next_state = timer_expire ? NS_YELLOW : NS_RED; 
 
            NS_YELLOW: 
                next_state = timer_expire ? NS_GREEN : NS_YELLOW; 
 
            NS_GREEN: 
                next_state = timer_expire ? NS_WALK : NS_GREEN; 
 
            NS_WALK: 
                next_state = timer_expire ? EW_RED : NS_WALK; 
 
            // East/West sequence 
            EW_RED: 
                next_state = timer_expire ? EW_YELLOW : EW_RED; 
 
            EW_YELLOW: 
                next_state = timer_expire ? EW_GREEN : EW_YELLOW; 
 
            EW_GREEN: 
                next_state = timer_expire ? EW_WALK : EW_GREEN; 
 
            EW_WALK: 
                next_state = timer_expire ? N_RED : EW_WALK; 
 

            // North-only sequence 
            N_RED: 
                next_state = timer_expire ? N_YELLOW : N_RED; 
 
            N_YELLOW: 
                next_state = timer_expire ? N_GREEN : N_YELLOW; 
 
            N_GREEN: 
                next_state = timer_expire ? N_WALK : N_GREEN; 
 
            N_WALK: 
                next_state = timer_expire ? S_RED : N_WALK; 
 
            // South-only sequence 
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
 
    //----------------------------------------------------------------- 
    // Output Decode 
    // Defaults assigned first => no latches 
    //----------------------------------------------------------------- 
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
 
            // North/South outputs 
            NS_RED:    red_n    = 1'b1; 
            NS_YELLOW: yellow_n = 1'b1; 
            NS_GREEN:  green_n  = 1'b1; 
            NS_WALK:   walk_n   = 1'b1; 
 
            // East/West outputs 
            EW_RED:    red_e    = 1'b1; 
            EW_YELLOW: yellow_e = 1'b1; 
            EW_GREEN:  green_e  = 1'b1; 
            EW_WALK:   walk_e   = 1'b1; 
 
            // North outputs 
            N_RED:     red_n    = 1'b1; 
            N_YELLOW:  yellow_n = 1'b1; 
            N_GREEN:   green_n  = 1'b1; 
            N_WALK:    walk_n   = 1'b1; 
 
            // South outputs 
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
 
endmodule