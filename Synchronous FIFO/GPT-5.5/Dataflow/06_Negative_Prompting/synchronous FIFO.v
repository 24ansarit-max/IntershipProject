`timescale 1ns / 1ps 
/*═══════════════════════════════════════════════════
════════════ 
  16-bit Synchronous FIFO (DATAFLOW STYLE) 
  Target : Nexys A7 (xc7a100tcsg324-2) 
 
  DATA_WIDTH = 16 
  DEPTH      = 16 
  ADDR_WIDTH = 4 
  PTR_WIDTH  = 5 
 
  All combinational logic uses continuous assign. 
  No always @(*) 
  No always_comb 
  Only sequential always @(posedge clk) 
 
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
 
    output wire                    full, 
    output wire                    empty, 
    output wire                    almost_full, 
    output wire                    almost_empty, 
 
    output wire [ADDR_WIDTH-1:0]   count 
); 
 
    /*─────────────────────────────────────────── 
      Block RAM Storage 
    ───────────────────────────────────────────*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    /*─────────────────────────────────────────── 
      FIFO Pointers 
    ───────────────────────────────────────────*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    /*─────────────────────────────────────────── 
      Internal Signals 
    ───────────────────────────────────────────*/ 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    wire                  wr_en_safe; 
    wire                  rd_en_safe; 
 
    /*─────────────────────────────────────────── 
      ASSIGN CLUSTER #1 
      Pointer Derived Signals 
 
      Power: Low 
      Area : ~6 LUTs 
      Delay: ~1.5 ns (2 logic levels) 
    ───────────────────────────────────────────*/ 
 
    assign full = 
           (wr_ptr[4] ^ rd_ptr[4]) & 
           (wr_ptr[3:0] == rd_ptr[3:0]); 
 
    assign empty = 
           (wr_ptr == rd_ptr); 
 
    assign count = 
           wr_ptr[3:0] - rd_ptr[3:0]; 
 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    /*─────────────────────────────────────────── 
      ASSIGN CLUSTER #2 
      Threshold Flags 
 
      Power: Very Low 
      Area : ~4 LUTs 
      Delay: ~1.0 ns (1-2 logic levels) 
    ───────────────────────────────────────────*/ 
 
    assign almost_full = 
           (count >= (DEPTH - 2)); 
 
    assign almost_empty = 
           (count <= 2); 
 
    /*─────────────────────────────────────────── 
      ASSIGN CLUSTER #3 
      Enable Gating 
 
      Power: 
        Prevents invalid BRAM accesses. 
        Reduces address/data bus switching. 
 
      Area : ~2 LUTs 
      Delay: ~0.3 ns (1 logic level) 
    ───────────────────────────────────────────*/ 
 
    assign wr_en_safe = 
           wr_en & ~full; 
 
    assign rd_en_safe = 
           rd_en & ~empty; 
 
    /*─────────────────────────────────────────── 
      Pointer Registers 
 
      Sync Active-Low Reset 
      CE = wr_en_safe / rd_en_safe 
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
 
      No reset on memory contents 
    ───────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (wr_en_safe) 
            mem[wr_addr] <= din; 
 
        if (rd_en_safe) 
            dout <= mem[rd_addr]; 
    end 
 
endmodule
