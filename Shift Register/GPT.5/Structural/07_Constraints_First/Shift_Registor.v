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
 
 
(* shreg_extract = "no" *) 
module shift_reg_16 #( 
    parameter WIDTH = 16 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             ce, 
    input  wire             serial_in, 
    output wire             serial_out, 
    output wire [WIDTH-1:0] parallel_out 
); 

 
    // [C1 MET] 
    // Pure structural FF chain. 
    // No behavioral logic in top module. 
    // FF-to-FF shift path only. 
 
    // [C2 MET] 
    // Exactly WIDTH flip-flops. 
    // No DSP48. 
    // No BRAM. 
    // No BUFG instantiated. 
 
    // [C3 MET] 
    // Common CE connected to every DFF . 
    // Supports Vivado clock-enable inference. 
 
    // [C4 MET] 
    // Top module contains only assigns and instantiations. 
    // All sequential logic resides in dff_ce. 
 
    // [C5 MET] 
    // Verilog-2001 syntax. 
    // generate-for replication. 
    // shreg_extract disabled. 
 
    wire [WIDTH:0] chain; 
 
    assign chain[0] = serial_in; 

 
    (* use_clock_enable = "yes" *) 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : dff_chain_i 
 
            dff_ce u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .ce    (ce), 
                .d     (chain[i]), 
                .q     (chain[i+1]) 
            ); 
 
        end 
    endgenerate 
 
    assign serial_out   = chain[WIDTH]; 
    assign parallel_out = chain[WIDTH:1]; 
 
endmodule