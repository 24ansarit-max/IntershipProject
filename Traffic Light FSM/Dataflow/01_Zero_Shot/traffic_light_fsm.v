`timescale 1ns/1ps 
 
//========================================================= 
// 16-bit Traffic Light FSM 
// Dataflow Combinational Logic + Single FF Stage 
// 
// Target : Nexys A7 (xc7a100tcsg324-2) 
// Style  : Pure Dataflow for combinational logic 
// Reset  : Synchronous Active-High 
// 
// Directions: 
//   bit[0] = North/South 
//   bit[1] = East/West 
// 

// State Encoding (16-bit parameters) 
//========================================================= 
 
module traffic_light_fsm_dataflow 
( 
    input  wire        clk, 
    input  wire        rst, 
 
    output wire [1:0]  red, 
    output wire [1:0]  yellow, 
    output wire [1:0]  green 
); 
 
    //----------------------------------------------------- 
    // 16-bit State Encoding 
    //----------------------------------------------------- 
    parameter [15:0] S_NS_GREEN  = 16'h0001; 
    parameter [15:0] S_NS_YELLOW = 16'h0002; 
    parameter [15:0] S_EW_GREEN  = 16'h0004; 
    parameter [15:0] S_EW_YELLOW = 16'h0008; 
 
    //----------------------------------------------------- 
    // Timing Constants 
    //----------------------------------------------------- 
    parameter [15:0] GREEN_TIME  = 16'd50000; 
    parameter [15:0] YELLOW_TIME = 16'd10000; 
 
    //----------------------------------------------------- 

    // State / Timer Registers 
    //----------------------------------------------------- 
    reg  [15:0] state; 
    reg  [15:0] timer; 
 
    //----------------------------------------------------- 
    // Next-State / Next-Timer Signals 
    //----------------------------------------------------- 
    wire [15:0] next_state; 
    wire [15:0] next_timer; 
 
    //----------------------------------------------------- 
    // Timer Expired Flag 
    //----------------------------------------------------- 
    // Boolean function: 
    // expired = 1 when countdown reaches zero 
    //----------------------------------------------------- 
    wire expired; 
    assign expired = (timer == 16'd0); 
 
    //----------------------------------------------------- 
    // State Transition Logic 
    //----------------------------------------------------- 
    // NS_GREEN -> NS_YELLOW 
    // NS_YELLOW -> EW_GREEN 
    // EW_GREEN -> EW_YELLOW 
    // EW_YELLOW -> NS_GREEN 
    // 

    // If timer not expired, remain in current state. 
    //----------------------------------------------------- 
    assign next_state = 
            !expired                    ? state       : 
            (state == S_NS_GREEN )      ? S_NS_YELLOW : 
            (state == S_NS_YELLOW)      ? S_EW_GREEN  : 
            (state == S_EW_GREEN )      ? S_EW_YELLOW : 
            (state == S_EW_YELLOW)      ? S_NS_GREEN  : 
                                          S_NS_GREEN; 
 
    //----------------------------------------------------- 
    // Timer Reload Logic 
    //----------------------------------------------------- 
    // While active: 
    //     timer = timer - 1 
    // 
    // On transition: 
    //     load GREEN_TIME or YELLOW_TIME 
    //----------------------------------------------------- 
    assign next_timer = 
            !expired                           ? (timer - 16'd1) : 
 
            (state == S_NS_GREEN )             ? YELLOW_TIME : 
            (state == S_NS_YELLOW)             ? GREEN_TIME  : 
            (state == S_EW_GREEN )             ? YELLOW_TIME : 
            (state == S_EW_YELLOW)             ? GREEN_TIME  : 
                                                 GREEN_TIME; 
 

    //----------------------------------------------------- 
    // Output Decode Logic 
    //----------------------------------------------------- 
 
    // Red lamps 
    // 
    // NS_GREEN  : EW red 
    // NS_YELLOW : EW red 
    // EW_GREEN  : NS red 
    // EW_YELLOW : NS red 
    // 
    assign red = 
            (state == S_NS_GREEN )  ? 2'b10 : 
            (state == S_NS_YELLOW)  ? 2'b10 : 
            (state == S_EW_GREEN )  ? 2'b01 : 
            (state == S_EW_YELLOW)  ? 2'b01 : 
                                      2'b11; 
 
    //----------------------------------------------------- 
    // Yellow lamp decode 
    //----------------------------------------------------- 
    assign yellow = 
            (state == S_NS_YELLOW) ? 2'b01 : 
            (state == S_EW_YELLOW) ? 2'b10 : 
                                     2'b00; 
 
    //----------------------------------------------------- 
    // Green lamp decode 

    //----------------------------------------------------- 
    assign green = 
            (state == S_NS_GREEN) ? 2'b01 : 
            (state == S_EW_GREEN) ? 2'b10 : 
                                    2'b00; 
 
    //----------------------------------------------------- 
    // Flip-Flop Stage 
    //----------------------------------------------------- 
    // Only sequential logic in the design. 
    //----------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
        begin 
            state <= S_NS_GREEN; 
            timer <= GREEN_TIME; 
        end 
        else 
        begin 
            state <= next_state; 
            timer <= next_timer; 
        end 
    end 
 
endmodule