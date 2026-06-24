`timescale 1ns / 1ps 
/*═══════════════════════════════════════════════════
════════════ 
  16-bit Synchronous FIFO (DATAFLOW STYLE) 
  Target : Nexys A7 (xc7a100tcsg324-2) 
 
  Parameters 
  ---------- 
  DATA_WIDTH = 16 
  DEPTH      = 16 
  ADDR_WIDTH = 4 
  PTR_WIDTH  = 5 
 
  Design Rules 
  ------------ 
  • All combinational logic uses continuous assign 
  • No always @(*) 
  • No always_comb 
  • Only always @(posedge clk) for FFs and BRAM 
  • 5-bit pointers: MSB=wrap bit, [3:0]=BRAM address 
  • Block RAM inference 
  • Read-first synchronous read 
═════════════════════════════════════════════════════
══════════*/ 
 
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
 
    output wire [PTR_WIDTH-1:0]    count, 
 
    output wire                    wr_en_safe, 
    output wire                    rd_en_safe, 
 
    output wire                    overflow, 
    output wire                    underflow 
); 
 
    /*─────────────────────────────────────────── 
      Block RAM Storage 
    ───────────────────────────────────────────*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    /*─────────────────────────────────────────── 
      Pointer Registers 
    ───────────────────────────────────────────*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    /*─────────────────────────────────────────── 
      Internal Combinational Signals 
    ───────────────────────────────────────────*/ 
    wire full_c; 
    wire empty_c; 
    wire almost_full_c; 
    wire almost_empty_c; 
 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    /*─────────────────────────────────────────── 
      Pointer address extractions 
 
      Power : negligible 
      Area  : 0 LUTs 
      Delay : routing only 
    ───────────────────────────────────────────*/ 
    assign wr_addr = wr_ptr[ADDR_WIDTH-1:0]; 
    assign rd_addr = rd_ptr[ADDR_WIDTH-1:0]; 
 
    /*─────────────────────────────────────────── 
      Full / empty detection 
 
      Power : low 
      Area  : ~3 LUTs 
      Delay : ~2 LUT levels 
    ───────────────────────────────────────────*/ 
    assign full_c = 
           (wr_ptr[PTR_WIDTH-1] ^ rd_ptr[PTR_WIDTH-1]) & 
           (wr_ptr[ADDR_WIDTH-1:0] == 
            rd_ptr[ADDR_WIDTH-1:0]); 
 
    assign empty_c = 
           (wr_ptr == rd_ptr); 
 
    /*─────────────────────────────────────────── 
      Occupancy count 
 
      Power : moderate 
      Area  : ~4 LUTs 
      Delay : carry-chain subtractor 
    ───────────────────────────────────────────*/ 
    assign count = 
           wr_ptr[ADDR_WIDTH-1:0] - 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    /*─────────────────────────────────────────── 
      Threshold flags 
 
      Power : low 
      Area  : ~4 LUTs 
      Delay : 1-2 LUT levels 
    ───────────────────────────────────────────*/ 
    assign almost_full_c = 
           (count >= (DEPTH - 2)); 
 
    assign almost_empty_c = 
           (count <= 2); 
 
    /*─────────────────────────────────────────── 
      Gated enables (power optimization) 
 
      Power : 
        Prevents invalid BRAM accesses 
        Reduces switching activity 
 
      Area  : ~2 LUTs 
      Delay : 1 LUT level 
    ───────────────────────────────────────────*/ 
    assign wr_en_safe = 
           wr_en & ~full_c; 
 
    assign rd_en_safe = 
           rd_en & ~empty_c; 
 
    /*─────────────────────────────────────────── 
      Error / status flags 
 
      Power : event driven 
      Area  : ~2 LUTs 
      Delay : 1 LUT level 
    ───────────────────────────────────────────*/ 
    assign overflow = 
           wr_en & full_c; 
 
    assign underflow = 
           rd_en & empty_c; 
 
    /*─────────────────────────────────────────── 
      Pointer Registers 
      Synchronous Active-Low Reset 
    ───────────────────────────────────────────*/ 
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
 
    /*─────────────────────────────────────────── 
      Block RAM 
      Read-First Mode 
      No Reset On Memory Contents 
    ───────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (wr_en_safe) 
            mem[wr_addr] <= din; 
 
        if (rd_en_safe) 
            dout <= mem[rd_addr]; 
    end 
 
    /*─────────────────────────────────────────── 
      Registered Output Flags 
      Adds 1-cycle latency 
      Improves timing closure 
    ───────────────────────────────────────────*/ 
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
