module traffic_light_fsm 
( 
    input  wire clk, 
    input  wire rst, 
    input  wire timer_expire, 
 
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
 
    //========================================================= 
    // State Encoding 
    //========================================================= 
    localparam [15:0] N_RED    = 16'h0001; 
 
    //========================================================= 
    // State Register 
    //========================================================= 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    //========================================================= 
    // SECTION: Subterm wires 
    //========================================================= 
    (* keep = "false" *) wire adv;      // iter3 
    (* keep = "false" *) wire adv_n;    // iter3 
 
    assign adv   = timer_expire;        // iter2 
    assign adv_n = ~timer_expire;       // iter2 
 
    //========================================================= 
    // SECTION: Next-state assigns 
    //========================================================= 

    (* keep = "false" *) wire [15:0] next_state;   // iter3 
 
    assign next_state[0]  = (state[15] & adv) | (state[0]  & adv_n); 
    assign next_state[1]  = (state[0]  & adv) | (state[1]  & adv_n); 
    assign next_state[2]  = (state[1]  & adv) | (state[2]  & adv_n); 
    assign next_state[3]  = (state[2]  & adv) | (state[3]  & adv_n); 
 
    assign next_state[4]  = (state[3]  & adv) | (state[4]  & adv_n); 
    assign next_state[5]  = (state[4]  & adv) | (state[5]  & adv_n); 
    assign next_state[6]  = (state[5]  & adv) | (state[6]  & adv_n); 
    assign next_state[7]  = (state[6]  & adv) | (state[7]  & adv_n); 
 
    assign next_state[8]  = (state[7]  & adv) | (state[8]  & adv_n); 
    assign next_state[9]  = (state[8]  & adv) | (state[9]  & adv_n); 
    assign next_state[10] = (state[9]  & adv) | (state[10] & adv_n); 
    assign next_state[11] = (state[10] & adv) | (state[11] & adv_n); 
 
    assign next_state[12] = (state[11] & adv) | (state[12] & adv_n); 
    assign next_state[13] = (state[12] & adv) | (state[13] & adv_n); 
    assign next_state[14] = (state[13] & adv) | (state[14] & adv_n); 
    assign next_state[15] = (state[14] & adv) | (state[15] & adv_n); 
 
    //========================================================= 
    // SECTION: State FF (always @posedge) 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 

            state <= N_RED; 
        else 
            state <= next_state; 
    end 
 
    //========================================================= 
    // SECTION: Output assigns 
    //========================================================= 
    assign red_n    = state[0]; 
    assign yellow_n = state[1]; 
    assign green_n  = state[2]; 
    assign walk_n   = state[3]; 
 
    assign red_s    = state[4]; 
    assign yellow_s = state[5]; 
    assign green_s  = state[6]; 
    assign walk_s   = state[7]; 
 
    assign red_e    = state[8]; 
    assign yellow_e = state[9]; 
    assign green_e  = state[10]; 
    assign walk_e   = state[11]; 
 
    assign red_w    = state[12]; 
    assign yellow_w = state[13]; 
    assign green_w  = state[14]; 
    assign walk_w   = state[15]; 
 

    //========================================================= 
    // SECTION: PPA summary 
    //========================================================= 
    // FF            : 16 
    // LUT estimate  : ~17 
    // Logic depth   : 1-2 LUT6 levels 
    // Fmax estimate : >250 MHz (Artix-7 -2) 
    // Power         : very low; only two state bits toggle 
    // Reset         : synchronous active-high 
    // Latches       : none 
    // Style         : assign-only combinational logic 
    //========================================================= 
 
endmodule