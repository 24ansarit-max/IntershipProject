module traffic_light_fsm 
#( 
    parameter TIMER_MAX = 16'd50000 
) 
( 
    input  wire clk, 
    input  wire rst, 
 
    output reg [15:0] state 
); 
 
    //--------------------------------------------------------- 
    // STEP 1 : One-Hot State Encoding 

    //--------------------------------------------------------- 
 
    localparam NS_RED    = 16'b0000_0000_0000_0001; 
    localparam NS_YELLOW = 16'b0000_0000_0000_0010; 
    localparam NS_GREEN  = 16'b0000_0000_0000_0100; 
    localparam NS_WALK   = 16'b0000_0000_0000_1000; 
 
    localparam EW_RED    = 16'b0000_0000_0001_0000; 
    localparam EW_YELLOW = 16'b0000_0000_0010_0000; 
    localparam EW_GREEN  = 16'b0000_0000_0100_0000; 
    localparam EW_WALK   = 16'b0000_0000_1000_0000; 
 
    localparam N_RED     = 16'b0000_0001_0000_0000; 
    localparam N_YELLOW  = 16'b0000_0010_0000_0000; 
    localparam N_GREEN   = 16'b0000_0100_0000_0000; 
    localparam N_WALK    = 16'b0000_1000_0000_0000; 
 
    localparam S_RED     = 16'b0001_0000_0000_0000; 
    localparam S_YELLOW  = 16'b0010_0000_0000_0000; 
    localparam S_GREEN   = 16'b0100_0000_0000_0000; 
    localparam S_WALK    = 16'b1000_0000_0000_0000; 
 
    //--------------------------------------------------------- 
    // FF Count: 
    // State Register = 16 FFs 
    //--------------------------------------------------------- 
 
    reg [15:0] state_next; 

 
    //--------------------------------------------------------- 
    // Timer Register 
    // FF Count = 16 FFs 
    //--------------------------------------------------------- 
 
    reg [15:0] timer; 
 
    wire timer_done; 
 
    assign timer_done = (timer == TIMER_MAX); 
 
    //--------------------------------------------------------- 
    // Sequential State Register 
    // 
    // Critical Path Contribution: 
    // FF -> Decode -> Mux -> FF 
    //--------------------------------------------------------- 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            state <= NS_RED; 
        else 
            state <= state_next; 
    end 
 
    //--------------------------------------------------------- 

    // Sequential Timer 
    // 
    // FF Count = 16 
    //--------------------------------------------------------- 
 
    always @(posedge clk) 
    begin 
        if (rst) 
            timer <= 16'd0; 
        else if (timer_done) 
            timer <= 16'd0; 
        else 
            timer <= timer + 16'd1; 
    end 
 
    //--------------------------------------------------------- 
    // STEP 3 
    // Next-State Combinational Logic 
    // 
    // Mux Depth: 
    // One LUT level + state selection mux 
    // 
    // No Latch Risk: 
    // state_next assigned in all paths 
    //--------------------------------------------------------- 
 
    always @(*) 
    begin 

        state_next = state; 
 
        case (state) 
 
            NS_RED: 
                if (timer_done) state_next = NS_YELLOW; 
 
            NS_YELLOW: 
                if (timer_done) state_next = NS_GREEN; 
 
            NS_GREEN: 
                if (timer_done) state_next = NS_WALK; 
 
            NS_WALK: 
                if (timer_done) state_next = EW_RED; 
 
            EW_RED: 
                if (timer_done) state_next = EW_YELLOW; 
 
            EW_YELLOW: 
                if (timer_done) state_next = EW_GREEN; 
 
            EW_GREEN: 
                if (timer_done) state_next = EW_WALK; 
 
            EW_WALK: 
                if (timer_done) state_next = N_RED; 
 

            N_RED: 
                if (timer_done) state_next = N_YELLOW; 
 
            N_YELLOW: 
                if (timer_done) state_next = N_GREEN; 
 
            N_GREEN: 
                if (timer_done) state_next = N_WALK; 
 
            N_WALK: 
                if (timer_done) state_next = S_RED; 
 
            S_RED: 
                if (timer_done) state_next = S_YELLOW; 
 
            S_YELLOW: 
                if (timer_done) state_next = S_GREEN; 
 
            S_GREEN: 
                if (timer_done) state_next = S_WALK; 
 
            S_WALK: 
                if (timer_done) state_next = NS_RED; 
 
            default: 
                state_next = NS_RED; 
 
        endcase 

    end 
 
endmodule