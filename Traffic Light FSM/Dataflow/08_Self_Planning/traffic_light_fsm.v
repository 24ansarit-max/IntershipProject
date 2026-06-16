module traffic_light_fsm 
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
 
    //--------------------------------------------------------- 
    // One-Hot State Encoding 
    //--------------------------------------------------------- 
    localparam [15:0] 
        N_RED    = 16'h0001; 
 
    //--------------------------------------------------------- 
    // State Register 
    //--------------------------------------------------------- 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 

    //--------------------------------------------------------- 
    // Shared Aliases 
    //--------------------------------------------------------- 
    wire s0  = state[0]; 
    wire s1  = state[1]; 
    wire s2  = state[2]; 
    wire s3  = state[3]; 
    wire s4  = state[4]; 
    wire s5  = state[5]; 
    wire s6  = state[6]; 
    wire s7  = state[7]; 
    wire s8  = state[8]; 
    wire s9  = state[9]; 
    wire s10 = state[10]; 
    wire s11 = state[11]; 
    wire s12 = state[12]; 
    wire s13 = state[13]; 
    wire s14 = state[14]; 
    wire s15 = state[15]; 
 
    //--------------------------------------------------------- 
    // Next-State Equations 
    //--------------------------------------------------------- 
    wire [15:0] next_state; 
 
    assign next_state[0]  = s15; 
    assign next_state[1]  = s0; 
    assign next_state[2]  = s1; 

    assign next_state[3]  = s2; 
 
    assign next_state[4]  = s3; 
    assign next_state[5]  = s4; 
    assign next_state[6]  = s5; 
    assign next_state[7]  = s6; 
 
    assign next_state[8]  = s7; 
    assign next_state[9]  = s8; 
    assign next_state[10] = s9; 
    assign next_state[11] = s10; 
 
    assign next_state[12] = s11; 
    assign next_state[13] = s12; 
    assign next_state[14] = s13; 
    assign next_state[15] = s14; 
 
    //--------------------------------------------------------- 
    // State FF 
    //--------------------------------------------------------- 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= N_RED; 
        else 
            state <= next_state; 
    end 
 

    //--------------------------------------------------------- 
    // Output Equations 
    //--------------------------------------------------------- 
    assign red_n    = s0; 
    assign yellow_n = s1; 
    assign green_n  = s2; 
    assign walk_n   = s3; 
 
    assign red_s    = s4; 
    assign yellow_s = s5; 
    assign green_s  = s6; 
    assign walk_s   = s7; 
 
    assign red_e    = s8; 
    assign yellow_e = s9; 
    assign green_e  = s10; 
    assign walk_e   = s11; 
 
    assign red_w    = s12; 
    assign yellow_w = s13; 
    assign green_w  = s14; 
    assign walk_w   = s15; 
 
endmodule