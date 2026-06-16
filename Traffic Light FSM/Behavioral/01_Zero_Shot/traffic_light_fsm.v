`timescale 1ns / 1ps 
 
//========================================================= 
// 16-bit Traffic Light Controller FSM 
// Target : Nexys A7 (xc7a100tcsg324-2) 
// Style  : Behavioral RTL 

// Reset  : Synchronous Active-High 
// 
// States: 
//   S_NS_GREEN   -> North/South Green 
//   S_NS_YELLOW  -> North/South Yellow 
//   S_EW_GREEN   -> East/West Green 
//   S_EW_YELLOW  -> East/West Yellow 
// 
// Outputs: 
//   red[1:0] 
//   yellow[1:0] 
//   green[1:0] 
// 
// Direction Encoding: 
//   bit[0] = North/South 
//   bit[1] = East/West 
// 
// Resource Optimized: 
//   2-bit binary FSM 
//   16-bit countdown timer 
//========================================================= 
 
module traffic_light_fsm 
( 
    input  wire        clk, 
    input  wire        rst, 
 
    output reg  [1:0]  red, 

    output reg  [1:0]  yellow, 
    output reg  [1:0]  green 
); 
 
    //----------------------------------------------------- 
    // State Encoding 
    //----------------------------------------------------- 
    parameter [1:0] 
        S_NS_GREEN  = 2'b00, 
        S_NS_YELLOW = 2'b01, 
        S_EW_GREEN  = 2'b10, 
        S_EW_YELLOW = 2'b11; 
 
    //----------------------------------------------------- 
    // Timing Constants 
    //----------------------------------------------------- 
    parameter [15:0] GREEN_TIME  = 16'd50000; 
    parameter [15:0] YELLOW_TIME = 16'd10000; 
 
    //----------------------------------------------------- 
    // Registers 
    //----------------------------------------------------- 
    reg [1:0]  state; 
    reg [15:0] timer; 
 
    //----------------------------------------------------- 
    // Sequential FSM 
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
            if (timer != 16'd0) 
            begin 
                timer <= timer - 16'd1; 
            end 
            else 
            begin 
                case (state) 
 
                    //------------------------------------------------- 
                    // NS Green -> NS Yellow 
                    //------------------------------------------------- 
                    S_NS_GREEN: 
                    begin 
                        state <= S_NS_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    //------------------------------------------------- 
                    // NS Yellow -> EW Green 

                    //------------------------------------------------- 
                    S_NS_YELLOW: 
                    begin 
                        state <= S_EW_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    //------------------------------------------------- 
                    // EW Green -> EW Yellow 
                    //------------------------------------------------- 
                    S_EW_GREEN: 
                    begin 
                        state <= S_EW_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    //------------------------------------------------- 
                    // EW Yellow -> NS Green 
                    //------------------------------------------------- 
                    S_EW_YELLOW: 
                    begin 
                        state <= S_NS_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    //------------------------------------------------- 
                    // Recovery State 
                    //------------------------------------------------- 

                    default: 
                    begin 
                        state <= S_NS_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                endcase 
            end 
        end 
    end 
 
    //----------------------------------------------------- 
    // Output Decode Logic 
    // Full coverage => No inferred latches 
    //----------------------------------------------------- 
    always @(*) 
    begin 
        // Default outputs 
        red    = 2'b11; 
        yellow = 2'b00; 
        green  = 2'b00; 
 
        case (state) 
 
            //------------------------------------------------- 
            // North/South Green 
            //------------------------------------------------- 
            S_NS_GREEN: 

            begin 
                red    = 2'b10; 
                yellow = 2'b00; 
                green  = 2'b01; 
            end 
 
            //------------------------------------------------- 
            // North/South Yellow 
            //------------------------------------------------- 
            S_NS_YELLOW: 
            begin 
                red    = 2'b10; 
                yellow = 2'b01; 
                green  = 2'b00; 
            end 
 
            //------------------------------------------------- 
            // East/West Green 
            //------------------------------------------------- 
            S_EW_GREEN: 
            begin 
                red    = 2'b01; 
                yellow = 2'b00; 
                green  = 2'b10; 
            end 
 
            //------------------------------------------------- 
            // East/West Yellow 

            //------------------------------------------------- 
            S_EW_YELLOW: 
            begin 
                red    = 2'b01; 
                yellow = 2'b10; 
                green  = 2'b00; 
            end 
 
            //------------------------------------------------- 
            // Safe Default 
            //------------------------------------------------- 
            default: 
            begin 
                red    = 2'b11; 
                yellow = 2'b00; 
                green  = 2'b00; 
            end 
 
        endcase 
    end 
 
endmodule