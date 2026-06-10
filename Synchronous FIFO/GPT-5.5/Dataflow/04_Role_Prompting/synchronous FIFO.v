`timescale 1ns/1ps 
 
module fifo_16bit 
#( 
    parameter DATA_WIDTH = 16, 
    parameter DEPTH      = 16, 
    parameter ADDR_WIDTH = 4, 
    parameter PTR_WIDTH  = 5 
) 
( 
    input  wire                    clk, 
    input  wire                    rst_n, 
 
    input  wire                    wr_en, 
    input  wire                    rd_en, 
 
    input  wire [DATA_WIDTH-1:0]   din, 
 
    output reg  [DATA_WIDTH-1:0]   dout, 
 
    output reg                     full, 
    output reg                     empty, 
    output reg                     almost_full, 
    output reg                     almost_empty, 
 
    output wire                    overflow, 
    output wire                    underflow, 
 
    output wire [PTR_WIDTH-1:0]    count 
); 
 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    wire full_c; 
    wire empty_c; 
    wire almost_full_c; 
    wire almost_empty_c; 
 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    wire wr_en_safe; 
    wire rd_en_safe; 
 
    /*───────────────────────────────── 
      Dataflow Logic 
    ─────────────────────────────────*/ 
 
    assign full_c = 
           (wr_ptr[PTR_WIDTH-1] ^ rd_ptr[PTR_WIDTH-1]) & 
           (wr_ptr[ADDR_WIDTH-1:0] == 
            rd_ptr[ADDR_WIDTH-1:0]); 
 
    assign empty_c = 
           (wr_ptr == rd_ptr); 
 
    assign count = 
           wr_ptr - rd_ptr; 
 
    assign almost_full_c = 
           (count >= (DEPTH-2)); 
 
    assign almost_empty_c = 
           (count <= 2); 
 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    assign wr_en_safe = 
           wr_en & ~full_c; 
 
    assign rd_en_safe = 
           rd_en & ~empty_c; 
 
    assign overflow = 
           wr_en & full_c; 
 
    assign underflow = 
           rd_en & empty_c; 
 
    /*───────────────────────────────── 
      Pointer FFs 
    ─────────────────────────────────*/ 
 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            wr_ptr <= {PTR_WIDTH{1'b0}}; 
            rd_ptr <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            if (wr_en_safe) 
                wr_ptr <= wr_ptr + 1'b1; 
 
            if (rd_en_safe) 
                rd_ptr <= rd_ptr + 1'b1; 
        end 
    end 
 
    /*───────────────────────────────── 
      BRAM 
      Read-First 
    ─────────────────────────────────*/ 
 
    always @(posedge clk) 
    begin 
        if (wr_en_safe) 
            mem[wr_addr] <= din; 
 
        if (rd_en_safe) 
            dout <= mem[rd_addr]; 
    end 
 
    /*───────────────────────────────── 
      Registered Output Flags 
    ─────────────────────────────────*/ 
 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            full         <= 1'b0; 
            empty        <= 1'b1; 
            almost_full  <= 1'b0; 
            almost_empty <= 1'b1; 
        end 
        else 
        begin 
            full         <= full_c; 
            empty        <= empty_c; 
            almost_full  <= almost_full_c; 
            almost_empty <= almost_empty_c; 
        end 
    end 
 
endmodule
