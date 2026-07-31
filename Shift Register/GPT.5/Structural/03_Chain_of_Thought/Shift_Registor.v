`timescale 1ns/1ps 
 

module dff_ce #( 
    parameter INIT = 1'b0 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire d, 
    output reg  q 
); 
 
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) 
            q <= INIT; 
        else if (ce) 
            q <= d; 
    end 
 
endmodule 
 
 
module sr16 #( 
    parameter integer WIDTH     = 16, 
    parameter         DIRECTION = "LEFT" , 
    parameter         INIT      = 1'b0, 
    parameter         USE_CE    = 1 
)( 
    input  wire             clk, 
    input  wire             rst_n, 

    input  wire             ce, 
    input  wire             dir, 
    input  wire             load, 
    input  wire             serial_in, 
    input  wire [WIDTH-1:0] parallel_in, 
 
    output wire             serial_out, 
    output wire [WIDTH-1:0] parallel_out 
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
            else begin : MIDDLE_BITS 
 
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
                .INIT(INIT) 
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
 
    assign serial_out = 
        dir ? q_int[0] : 
              q_int[WIDTH-1]; 
 
endmodule