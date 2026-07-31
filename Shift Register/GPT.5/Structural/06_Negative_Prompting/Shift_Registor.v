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
 
 
module shift_reg_16 #( 
    parameter WIDTH = 16 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             ce, 
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
                           serial_in; 
 
            end 
            else begin : OTHER_BITS 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                           q_int[i-1]; 
 
            end 
 
        end 
    endgenerate 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_DFF 
 
            dff_ce #( 
                .INIT_BIT(1'b0) 
            ) u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 

                .ce    (ce), 
                .d     (d_next[i]), 
                .q     (q_int[i]) 
            ); 
 
        end 
    endgenerate 
 
    assign parallel_out = q_int; 
    assign serial_out   = q_int[WIDTH-1]; 
 
endmodule