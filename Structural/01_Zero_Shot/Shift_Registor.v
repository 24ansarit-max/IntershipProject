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
    parameter WIDTH = 16 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             load, 
    input  wire             serial_in, 
    input  wire [WIDTH-1:0] parallel_in, 
    output wire             serial_out, 
    output wire [WIDTH-1:0] parallel_out 
); 
 
    wire [WIDTH-1:0] q_int; 
    wire [WIDTH-1:0] d_in; 
 
    genvar i; 
 

    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_SHIFT 
 
            if (i == 0) begin : FIRST_BIT 
                assign d_in[i] = load ? parallel_in[i] : serial_in; 
            end 
            else begin : OTHER_BITS 
                assign d_in[i] = load ? parallel_in[i] : q_int[i-1]; 
            end 
 
        end 
    endgenerate 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_DFFS 
 
            dff u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .d     (d_in[i]), 
                .q     (q_int[i]) 
            ); 
 
        end 
    endgenerate 
 
    assign parallel_out = q_int; 
    assign serial_out   = q_int[WIDTH-1]; 

 
endmodule