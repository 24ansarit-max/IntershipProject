`timescale 1ns/1ps 
 
module dff ( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire d, 
    output reg  q 
); 
 
    always @(posedge clk or negedge rst_n) begin 

        if (!rst_n) 
            q <= 1'b0; 
        else 
            q <= d; 
    end 
 
endmodule 
 
module shift_reg_16 #( 
    parameter WIDTH      = 16, 
    parameter LOW_POWER  = 1, 
    parameter ARTIX7_OPT = 1 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
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
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_shift_logic 
 
            if (i == 0) begin : bit0 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? q_int[i+1] : 
                           serial_in; 
 
            end 
            else if (i == WIDTH-1) begin : bit_last 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? serial_in : 
                           q_int[i-1]; 
 
            end 
            else begin : bit_middle 
 
                assign d_next[i] = 
                    load ? parallel_in[i] : 
                    dir  ? q_int[i+1] : 
                           q_int[i-1]; 
 
            end 

 
        end 
    endgenerate 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_dff_array 
 
            dff u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .d     (d_next[i]), 
                .q     (q_int[i]) 
            ); 
 
        end 
    endgenerate 
 
    assign parallel_out = q_int; 
 
    assign serial_out = dir ? q_int[0] : q_int[WIDTH-1]; 
 
endmodule