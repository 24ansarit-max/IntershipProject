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
 
    //========================================================= 
    // PARAMETERS 
    //========================================================= 
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
 
    //========================================================= 
    // STATE_REG 
    //========================================================= 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
    reg [15:0] next_state; 
 
    //========================================================= 
    // TIMER 
    //========================================================= 
    reg [15:0] timer; 
    reg        timer_expire; 
 

    always @(posedge clk) 
    begin 
        if (rst) 
        begin 
            timer <= PHASE_TIME; 
            timer_expire <= 1'b0; 
        end 
        else 
        begin 
            if (timer == 16'd0) 
            begin 
                timer <= PHASE_TIME; 
                timer_expire <= 1'b1; 
            end 
            else 
            begin 
                timer <= timer - 16'd1; 
                timer_expire <= 1'b0; 
            end 
        end 
    end 
 
    //========================================================= 
    // STATE_REG 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 

            state <= N_RED; 
        else 
            state <= next_state; 
    end 
 
    //========================================================= 
    // NEXT_STATE 
    // Pass 1: defaults added (latch prevention) 
    // Pass 2: simple one-hot transitions 
    //========================================================= 
    always @(*) 
    begin 
        next_state = state; 
 
        case(state) 
 
            N_RED: 
                if(timer_expire) next_state = N_YELLOW; 
 
            N_YELLOW: 
                if(timer_expire) next_state = N_GREEN; 
 
            N_GREEN: 
                if(timer_expire) next_state = N_WALK; 
 
            N_WALK: 
                if(timer_expire) next_state = S_RED; 
 

            S_RED: 
                if(timer_expire) next_state = S_YELLOW; 
 
            S_YELLOW: 
                if(timer_expire) next_state = S_GREEN; 
 
            S_GREEN: 
                if(timer_expire) next_state = S_WALK; 
 
            S_WALK: 
                if(timer_expire) next_state = E_RED; 
 
            E_RED: 
                if(timer_expire) next_state = E_YELLOW; 
 
            E_YELLOW: 
                if(timer_expire) next_state = E_GREEN; 
 
            E_GREEN: 
                if(timer_expire) next_state = E_WALK; 
 
            E_WALK: 
                if(timer_expire) next_state = W_RED; 
 
            W_RED: 
                if(timer_expire) next_state = W_YELLOW; 
 
            W_YELLOW: 

                if(timer_expire) next_state = W_GREEN; 
 
            W_GREEN: 
                if(timer_expire) next_state = W_WALK; 
 
            W_WALK: 
                if(timer_expire) next_state = N_RED; 
 
            default: 
                next_state = N_RED; 
 
        endcase 
    end 
 
    //========================================================= 
    // OUTPUT_DEC 
    // Pass 1: defaults added (latch prevention) 
    //========================================================= 
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
 
        case(state) 
 
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
                red_n = 1'b1; 
 
        endcase 
    end 
 
endmodule