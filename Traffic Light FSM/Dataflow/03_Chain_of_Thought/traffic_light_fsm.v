module traffic_light_fsm 
#( 
    parameter [15:0] TIMER_MAX = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
 
    output reg  [15:0] state, 
 
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
 
    //---------------------------------------------------------- 
    // 16-bit timer 
    //---------------------------------------------------------- 
    reg [15:0] timer; 
 
    wire timer_expire; 
    wire nt; 
 
    wire [15:0] next; 
 
    assign timer_expire = (timer == TIMER_MAX); 
    assign nt           = ~timer_expire; 
 
    //---------------------------------------------------------- 
    // One-hot next-state equations 
    // next[i] = state[i]&~t + state[i-1]&t 
    //---------------------------------------------------------- 
    assign next[0]  = (state[0]  & nt) | (state[15] & timer_expire); 
    assign next[1]  = (state[1]  & nt) | (state[0]  & timer_expire); 
    assign next[2]  = (state[2]  & nt) | (state[1]  & timer_expire); 
    assign next[3]  = (state[3]  & nt) | (state[2]  & timer_expire); 
 

    assign next[4]  = (state[4]  & nt) | (state[3]  & timer_expire); 
    assign next[5]  = (state[5]  & nt) | (state[4]  & timer_expire); 
    assign next[6]  = (state[6]  & nt) | (state[5]  & timer_expire); 
    assign next[7]  = (state[7]  & nt) | (state[6]  & timer_expire); 
 
    assign next[8]  = (state[8]  & nt) | (state[7]  & timer_expire); 
    assign next[9]  = (state[9]  & nt) | (state[8]  & timer_expire); 
    assign next[10] = (state[10] & nt) | (state[9]  & timer_expire); 
    assign next[11] = (state[11] & nt) | (state[10] & timer_expire); 
 
    assign next[12] = (state[12] & nt) | (state[11] & timer_expire); 
    assign next[13] = (state[13] & nt) | (state[12] & timer_expire); 
    assign next[14] = (state[14] & nt) | (state[13] & timer_expire); 
    assign next[15] = (state[15] & nt) | (state[14] & timer_expire); 
 
    //---------------------------------------------------------- 
    // Output decode 
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
    // State register (16 FFs) 
    //---------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= 16'b0000_0000_0000_0001; // NS_RED 
        else 
            state <= next; 
    end 
 
    //---------------------------------------------------------- 
    // Timer register (16 FFs) 
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
 
endmodule