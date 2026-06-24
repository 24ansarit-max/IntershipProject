//============================================================== 
// Module : tl_reg16 
// Responsibility : State register 
// matches Plan: Module #1 
//============================================================== 
module tl_reg16 
#( 
    parameter [15:0] RESET_STATE = 16'h0001 
) 

( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] d, 
    output reg  [15:0] q 
); 
 
always @(posedge clk) 
begin 
    if (rst) 
        q <= RESET_STATE; 
    else 
        q <= d; 
end 
 
endmodule 
 
 
//============================================================== 
// Module : tl_timer16 
// Responsibility : Phase-duration timer 
// matches Plan: Module #2 
//============================================================== 
module tl_timer16 
#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
) 
( 

    input  wire clk, 
    input  wire rst, 
    output wire timer_expire 
); 
 
reg [15:0] timer; 
 
assign timer_expire = (timer == 16'd0); 
 
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
 
 
//============================================================== 
// Module : tl_ns_logic 
// Responsibility : Next-state generation 
// matches Plan: Module #3 
//============================================================== 
module tl_ns_logic 

( 
    input  wire [15:0] state, 
    input  wire        timer_expire, 
    output reg  [15:0] next_state 
); 
 
always @(*) 
begin 
    next_state = 16'h0001; 
 
    case (state) 
 
        16'h0001: next_state = timer_expire ? 16'h0002 : 16'h0001; 
        16'h0002: next_state = timer_expire ? 16'h0004 : 16'h0002; 
        16'h0004: next_state = timer_expire ? 16'h0008 : 16'h0004; 
        16'h0008: next_state = timer_expire ? 16'h0010 : 16'h0008; 
 
        16'h0010: next_state = timer_expire ? 16'h0020 : 16'h0010; 
        16'h0020: next_state = timer_expire ? 16'h0040 : 16'h0020; 
        16'h0040: next_state = timer_expire ? 16'h0080 : 16'h0040; 
        16'h0080: next_state = timer_expire ? 16'h0100 : 16'h0080; 
 
        16'h0100: next_state = timer_expire ? 16'h0200 : 16'h0100; 
        16'h0200: next_state = timer_expire ? 16'h0400 : 16'h0200; 
        16'h0400: next_state = timer_expire ? 16'h0800 : 16'h0400; 
        16'h0800: next_state = timer_expire ? 16'h1000 : 16'h0800; 
 
        16'h1000: next_state = timer_expire ? 16'h2000 : 16'h1000; 

        16'h2000: next_state = timer_expire ? 16'h4000 : 16'h2000; 
        16'h4000: next_state = timer_expire ? 16'h8000 : 16'h4000; 
        16'h8000: next_state = timer_expire ? 16'h0001 : 16'h8000; 
 
        default: next_state = 16'h0001; 
 
    endcase 
end 
 
endmodule 
 
 
//============================================================== 
// Module : tl_outdec 
// Responsibility : Output decoder 
// matches Plan: Module #4 
//============================================================== 
module tl_outdec 
( 
    input  wire [15:0] state, 
 
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
 
always @(*) 
begin 
    red_n=0; yellow_n=0; green_n=0; walk_n=0; 
    red_s=0; yellow_s=0; green_s=0; walk_s=0; 
    red_e=0; yellow_e=0; green_e=0; walk_e=0; 
    red_w=0; yellow_w=0; green_w=0; walk_w=0; 
 
    case(state) 
 
        16'h0001: red_n    = 1'b1; 
        16'h0002: yellow_n = 1'b1; 
        16'h0004: green_n  = 1'b1; 
        16'h0008: walk_n   = 1'b1; 
 

        16'h0010: red_s    = 1'b1; 
        16'h0020: yellow_s = 1'b1; 
        16'h0040: green_s  = 1'b1; 
        16'h0080: walk_s   = 1'b1; 
 
        16'h0100: red_e    = 1'b1; 
        16'h0200: yellow_e = 1'b1; 
        16'h0400: green_e  = 1'b1; 
        16'h0800: walk_e   = 1'b1; 
 
        16'h1000: red_w    = 1'b1; 
        16'h2000: yellow_w = 1'b1; 
        16'h4000: green_w  = 1'b1; 
        16'h8000: walk_w   = 1'b1; 
 
        default: red_n = 1'b1; 
 
    endcase 
end 
 
endmodule 
 
 
//============================================================== 
// Module : traffic_light_top 
// Responsibility : Structural wiring only 
// matches Plan: Module #5 
//============================================================== 

module traffic_light_top 
#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
 
    output wire red_n, 
    output wire yellow_n, 
    output wire green_n, 
    output wire walk_n, 
 
    output wire red_s, 
    output wire yellow_s, 
    output wire green_s, 
    output wire walk_s, 
 
    output wire red_e, 
    output wire yellow_e, 
    output wire green_e, 
    output wire walk_e, 
 
    output wire red_w, 
    output wire yellow_w, 
    output wire green_w, 
    output wire walk_w 
); 

 
wire [15:0] state; 
wire [15:0] next_state; 
wire        timer_expire; 
 
tl_reg16 u_reg 
( 
    .clk(clk), 
    .rst(rst), 
    .d(next_state), 
    .q(state) 
); 
 
tl_timer16 
#( 
    .PHASE_TIME(PHASE_TIME) 
) 
u_timer 
( 
    .clk(clk), 
    .rst(rst), 
    .timer_expire(timer_expire) 
); 
 
tl_ns_logic u_ns 
( 
    .state(state), 
    .timer_expire(timer_expire), 

    .next_state(next_state) 
); 
 
tl_outdec u_out 
( 
    .state(state), 
 
    .red_n(red_n), 
    .yellow_n(yellow_n), 
    .green_n(green_n), 
    .walk_n(walk_n), 
 
    .red_s(red_s), 
    .yellow_s(yellow_s), 
    .green_s(green_s), 
    .walk_s(walk_s), 
 
    .red_e(red_e), 
    .yellow_e(yellow_e), 
    .green_e(green_e), 
    .walk_e(walk_e), 
 
    .red_w(red_w), 
    .yellow_w(yellow_w), 
    .green_w(green_w), 
    .walk_w(walk_w) 
); 
 

endmodule