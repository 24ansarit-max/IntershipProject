// v1.0 - structural baseline 
// [POWER]  ~9 mW (no clock enable — all FFs toggle freely) 
// [AREA]   16 FFs, 0 LUTs (pure shift chain) 
// [DELAY]  ~1.9 ns FF-to-FF (single FDCE stage) 
 
module dff( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire d, 
    output reg  q 
); 
 
    always @(posedge clk) 
        if (!rst_n) 
            q <= 1'b0; 
        else 
            q <= d; 
 
endmodule 
 
 
module sr16_v1 #( 
    parameter WIDTH = 16 
)( 

    input  wire clk, 
    input  wire rst_n, 
    input  wire serial_in, 
    output wire serial_out 
); 
 
    wire [WIDTH:0] chain; 
 
    assign chain[0] = serial_in; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : dff_chain 
 
            dff u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .d     (chain[i]), 
                .q     (chain[i+1]) 
            ); 
 
        end 
    endgenerate 
 
    assign serial_out = chain[WIDTH]; 
 
endmodule