module traffic_light_top 
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
 
    //---------------------------------------------------------- 
    // Internal Signals 
    //---------------------------------------------------------- 
    wire [15:0] state; 
    wire [15:0] next_state; 
    wire        timer_expire; 
 
    //---------------------------------------------------------- 
    // Timer Block 
    // Resource Estimate: 
    // LUTs ≈ 16 
    // FFs  = 16 
    //---------------------------------------------------------- 
    timer_block 
    #( 
        .TIMER_MAX(TIMER_MAX) 
    ) 
    u_timer 
    ( 
        .clk(clk), 
        .rst(rst), 

        .timer_expire(timer_expire) 
    ); 
 
    //---------------------------------------------------------- 
    // Next-State Logic 
    // Resource Estimate: 
    // LUTs ≈ 16 
    // FFs  = 0 
    //---------------------------------------------------------- 
    next_state_logic 
    u_next_state 
    ( 
        .state(state), 
        .timer_expire(timer_expire), 
        .next_state(next_state) 
    ); 
 
    //---------------------------------------------------------- 
    // State Register 
    // Resource Estimate: 
    // LUTs = 0 
    // FFs  = 16 
    //---------------------------------------------------------- 
    state_ff 
    u_state_ff 
    ( 
        .clk(clk), 
        .rst(rst), 

        .d(next_state), 
        .q(state) 
    ); 
 
    //---------------------------------------------------------- 
    // Output Decoder 
    // Resource Estimate: 
    // LUTs ≈ 0 
    // FFs  = 0 
    //---------------------------------------------------------- 
    output_decode 
    u_output_decode 
    ( 
        .state(state), 
 
        .ns_red(ns_red), 
        .ns_yellow(ns_yellow), 
        .ns_green(ns_green), 
        .ns_walk(ns_walk), 
 
        .ew_red(ew_red), 
        .ew_yellow(ew_yellow), 
        .ew_green(ew_green), 
        .ew_walk(ew_walk), 
 
        .north_red(north_red), 
        .north_yellow(north_yellow), 
        .north_green(north_green), 

        .north_walk(north_walk), 
 
        .south_red(south_red), 
        .south_yellow(south_yellow), 
        .south_green(south_green), 
        .south_walk(south_walk) 
    ); 
 
endmodule 
 
 
//============================================================== 
// 16-bit One-Hot State Register 
//============================================================== 
module state_ff 
( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] d, 
    output reg  [15:0] q 
); 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            q <= 16'b0000_0000_0000_0001; // NS_RED 
        else 
            q <= d; 

    end 
 
endmodule 
 
 
//============================================================== 
// 16-bit Timer 
//============================================================== 
module timer_block 
#( 
    parameter [15:0] TIMER_MAX = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
    output wire timer_expire 
); 
 
    reg [15:0] timer; 
 
    assign timer_expire = (timer == TIMER_MAX); 
 
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
 
 
//============================================================== 
// Next-State Combinational Logic 
// Ring FSM: 
// next[i] = state[i] when timer not expired 
// next[i] = previous_state when timer expired 
//============================================================== 
module next_state_logic 
( 
    input  wire [15:0] state, 
    input  wire        timer_expire, 
    output wire [15:0] next_state 
); 
 
    wire nt; 
 
    assign nt = ~timer_expire; 
 
    assign next_state[0]  = (state[0]  & nt) | (state[15] & timer_expire); 
    assign next_state[1]  = (state[1]  & nt) | (state[0]  & timer_expire); 
    assign next_state[2]  = (state[2]  & nt) | (state[1]  & timer_expire); 
    assign next_state[3]  = (state[3]  & nt) | (state[2]  & timer_expire); 

 
    assign next_state[4]  = (state[4]  & nt) | (state[3]  & timer_expire); 
    assign next_state[5]  = (state[5]  & nt) | (state[4]  & timer_expire); 
    assign next_state[6]  = (state[6]  & nt) | (state[5]  & timer_expire); 
    assign next_state[7]  = (state[7]  & nt) | (state[6]  & timer_expire); 
 
    assign next_state[8]  = (state[8]  & nt) | (state[7]  & timer_expire); 
    assign next_state[9]  = (state[9]  & nt) | (state[8]  & timer_expire); 
    assign next_state[10] = (state[10] & nt) | (state[9]  & timer_expire); 
    assign next_state[11] = (state[11] & nt) | (state[10] & timer_expire); 
 
    assign next_state[12] = (state[12] & nt) | (state[11] & timer_expire); 
    assign next_state[13] = (state[13] & nt) | (state[12] & timer_expire); 
    assign next_state[14] = (state[14] & nt) | (state[13] & timer_expire); 
    assign next_state[15] = (state[15] & nt) | (state[14] & timer_expire); 
 
endmodule 
 
 
//============================================================== 
// Output Decoder 
//============================================================== 
module output_decode 
( 
    input wire [15:0] state, 
 
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
 
endmodule