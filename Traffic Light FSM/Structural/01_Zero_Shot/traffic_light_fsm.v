`timescale 1ns/1ps 
 
//========================================================= 
// Traffic Light FSM - Structural Style 
// Target : Nexys A7 (xc7a100tcsg324-2) 
// 
// Hierarchy: 
//   traffic_light_top 
//      | 
//      +-- state_register 

//      +-- next_state_logic 
//      +-- output_decoder 
// 
// State Encoding (16-bit One-Hot) 
//========================================================= 
 
 
 
//========================================================= 
// State Register 
// 16 FFs total 
// Synchronous active-high reset 
//========================================================= 
module state_register 
( 
    input  wire        clk, 
    input  wire        rst, 
    input  wire [15:0] next_state, 
    output reg  [15:0] state 
); 
 
    parameter [15:0] S_NS_GREEN = 16'h0001; 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= S_NS_GREEN; 
        else 

            state <= next_state; 
    end 
 
endmodule 
 
 
 
//========================================================= 
// Next-State Logic 
// Pure combinational logic 
//========================================================= 
module next_state_logic 
( 
    input  wire [15:0] state, 
    output wire [15:0] next_state 
); 
 
    parameter [15:0] S_NS_GREEN  = 16'h0001; 
    parameter [15:0] S_NS_YELLOW = 16'h0002; 
    parameter [15:0] S_EW_GREEN  = 16'h0004; 
    parameter [15:0] S_EW_YELLOW = 16'h0008; 
 
    assign next_state = 
           (state == S_NS_GREEN ) ? S_NS_YELLOW : 
           (state == S_NS_YELLOW) ? S_EW_GREEN  : 
           (state == S_EW_GREEN ) ? S_EW_YELLOW : 
           (state == S_EW_YELLOW) ? S_NS_GREEN  : 
                                    S_NS_GREEN; 

 
endmodule 
 
 
 
//========================================================= 
// Output Decoder 
// Direction Encoding: 
//   bit0 = North/South 
//   bit1 = East/West 
//========================================================= 
module output_decoder 
( 
    input  wire [15:0] state, 
 
    output wire [1:0] red, 
    output wire [1:0] yellow, 
    output wire [1:0] green 
); 
 
    parameter [15:0] S_NS_GREEN  = 16'h0001; 
    parameter [15:0] S_NS_YELLOW = 16'h0002; 
    parameter [15:0] S_EW_GREEN  = 16'h0004; 
    parameter [15:0] S_EW_YELLOW = 16'h0008; 
 
    assign red = 
           (state == S_NS_GREEN ) ? 2'b10 : 
           (state == S_NS_YELLOW) ? 2'b10 : 

           (state == S_EW_GREEN ) ? 2'b01 : 
           (state == S_EW_YELLOW) ? 2'b01 : 
                                    2'b11; 
 
    assign yellow = 
           (state == S_NS_YELLOW) ? 2'b01 : 
           (state == S_EW_YELLOW) ? 2'b10 : 
                                    2'b00; 
 
    assign green = 
           (state == S_NS_GREEN) ? 2'b01 : 
           (state == S_EW_GREEN) ? 2'b10 : 
                                   2'b00; 
 
endmodule 
 
 
 
//========================================================= 
// Top-Level Module 
// Port wiring only 
// No logic allowed here 
//========================================================= 
module traffic_light_top 
( 
    input  wire       clk, 
    input  wire       rst, 
 

    output wire [1:0] red, 
    output wire [1:0] yellow, 
    output wire [1:0] green 
); 
 
    //----------------------------------------------------- 
    // Interconnect Signals 
    //----------------------------------------------------- 
    wire [15:0] state_bus; 
    wire [15:0] next_state_bus; 
 
    //----------------------------------------------------- 
    // State Register Instance 
    //----------------------------------------------------- 
    state_register u_state_register 
    ( 
        .clk        (clk),            // System clock 
        .rst        (rst),            // Synchronous reset 
        .next_state (next_state_bus), // Next-state input 
        .state      (state_bus)       // Current-state output 
    ); 
 
    //----------------------------------------------------- 
    // Next-State Logic Instance 
    //----------------------------------------------------- 
    next_state_logic u_next_state_logic 
    ( 
        .state      (state_bus),      // Current state 

        .next_state (next_state_bus)  // Computed next state 
    ); 
 
    //----------------------------------------------------- 
    // Output Decoder Instance 
    //----------------------------------------------------- 
    output_decoder u_output_decoder 
    ( 
        .state  (state_bus),  // Current FSM state 
 
        .red    (red),        // Red outputs 
        .yellow (yellow),     // Yellow outputs 
        .green  (green)       // Green outputs 
    ); 
 
endmodule