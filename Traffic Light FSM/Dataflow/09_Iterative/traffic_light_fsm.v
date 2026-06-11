module traffic_light_fsm 
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
 
    //========================================================= 
    // 16-State One-Hot Encoding 
    //========================================================= 
    localparam [15:0] 
        N_RED    = 16'h0001, 
        N_YELLOW = 16'h0002, 
        N_GREEN  = 16'h0004, 
        N_WALK   = 16'h0008, 
 
        S_RED    = 16'h0010, 
        S_YELLOW = 16'h0020, 
        S_GREEN  = 16'h0040, 
        S_WALK   = 16'h0080, 
 
        E_RED    = 16'h0100, 
        E_YELLOW = 16'h0200, 
        E_GREEN  = 16'h0400, 
        E_WALK   = 16'h0800, 
 
        W_RED    = 16'h1000, 
        W_YELLOW = 16'h2000, 
        W_GREEN  = 16'h4000, 
        W_WALK   = 16'h8000; 
 

    //========================================================= 
    // State Register 
    //========================================================= 
    (* fsm_encoding = "one_hot" *) 
    reg [15:0] state; 
 
    //========================================================= 
    // Timer 
    //========================================================= 
    reg [15:0] timer; 
 
    wire timer_expire; 
    assign timer_expire = (timer == 16'd0); 
 
    //========================================================= 
    // Iteration 3: Extracted Subterm 
    //========================================================= 
    (* keep = "false" *) wire advance; // iter3: extracted subterm 
                                      // iter4: power hint 
 
    assign advance = timer_expire;    // iter3: extracted subterm 
 
    //========================================================= 
    // Iteration 2: Simplified One-Hot Next-State Equations 
    //========================================================= 
    (* keep = "false" *) wire [15:0] next_state; // iter4: power hint 
 
    assign next_state[0]  = advance ? state[15] : state[0];   // iter2: simplified 

    assign next_state[1]  = advance ? state[0]  : state[1];   // iter2: simplified 
    assign next_state[2]  = advance ? state[1]  : state[2];   // iter2: simplified 
    assign next_state[3]  = advance ? state[2]  : state[3];   // iter2: simplified 
 
    assign next_state[4]  = advance ? state[3]  : state[4];   // iter2: simplified 
    assign next_state[5]  = advance ? state[4]  : state[5];   // iter2: simplified 
    assign next_state[6]  = advance ? state[5]  : state[6];   // iter2: simplified 
    assign next_state[7]  = advance ? state[6]  : state[7];   // iter2: simplified 
 
    assign next_state[8]  = advance ? state[7]  : state[8];   // iter2: simplified 
    assign next_state[9]  = advance ? state[8]  : state[9];   // iter2: simplified 
    assign next_state[10] = advance ? state[9]  : state[10];  // iter2: simplified 
    assign next_state[11] = advance ? state[10] : state[11];  // iter2: simplified 
 
    assign next_state[12] = advance ? state[11] : state[12];  // iter2: simplified 
    assign next_state[13] = advance ? state[12] : state[13];  // iter2: simplified 
    assign next_state[14] = advance ? state[13] : state[14];  // iter2: simplified 
    assign next_state[15] = advance ? state[14] : state[15];  // iter2: simplified 
 
    //========================================================= 
    // State FF 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= N_RED; 
        else 
            state <= next_state; 

    end 
 
    //========================================================= 
    // Timer FF 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= PHASE_TIME; 
        else if (timer_expire) 
            timer <= PHASE_TIME; 
        else 
            timer <= timer - 16'd1; 
    end 
 
    //========================================================= 
    // Output Decode 
    // Direct one-hot decode 
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
 
endmodule