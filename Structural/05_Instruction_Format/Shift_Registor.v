`timescale 1ns/1ps 
 
module dff_ce #( 
    parameter INIT_BIT = 1'b0 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire d, 
    output reg  q 
); 
 
    always @(posedge clk) begin 
        if (!rst_n) 
            q <= INIT_BIT; 
        else if (ce) 
            q <= d; 
    end 
 

endmodule 
 
(* use_dsp = "no" *) 
(* shreg_extract = "yes" *) 
module sr16_struct #( 
    parameter WIDTH     = 16, 
    parameter DIRECTION = 2'b00, 
    parameter USE_CE    = 1, 
    parameter INIT      = 16'h0000 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             ce, 
    input  wire             dir, 
    input  wire             load, 
    input  wire             serial_in, 
    input  wire [WIDTH-1:0] parallel_in, 
    output wire [WIDTH-1:0] parallel_out, 
    output wire             serial_out 
); 
 
    wire [WIDTH-1:0] q_int; 
    wire [WIDTH-1:0] d_next; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_SHIFT 

 
            if (i == 0) begin : FIRST_BIT 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? q_int[i+1] : 
                           serial_in; 
 
            end 
            else if (i == WIDTH-1) begin : LAST_BIT 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? serial_in : 
                           q_int[i-1]; 
 
            end 
            else begin : MID_BITS 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? q_int[i+1] : 
                           q_int[i-1]; 
 
            end 
 
        end 
    endgenerate 

 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_DFF 
 
            dff_ce #( 
                .INIT_BIT(INIT[i]) 
            ) u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .ce    (USE_CE ? ce : 1'b1), 
                .d     (d_next[i]), 
                .q     (q_int[i]) 
            ); 
 
        end 
    endgenerate 
 
    assign parallel_out = q_int; 
 
    assign serial_out = dir ? 
                        q_int[0] : 
                        q_int[WIDTH-1]; 
 
endmodule