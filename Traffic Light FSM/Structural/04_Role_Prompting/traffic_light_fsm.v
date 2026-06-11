//============================================================== 
// Module : tl_reg16 
// Function: Reusable 16-bit synchronous register 
// Inputs  : clk, rst, d[15:0] 
// Outputs : q[15:0] 
// PPA     : 16 FF, 0 LUT 
//           Critical Path = FF only 
//============================================================== 
module tl_reg16 
( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] d, 
    output reg  [15:0] q 
); 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            q <= 16'h0001; 
        else 
            q <= d; 
    end 
 
endmodule 

 
 
//============================================================== 
// Module : tl_timer16 
// Function: 16-bit synchronous countdown timer 
// Inputs  : clk, rst 
// Outputs : timer_done 
// PPA     : 16 FF, ~8-16 LUT 
//           Critical Path = timer compare 
//============================================================== 
module tl_timer16 
#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
    output wire timer_done 
); 
 
    reg [15:0] timer; 
 
    assign timer_done = (timer == 16'd0); 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= PHASE_TIME; 

        else if (timer_done) 
            timer <= PHASE_TIME; 
        else 
            timer <= timer - 16'd1; 
    end 
 
endmodule 
 
 
//============================================================== 
// Module : tl_ns_logic 
// Function: One-hot next-state combinational logic 
// Inputs  : state[15:0], timer_done 
// Outputs : next_state[15:0] 
// PPA     : ~16 LUT 
//           Critical Path = one LUT mux level 
//============================================================== 
module tl_ns_logic 
( 
    input  wire [15:0] state, 
    input  wire        timer_done, 
    output wire [15:0] next_state 
); 
 
    wire nt; 
 
    assign nt = ~timer_done; 
 

    assign next_state[0]  = (state[0]  & nt) | (state[15] & timer_done); 
    assign next_state[1]  = (state[1]  & nt) | (state[0]  & timer_done); 
    assign next_state[2]  = (state[2]  & nt) | (state[1]  & timer_done); 
    assign next_state[3]  = (state[3]  & nt) | (state[2]  & timer_done); 
 
    assign next_state[4]  = (state[4]  & nt) | (state[3]  & timer_done); 
    assign next_state[5]  = (state[5]  & nt) | (state[4]  & timer_done); 
    assign next_state[6]  = (state[6]  & nt) | (state[5]  & timer_done); 
    assign next_state[7]  = (state[7]  & nt) | (state[6]  & timer_done); 
 
    assign next_state[8]  = (state[8]  & nt) | (state[7]  & timer_done); 
    assign next_state[9]  = (state[9]  & nt) | (state[8]  & timer_done); 
    assign next_state[10] = (state[10] & nt) | (state[9]  & timer_done); 
    assign next_state[11] = (state[11] & nt) | (state[10] & timer_done); 
 
    assign next_state[12] = (state[12] & nt) | (state[11] & timer_done); 
    assign next_state[13] = (state[13] & nt) | (state[12] & timer_done); 
    assign next_state[14] = (state[14] & nt) | (state[13] & timer_done); 
    assign next_state[15] = (state[15] & nt) | (state[14] & timer_done); 
 
endmodule 
 
 
//============================================================== 
// Module : tl_out_dec 
// Function: Decode one-hot state into traffic outputs 
// Inputs  : state[15:0] 
// Outputs : Traffic light control signals 

// PPA     : ~0-4 LUT 
//           Critical Path = routing only 
//============================================================== 
module tl_out_dec 
( 
    input  wire [15:0] state, 
 
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
 
 
//============================================================== 
// Module : tl_top 
// Function: Top-level traffic light controller 
// Inputs  : clk, rst 
// Outputs : Traffic light control signals 

// PPA     : FFs  = 32 
//           LUTs = ~24-40 
//           Fmax > 200 MHz (Artix-7 estimate) 
//           Critical Path: 
//           state_ff -> tl_ns_logic -> state_ff 
//============================================================== 
module tl_top 
#( 
    parameter [15:0] PHASE_TIME = 16'd50000 
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
 
    wire [15:0] state; 
    wire [15:0] next_state; 
    wire timer_done; 
 
    tl_timer16 
    #( 
        .PHASE_TIME(PHASE_TIME) 
    ) 
    u_timer 
    ( 
        .clk(clk), 
        .rst(rst), 
        .timer_done(timer_done) 
    ); 
 
    tl_ns_logic 
    u_ns_logic 
    ( 
        .state(state), 
        .timer_done(timer_done), 
        .next_state(next_state) 

    ); 
 
    tl_reg16 
    u_state_reg 
    ( 
        .clk(clk), 
        .rst(rst), 
        .d(next_state), 
        .q(state) 
    ); 
 
    tl_out_dec 
    u_out_dec 
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