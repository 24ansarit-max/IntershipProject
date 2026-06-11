`timescale 1ns/1ps 
 
//========================================================= 
// State Register 
//========================================================= 
module tl_state_reg 

( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] d, 
    output reg  [15:0] q 
); 
 
    localparam [15:0] S0_R = 16'h0001; 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            q <= S0_R; 
        else 
            q <= d; 
    end 
 
endmodule 
 
 
//========================================================= 
// Next-State Logic 
// No assign statements 
//========================================================= 
module tl_next_state 
( 
    input  wire [15:0] state, 
    output reg  [15:0] next 

); 
 
    localparam [15:0] 
        S0_R = 16'h0001, 
        S0_Y = 16'h0002, 
        S0_G = 16'h0004, 
 
        S1_R = 16'h0008, 
        S1_Y = 16'h0010, 
        S1_G = 16'h0020, 
 
        S2_R = 16'h0040, 
        S2_Y = 16'h0080, 
        S2_G = 16'h0100, 
 
        S3_R = 16'h0200, 
        S3_Y = 16'h0400, 
        S3_G = 16'h0800, 
 
        S12  = 16'h1000, 
        S13  = 16'h2000, 
        S14  = 16'h4000, 
        S15  = 16'h8000; 
 
    always @(*) 
    begin 
        next = S0_R; 
 

        case(state) 
 
            S0_R : next = S0_Y; 
            S0_Y : next = S0_G; 
            S0_G : next = S1_R; 
 
            S1_R : next = S1_Y; 
            S1_Y : next = S1_G; 
            S1_G : next = S2_R; 
 
            S2_R : next = S2_Y; 
            S2_Y : next = S2_G; 
            S2_G : next = S3_R; 
 
            S3_R : next = S3_Y; 
            S3_Y : next = S3_G; 
            S3_G : next = S12; 
 
            S12  : next = S13; 
            S13  : next = S14; 
            S14  : next = S15; 
            S15  : next = S0_R; 
 
            default : next = S0_R; 
 
        endcase 
    end 
 

endmodule 
 
 
//========================================================= 
// Output Decoder 
// No assign statements 
//========================================================= 
module tl_output_dec 
( 
    input  wire [15:0] state, 
 
    output reg [3:0] red, 
    output reg [3:0] yellow, 
    output reg [3:0] green 
); 
 
    always @(*) 
    begin 
        red    = 4'b0000; 
        yellow = 4'b0000; 
        green  = 4'b0000; 
 
        case(state) 
 
            16'h0001 : red[0]    = 1'b1; 
            16'h0002 : yellow[0] = 1'b1; 
            16'h0004 : green[0]  = 1'b1; 
 

            16'h0008 : red[1]    = 1'b1; 
            16'h0010 : yellow[1] = 1'b1; 
            16'h0020 : green[1]  = 1'b1; 
 
            16'h0040 : red[2]    = 1'b1; 
            16'h0080 : yellow[2] = 1'b1; 
            16'h0100 : green[2]  = 1'b1; 
 
            16'h0200 : red[3]    = 1'b1; 
            16'h0400 : yellow[3] = 1'b1; 
            16'h0800 : green[3]  = 1'b1; 
 
            default : 
            begin 
                red    = 4'b0000; 
                yellow = 4'b0000; 
                green  = 4'b0000; 
            end 
 
        endcase 
    end 
 
endmodule 
 
 
//========================================================= 
// Top-Level 
// Wiring only 

//========================================================= 
module tl_top 
( 
    input  wire       clk, 
    input  wire       rst, 
 
    output wire [3:0] red, 
    output wire [3:0] yellow, 
    output wire [3:0] green 
); 
 
    wire [15:0] state_bus; 
    wire [15:0] next_bus; 
 
    // State register 
    tl_state_reg u_state_reg 
    ( 
        .clk(clk),          // system clock 
        .rst(rst),          // synchronous reset 
        .d(next_bus),       // next state 
        .q(state_bus)       // current state 
    ); 
 
    // Next-state logic 
    tl_next_state u_next_state 
    ( 
        .state(state_bus),  // current state 
        .next(next_bus)     // next state 

    ); 
 
    // Output decoder 
    tl_output_dec u_output_dec 
    ( 
        .state(state_bus),  // current state 
        .red(red),          // red outputs 
        .yellow(yellow),    // yellow outputs 
        .green(green)       // green outputs 
    ); 
 
endmodule