`timescale 1ns/1ps 
//============================================================ 
// 16-State Traffic Light FSM 
// Behavioral Verilog 

// 
// Target FPGA : xc7a100tcsg324-2 (Nexys A7) 
// Encoding    : 16-bit One-Hot 
// Reset       : Synchronous Active-High 
// 
// Organization: 
//   4 Directions × 4 Phases 
// 
// Direction 0 : North 
// Direction 1 : East 
// Direction 2 : South 
// Direction 3 : West 
// 
// Phases: 
//   RED 
//   YELLOW 
//   GREEN 
//   WALK 
// 
// Total States = 16 
// 
// Outputs: 
//   red[3:0] 
//   yellow[3:0] 
//   green[3:0] 
//   walk[3:0] 
// 
// Notes: 

// - One-hot state machine 
// - 16-bit timer register 
// - Fully specified case statements 
// - No inferred latches 
// - Synthesizable on Artix-7 
//============================================================ 
 
module traffic_light_fsm16 
( 
    input  wire       clk, 
    input  wire       rst, 
 
    output reg [3:0]  red, 
    output reg [3:0]  yellow, 
    output reg [3:0]  green, 
    output reg [3:0]  walk 
); 
 
    //-------------------------------------------------------- 
    // Phase Durations 
    //-------------------------------------------------------- 
    parameter [15:0] RED_TIME    = 16'd1000; 
    parameter [15:0] YELLOW_TIME = 16'd250; 
    parameter [15:0] GREEN_TIME  = 16'd750; 
    parameter [15:0] WALK_TIME   = 16'd500; 
 
    //-------------------------------------------------------- 
    // 16 One-Hot States 

    //-------------------------------------------------------- 
    parameter [15:0] 
        N_RED     = 16'h0001, 
        N_YELLOW  = 16'h0002, 
        N_GREEN   = 16'h0004, 
        N_WALK    = 16'h0008, 
 
        E_RED     = 16'h0010, 
        E_YELLOW  = 16'h0020, 
        E_GREEN   = 16'h0040, 
        E_WALK    = 16'h0080, 
 
        S_RED     = 16'h0100, 
        S_YELLOW  = 16'h0200, 
        S_GREEN   = 16'h0400, 
        S_WALK    = 16'h0800, 
 
        W_RED     = 16'h1000, 
        W_YELLOW  = 16'h2000, 
        W_GREEN   = 16'h4000, 
        W_WALK    = 16'h8000; 
 
    //-------------------------------------------------------- 
    // State Register 
    //-------------------------------------------------------- 
    reg [15:0] state; 
 
    //-------------------------------------------------------- 

    // 16-bit Phase Timer 
    //-------------------------------------------------------- 
    reg [15:0] timer; 
 
    //-------------------------------------------------------- 
    // Sequential FSM 
    //-------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
        begin 
            // Reset into North RED state 
            state <= N_RED; 
            timer <= RED_TIME; 
        end 
        else 
        begin 
            if (timer != 16'd0) 
            begin 
                // Countdown active phase 
                timer <= timer - 16'd1; 
            end 
            else 
            begin 
                case (state) 
 
                    //======================================== 
                    // NORTH Direction 

                    //======================================== 
                    N_RED: 
                    begin 
                        state <= N_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    N_YELLOW: 
                    begin 
                        state <= N_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    N_GREEN: 
                    begin 
                        state <= N_WALK; 
                        timer <= WALK_TIME; 
                    end 
 
                    N_WALK: 
                    begin 
                        state <= E_RED; 
                        timer <= RED_TIME; 
                    end 
 
                    //======================================== 
                    // EAST Direction 
                    //======================================== 

                    E_RED: 
                    begin 
                        state <= E_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    E_YELLOW: 
                    begin 
                        state <= E_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    E_GREEN: 
                    begin 
                        state <= E_WALK; 
                        timer <= WALK_TIME; 
                    end 
 
                    E_WALK: 
                    begin 
                        state <= S_RED; 
                        timer <= RED_TIME; 
                    end 
 
                    //======================================== 
                    // SOUTH Direction 
                    //======================================== 
                    S_RED: 

                    begin 
                        state <= S_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    S_YELLOW: 
                    begin 
                        state <= S_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    S_GREEN: 
                    begin 
                        state <= S_WALK; 
                        timer <= WALK_TIME; 
                    end 
 
                    S_WALK: 
                    begin 
                        state <= W_RED; 
                        timer <= RED_TIME; 
                    end 
 
                    //======================================== 
                    // WEST Direction 
                    //======================================== 
                    W_RED: 
                    begin 

                        state <= W_YELLOW; 
                        timer <= YELLOW_TIME; 
                    end 
 
                    W_YELLOW: 
                    begin 
                        state <= W_GREEN; 
                        timer <= GREEN_TIME; 
                    end 
 
                    W_GREEN: 
                    begin 
                        state <= W_WALK; 
                        timer <= WALK_TIME; 
                    end 
 
                    W_WALK: 
                    begin 
                        state <= N_RED; 
                        timer <= RED_TIME; 
                    end 
 
                    //======================================== 
                    // Recovery State 
                    //======================================== 
                    default: 
                    begin 
                        state <= N_RED; 

                        timer <= RED_TIME; 
                    end 
 
                endcase 
            end 
        end 
    end 
 
    //-------------------------------------------------------- 
    // Output Decoder 
    // Fully specified => no latches 
    //-------------------------------------------------------- 
    always @(*) 
    begin 
        // Default outputs 
        red    = 4'b0000; 
        yellow = 4'b0000; 
        green  = 4'b0000; 
        walk   = 4'b0000; 
 
        case (state) 
 
            // North 
            N_RED:    red[0]    = 1'b1; 
            N_YELLOW: yellow[0] = 1'b1; 
            N_GREEN:  green[0]  = 1'b1; 
            N_WALK:   walk[0]   = 1'b1; 
 

            // East 
            E_RED:    red[1]    = 1'b1; 
            E_YELLOW: yellow[1] = 1'b1; 
            E_GREEN:  green[1]  = 1'b1; 
            E_WALK:   walk[1]   = 1'b1; 
 
            // South 
            S_RED:    red[2]    = 1'b1; 
            S_YELLOW: yellow[2] = 1'b1; 
            S_GREEN:  green[2]  = 1'b1; 
            S_WALK:   walk[2]   = 1'b1; 
 
            // West 
            W_RED:    red[3]    = 1'b1; 
            W_YELLOW: yellow[3] = 1'b1; 
            W_GREEN:  green[3]  = 1'b1; 
            W_WALK:   walk[3]   = 1'b1; 
 
            default: 
            begin 
                red    = 4'b0000; 
                yellow = 4'b0000; 
                green  = 4'b0000; 
                walk   = 4'b0000; 
            end 
 
        endcase 
    end 

 
endmodule