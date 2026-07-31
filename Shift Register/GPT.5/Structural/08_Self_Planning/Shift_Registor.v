`timescale 1ns/1ps 
 
module dff_ce ( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire d, 
    output reg  q 
); 
 
    always @(posedge clk) begin 
        if (!rst_n) 
            q <= 1'b0; 
        else if (ce) 
            q <= d; 
    end 
 
endmodule 
 
 
module sr16_universal_struct #( 
    parameter WIDTH = 16 
)( 

    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             ce, 
    input  wire             dir, 
    input  wire             load, 
    input  wire             serial_in, 
    input  wire [WIDTH-1:0] parallel_in, 
    output wire [WIDTH-1:0] parallel_out 
); 
 
    wire [WIDTH-1:0] q; 
    wire [WIDTH-1:0] d; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : dff_chain 
 
            if (i == 0) begin : first_bit 
 
                assign d[i] = 
                    load ? parallel_in[i] : 
                    (dir ? q[i+1] : serial_in); 
 
            end 
            else if (i == WIDTH-1) begin : last_bit 
 
                assign d[i] = 

                    load ? parallel_in[i] : 
                    (dir ? serial_in : q[i-1]); 
 
            end 
            else begin : middle_bits 
 
                assign d[i] = 
                    load ? parallel_in[i] : 
                    (dir ? q[i+1] : q[i-1]); 
 
            end 
 
            dff_ce u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .ce    (ce), 
                .d     (d[i]), 
                .q     (q[i]) 
            ); 
 
        end 
    endgenerate 
 
    assign parallel_out = q; 
 
endmodule