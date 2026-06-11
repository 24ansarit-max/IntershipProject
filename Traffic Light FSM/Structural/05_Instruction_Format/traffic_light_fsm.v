//===================================================================== 
// ===== MODULE NAME : tl_dff16 ===== 
//===================================================================== 
module tl_dff16 
( 
    input  wire        clk,   // system clock 100MHz 
    input  wire        rst,   // synchronous reset 
    input  wire [15:0] d,     // next state input 
    output reg  [15:0] q      // current state output 
); 
 
    localparam [15:0] RESET_STATE = 16'h0001; 
 
    always @(posedge clk) 
    begin 
        if (rst) 

            q <= RESET_STATE; 
        else 
            q <= d; 
    end 
 
endmodule 
 
 
//===================================================================== 
// ===== MODULE NAME : tl_ns16 ===== 
//===================================================================== 
module tl_ns16 
( 
    input  wire [15:0] state,         // current state 
    input  wire        timer_expire,  // timer expiration pulse 
    output wire [15:0] next_state     // next state 
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
 
 
//===================================================================== 
// ===== MODULE NAME : tl_timer16 ===== 
//===================================================================== 
module tl_timer16 
#( 
    parameter [15:0] TIMER_MAX = 16'd50000 
) 
( 
    input  wire clk,           // system clock 100MHz 
    input  wire rst,           // synchronous reset 
    output wire timer_expire   // expiration pulse 

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
 
 
//===================================================================== 
// ===== MODULE NAME : tl_outdec ===== 
//===================================================================== 
module tl_outdec 
( 
    input  wire [15:0] state,        // current state 
 
    output wire ns_red,             // north/south red 
    output wire ns_yellow,          // north/south yellow 

    output wire ns_green,           // north/south green 
    output wire ns_walk,            // north/south walk 
 
    output wire ew_red,             // east/west red 
    output wire ew_yellow,          // east/west yellow 
    output wire ew_green,           // east/west green 
    output wire ew_walk,            // east/west walk 
 
    output wire north_red,          // north red 
    output wire north_yellow,       // north yellow 
    output wire north_green,        // north green 
    output wire north_walk,         // north walk 
 
    output wire south_red,          // south red 
    output wire south_yellow,       // south yellow 
    output wire south_green,        // south green 
    output wire south_walk          // south walk 
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
 
 
//===================================================================== 
// ===== MODULE NAME : traffic_light_top ===== 
//===================================================================== 
module traffic_light_top 
#( 
    parameter [15:0] TIMER_MAX = 16'd50000 
) 
( 
    input  wire clk,           // system clock 100MHz 
    input  wire rst,           // synchronous reset 
 
    output wire ns_red,        // north/south red 
    output wire ns_yellow,     // north/south yellow 
    output wire ns_green,      // north/south green 

    output wire ns_walk,       // north/south walk 
 
    output wire ew_red,        // east/west red 
    output wire ew_yellow,     // east/west yellow 
    output wire ew_green,      // east/west green 
    output wire ew_walk,       // east/west walk 
 
    output wire north_red,     // north red 
    output wire north_yellow,  // north yellow 
    output wire north_green,   // north green 
    output wire north_walk,    // north walk 
 
    output wire south_red,     // south red 
    output wire south_yellow,  // south yellow 
    output wire south_green,   // south green 
    output wire south_walk     // south walk 
); 
 
    wire [15:0] state; 
    wire [15:0] next_state; 
    wire        timer_expire; 
 
    tl_timer16 
    #( 
        .TIMER_MAX(TIMER_MAX) 
    ) 
    u_timer 
    ( 

        .clk(clk), 
        .rst(rst), 
        .timer_expire(timer_expire) 
    ); 
 
    tl_ns16 
    u_next_state 
    ( 
        .state(state), 
        .timer_expire(timer_expire), 
        .next_state(next_state) 
    ); 
 
    tl_dff16 
    u_state_reg 
    ( 
        .clk(clk), 
        .rst(rst), 
        .d(next_state), 
        .q(state) 
    ); 
 
    tl_outdec 
    u_decoder 
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
 
 
// LUT = ~30-45 
// FF  = 32 (16 state + 16 timer) 
// Fmax = >200 MHz on xc7a100tcsg324-2