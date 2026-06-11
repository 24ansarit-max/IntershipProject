module tl_outdec 
( 
    input  wire [15:0] state, 
 
    output reg red_n, 
    output reg yellow_n, 
    output reg green_n, 
    output reg walk_n, 
 
    output reg red_s, 
    output reg yellow_s, 
    output reg green_s, 
    output reg walk_s, 
 
    output reg red_e, 
    output reg yellow_e, 
    output reg green_e, 
    output reg walk_e, 

 
    output reg red_w, 
    output reg yellow_w, 
    output reg green_w, 
    output reg walk_w 
); 
 
always @(*) 
begin 
    red_n    = 1'b0; 
    yellow_n = 1'b0; 
    green_n  = 1'b0; 
    walk_n   = 1'b0; 
 
    red_s    = 1'b0; 
    yellow_s = 1'b0; 
    green_s  = 1'b0; 
    walk_s   = 1'b0; 
 
    red_e    = 1'b0; 
    yellow_e = 1'b0; 
    green_e  = 1'b0; 
    walk_e   = 1'b0; 
 
    red_w    = 1'b0; 
    yellow_w = 1'b0; 
    green_w  = 1'b0; 
    walk_w   = 1'b0; 

 
    case(state) 
        16'h0001: red_n    = 1'b1; 
        16'h0002: yellow_n = 1'b1; 
        16'h0004: green_n  = 1'b1; 
        16'h0008: walk_n   = 1'b1; 
 
        16'h0010: red_s    = 1'b1; 
        16'h0020: yellow_s = 1'b1; 
        16'h0040: green_s  = 1'b1; 
        16'h0080: walk_s   = 1'b1; 
 
        16'h0100: red_e    = 1'b1; 
        16'h0200: yellow_e = 1'b1; 
        16'h0400: green_e  = 1'b1; 
        16'h0800: walk_e   = 1'b1; 
 
        16'h1000: red_w    = 1'b1; 
        16'h2000: yellow_w = 1'b1; 
        16'h4000: green_w  = 1'b1; 
        16'h8000: walk_w   = 1'b1; 
 
        default: red_n = 1'b1; 
    endcase 
end 
 
endmodule