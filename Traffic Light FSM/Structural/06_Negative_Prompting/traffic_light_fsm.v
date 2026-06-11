module tl_reg16( 
    input clk, 
    input rst, 
    input [15:0] d, 
    output reg [15:0] q 
); 
always @(posedge clk) 
begin 
    if (rst) 
        q <= 16'h0001; 
    else 
        q <= d; 
end 
endmodule 
 
 

module tl_ns_logic( 
    input  [15:0] state, 
    output reg [15:0] next_state 
); 
always @(*) 
begin 
    next_state = 16'b0; 
 
    if (state[0])       next_state = 16'h0002; 
    else if (state[1])  next_state = 16'h0004; 
    else if (state[2])  next_state = 16'h0008; 
    else if (state[3])  next_state = 16'h0010; 
    else if (state[4])  next_state = 16'h0020; 
    else if (state[5])  next_state = 16'h0040; 
    else if (state[6])  next_state = 16'h0080; 
    else if (state[7])  next_state = 16'h0100; 
    else if (state[8])  next_state = 16'h0200; 
    else if (state[9])  next_state = 16'h0400; 
    else if (state[10]) next_state = 16'h0800; 
    else if (state[11]) next_state = 16'h1000; 
    else if (state[12]) next_state = 16'h2000; 
    else if (state[13]) next_state = 16'h4000; 
    else if (state[14]) next_state = 16'h8000; 
    else if (state[15]) next_state = 16'h0001; 
    else                next_state = 16'h0001; 
end 
endmodule 
 

 
module tl_outdec( 
    input [15:0] state, 
 
    output reg ns_red, 
    output reg ns_yellow, 
    output reg ns_green, 
    output reg ns_walk, 
 
    output reg ew_red, 
    output reg ew_yellow, 
    output reg ew_green, 
    output reg ew_walk, 
 
    output reg north_red, 
    output reg north_yellow, 
    output reg north_green, 
    output reg north_walk, 
 
    output reg south_red, 
    output reg south_yellow, 
    output reg south_green, 
    output reg south_walk 
); 
 
always @(*) 
begin 
    ns_red = 0; ns_yellow = 0; ns_green = 0; ns_walk = 0; 

    ew_red = 0; ew_yellow = 0; ew_green = 0; ew_walk = 0; 
    north_red = 0; north_yellow = 0; north_green = 0; north_walk = 0; 
    south_red = 0; south_yellow = 0; south_green = 0; south_walk = 0; 
 
    case (1'b1) 
        state[0]:  ns_red       = 1'b1; 
        state[1]:  ns_yellow    = 1'b1; 
        state[2]:  ns_green     = 1'b1; 
        state[3]:  ns_walk      = 1'b1; 
 
        state[4]:  ew_red       = 1'b1; 
        state[5]:  ew_yellow    = 1'b1; 
        state[6]:  ew_green     = 1'b1; 
        state[7]:  ew_walk      = 1'b1; 
 
        state[8]:  north_red    = 1'b1; 
        state[9]:  north_yellow = 1'b1; 
        state[10]: north_green  = 1'b1; 
        state[11]: north_walk   = 1'b1; 
 
        state[12]: south_red    = 1'b1; 
        state[13]: south_yellow = 1'b1; 
        state[14]: south_green  = 1'b1; 
        state[15]: south_walk   = 1'b1; 
    endcase 
end 
 
endmodule 

 
 
module tl_top( 
    input clk, 
    input rst, 
 
    output ns_red, 
    output ns_yellow, 
    output ns_green, 
    output ns_walk, 
 
    output ew_red, 
    output ew_yellow, 
    output ew_green, 
    output ew_walk, 
 
    output north_red, 
    output north_yellow, 
    output north_green, 
    output north_walk, 
 
    output south_red, 
    output south_yellow, 
    output south_green, 
    output south_walk 
); 
 
wire [15:0] state; 

wire [15:0] next_state; 
 
tl_reg16 u_reg( 
    .clk(clk), 
    .rst(rst), 
    .d(next_state), 
    .q(state) 
); 
 
tl_ns_logic u_ns( 
    .state(state), 
    .next_state(next_state) 
); 
 
tl_outdec u_dec( 
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