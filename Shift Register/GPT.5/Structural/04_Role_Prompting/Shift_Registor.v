`timescale 1ns/1ps 
 
(* use_dsp = "no" *) 
(* shreg_extract = "yes" *) 
module shift_reg_16 #( 
    parameter integer WIDTH = 16 
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
 
    /* 
    ============================================================ 
    PARAMETER TRADEOFF GUIDE (Artix-7 xc7a100tcsg324-2) 
    ============================================================ 
    WIDTH   FFs   LUTs(est.)   Power(est.)   Delay(est.) 
    ---------------------------------------------------- 
      4      4       4-6       Very Low      <1.0 ns 
      8      8       8-10      Low           <1.5 ns 
     16     16      14-16      Low           <2.0 ns 
     32     32      24-30      Moderate      <2.5 ns 
    ---------------------------------------------------- 
    Expected Vivado Results (WIDTH=16): 
      Slice LUTs : ~14-16 
      Slice FFs  : 16 
      WNS Target : > 0 ns @ 200 MHz 
    ============================================================ 
    */ 
 
    wire [WIDTH-1:0] q_int; 
    wire [WIDTH-1:0] d_next; 
 
    genvar i; 
 

    generate 
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_SHIFT 
            /* 
            genvar-for selected because Vivado fully unrolls the logic. 
            This produces local routing and shallow mux structures, 
            minimizing LUT depth on Artix-7 6-input LUT architecture. 
            */ 
 
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
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_FF 
 
            reg q_reg; 
 
            always @(posedge clk or negedge rst_n) begin 
                if (!rst_n) 
                    q_reg <= 1'b0; 
                else if (ce) 
                    q_reg <= d_next[i]; 
            end 
 
            assign q_int[i] = q_reg; 
 
        end 
    endgenerate 
 
    assign parallel_out = q_int; 
 
    assign serial_out = 
        dir ? q_int[0] : 

              q_int[WIDTH-1]; 
 
endmodule 
 
 
/************************************************************** 
SELF-CHECK TESTBENCH SNIPPET 
Shift 16'hABCD left by 4 positions 
************************************************************** 
 
initial begin 
 
    rst_n       = 0; 
    ce          = 1; 
    dir         = 0; 
    load        = 0; 
    serial_in   = 0; 
    parallel_in = 16'h0000; 
 
    #20; 
    rst_n = 1; 
 
    load        = 1; 
    parallel_in = 16'hABCD; 
    @(posedge clk); 
 
    load = 0; 
    dir  = 0; 

 
    repeat (4) begin 
        serial_in = 0; 
        @(posedge clk); 
    end 
 
    if (parallel_out == (16'hABCD << 4)) 
        $display("PASS"); 
    else 
        $display("FAIL expected=%h got=%h" , 
                 (16'hABCD << 4), 
                 parallel_out); 
 
end 
 
**************************************************************/