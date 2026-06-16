`timescale 1ns / 1ps 
/*═══════════════════════════════════════════════════
════════════ 
  16-bit Synchronous FIFO (DATAFLOW STYLE) 
  Target : Nexys A7 (xc7a100tcsg324-2) 
  Memory : Block RAM Inference 
  Depth  : 16 Entries 
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
 
    output wire [PTR_WIDTH-1:0]    count 
); 
 
    /*───────────────────────────────────────────── 
      Block RAM Storage 
    ─────────────────────────────────────────────*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    /*───────────────────────────────────────────── 
      FIFO Pointers 
    ─────────────────────────────────────────────*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    /*───────────────────────────────────────────── 
      DATAFLOW Signals 
    ─────────────────────────────────────────────*/ 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    wire                  full_next; 
    wire                  empty_next; 
    wire                  almost_full_next; 
    wire                  almost_empty_next; 
 
    wire                  wr_en_safe; 
    wire                  rd_en_safe; 
 
    /*───────────────────────────────────────────── 
      Pure Dataflow Combinational Logic 
    ─────────────────────────────────────────────*/ 
 
    assign full_next = 
           (wr_ptr[PTR_WIDTH-1] ^ rd_ptr[PTR_WIDTH-1]) & 
           (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]); 
 
    assign empty_next = 
           (wr_ptr == rd_ptr); 
 
    assign count = 
           wr_ptr - rd_ptr; 
 
    assign almost_full_next = 
           (count >= (DEPTH-2)); 
 
    assign almost_empty_next = 
           (count <= 2); 
 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    assign wr_en_safe = 
           wr_en & ~full_next; 
 
    assign rd_en_safe = 
           rd_en & ~empty_next; 
 
    /*───────────────────────────────────────────── 
      Write Pointer FF 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            wr_ptr <= {PTR_WIDTH{1'b0}}; 
        else if (wr_en_safe) 
            wr_ptr <= wr_ptr + 1'b1; 
    end 
 
    /*───────────────────────────────────────────── 
      Read Pointer FF 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            rd_ptr <= {PTR_WIDTH{1'b0}}; 
        else if (rd_en_safe) 
            rd_ptr <= rd_ptr + 1'b1; 
    end 
 
    /*───────────────────────────────────────────── 
      BRAM Inference 
      Read-First Mode 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if (wr_en_safe) 
            mem[wr_addr] <= din; 
 
        if (rd_en_safe) 
            dout <= mem[rd_addr]; 
    end 
 
    /*───────────────────────────────────────────── 
      Registered Status Flags 
    ─────────────────────────────────────────────*/ 
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
            full         <= full_next; 
            empty        <= empty_next; 
            almost_full  <= almost_full_next; 
            almost_empty <= almost_empty_next; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      PPA ANNOTATION 
    ─────────────────────────────────────────────*/ 
 
    // Power : 
    //   Pointer increments only on valid accesses. 
    //   Write blocked when full. 
    //   Read blocked when empty. 
    //   BRAM inference minimizes dynamic power versus LUTRAM. 
 
    // Area  : 
    //   ~20-30 LUTs (control logic) 
    //   ~45 FFs 
    //      - wr_ptr  : 5 
    //      - rd_ptr  : 5 
    //      - dout    : 16 
    //      - flags   : 4 
    //      - misc    : synthesis dependent 
    //   1 Block RAM (16 × 16) 
 
    // Delay : 
    //   wr_ptr/rd_ptr 
    //      → comparator 
    //      → count subtractor 
    //      → almost_full/almost_empty logic 
    //      → flag FF 
    //   Critical path ≈ 1.5–2.5 ns on xc7a100t-2 
 
endmodule
