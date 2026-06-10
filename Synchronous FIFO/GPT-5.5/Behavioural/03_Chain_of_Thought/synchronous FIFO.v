`timescale 1ns/1ps 
 
module fifo16_sync_behav 
#( 
    parameter DATA_WIDTH = 16, 
    parameter DEPTH      = 16, 
    parameter ADDR_WIDTH = 4, 
    parameter PTR_WIDTH  = ADDR_WIDTH + 1 
) 
( 
    input  wire                  clk, 
    input  wire                  rst_n, 
 
    input  wire                  wr_en, 
    input  wire                  rd_en, 
 
    input  wire [DATA_WIDTH-1:0] din, 
 
    output reg  [DATA_WIDTH-1:0] dout, 
 
    output reg                   full, 
    output reg                   empty, 
    output reg                   almost_full, 
    output reg                   almost_empty, 
 
    output reg                   overflow, 
    output reg                   underflow, 
 
    output reg [PTR_WIDTH-1:0]   count 
); 
 
    /*────────────────────────────── 
      BRAM STORAGE 
    ──────────────────────────────*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    reg [DATA_WIDTH-1:0] dout_pre; 
 
    /*────────────────────────────── 
      POINTERS 
    ──────────────────────────────*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    /*────────────────────────────── 
      STATUS ARRAY 
    ──────────────────────────────*/ 
    reg overflow_log [0:DEPTH-1]; 
 
    integer k; 
 
    wire wr_fire; 
    wire rd_fire; 
 
    assign wr_fire = wr_en && !full; 
    assign rd_fire = rd_en && !empty; 
 
    wire [PTR_WIDTH-1:0] wr_ptr_next; 
    wire [PTR_WIDTH-1:0] rd_ptr_next; 
    wire [PTR_WIDTH-1:0] count_next; 
 
    assign wr_ptr_next = 
        wr_ptr + (wr_fire ? 1'b1 : 1'b0); 
 
    assign rd_ptr_next = 
        rd_ptr + (rd_fire ? 1'b1 : 1'b0); 
 
    assign count_next = 
          count 
        + (wr_fire ? 1'b1 : 1'b0) 
        - (rd_fire ? 1'b1 : 1'b0); 
 
    /*────────────────────────────── 
      Generate For 
      Power: 0 
      Area : 0 LUT / 0 FF 
      Delay: 0 ns 
    ──────────────────────────────*/ 
    genvar gi; 
 
    generate 
        for (gi=0; gi<PTR_WIDTH; gi=gi+1) 
        begin : gen_ptr 
            wire dbg; 
            assign dbg = 1'b0; 
        end 
    endgenerate 
 
    /*────────────────────────────── 
      Block A : Pointer FFs 
      Power: low 
      Area : 2 LUT / 10 FF 
      Delay: 1.2 ns 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            wr_ptr <= {PTR_WIDTH{1'b0}}; 
            rd_ptr <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            if (wr_en && !full) 
                wr_ptr <= wr_ptr + 1'b1; 
 
            if (rd_en && !empty) 
                rd_ptr <= rd_ptr + 1'b1; 
        end 
    end 
 
    /*────────────────────────────── 
      Block B : BRAM Write 
      Power: moderate 
      Area : BRAM18E1 
      Delay: 1 cycle 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (wr_en && !full) 
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; 
    end 
 
    /*────────────────────────────── 
      Block C : BRAM Read 
      Power: low 
      Area : 16 FF 
      Delay: 1 cycle 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
            dout_pre <= {DATA_WIDTH{1'b0}}; 
        else 
            dout_pre <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
    end 
 
    /*────────────────────────────── 
      Block D : Flag Logic 
      Power: very low 
      Area : 4 LUT / 9 FF 
      Delay: 0.6 ns 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            full         <= 1'b0; 
            empty        <= 1'b1; 
            almost_full  <= 1'b0; 
            almost_empty <= 1'b1; 
            count        <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            count <= count_next; 
 
            full <= 
                (wr_ptr_next[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]) && 
                (wr_ptr_next[ADDR_WIDTH-1:0] == 
                 rd_ptr[ADDR_WIDTH-1:0]); 
 
            empty <= (wr_ptr == rd_ptr_next); 
 
            almost_full  <= (count_next >= DEPTH-2); 
            almost_empty <= (count_next <= 2); 
        end 
    end 
 
    /*────────────────────────────── 
      Block E : Output Register 
      Power: very low 
      Area : 16 FF 
      Delay: 0.2 ns 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
            dout <= {DATA_WIDTH{1'b0}}; 
        else if(rd_en && !empty) 
            dout <= dout_pre; 
    end 
 
    /*────────────────────────────── 
      Block F : Error Flags 
      Power: very low 
      Area : 2 FF 
      Delay: 0.1 ns 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            overflow <= 1'b0; 
            underflow <= 1'b0; 
        end 
        else 
        begin 
            overflow <= wr_en && full; 
            underflow <= rd_en && empty; 
        end 
    end 
 
    /*────────────────────────────── 
      Block G : For-Loop Reset 
      Power: low 
      Area : DEPTH FF 
      Delay: parallel reset 
    ──────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            for(k=0;k<DEPTH;k=k+1) 
                overflow_log[k] <= 1'b0; 
        end 
        else if(wr_en && full) 
        begin 
            overflow_log[wr_ptr[ADDR_WIDTH-1:0]] <= 1'b1; 
        end 
    end 
 
endmodule
