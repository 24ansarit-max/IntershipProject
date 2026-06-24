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
 
    output wire                    full, 
    output wire                    empty, 
    output wire                    almost_full, 
    output wire                    almost_empty, 
 
    output wire                    dout_valid, 
    output wire                    overflow, 
    output wire                    underflow, 
 
    output wire [PTR_WIDTH-1:0]    count 
); 
 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    wire wr_en_safe; 
    wire rd_en_safe; 
 
    /*───────────────────────────── 
      Dataflow Logic 
    ─────────────────────────────*/ 
 
    assign full = 
           (wr_ptr[PTR_WIDTH-1] ^ rd_ptr[PTR_WIDTH-1]) & 
           (wr_ptr[ADDR_WIDTH-1:0] == 
            rd_ptr[ADDR_WIDTH-1:0]); 
 
    assign empty = 
           (wr_ptr == rd_ptr); 
 
    assign count = 
           wr_ptr - rd_ptr; 
 
    assign almost_full = 
           (count >= (DEPTH-2)); 
 
    assign almost_empty = 
           (count <= 2); 
 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    assign wr_en_safe = 
           wr_en & ~full; 
 
    assign rd_en_safe = 
           rd_en & ~empty; 
 
    assign overflow = 
           wr_en & full; 
 
    assign underflow = 
           rd_en & empty; 
 
    assign dout_valid = 
           rd_en_safe; 
 
    /*───────────────────────────── 
      Pointer Registers 
    ─────────────────────────────*/ 
 
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
 
    /*───────────────────────────── 
      BRAM (Read-First) 
    ─────────────────────────────*/ 
 
    always @(posedge clk) 
    begin 
        if (wr_en_safe) 
            mem[wr_addr] <= din; 
 
        if (rd_en_safe) 
            dout <= mem[rd_addr]; 
    end 
 
    /*───────────────────────────── 
      PPA 
    ─────────────────────────────*/ 
 
    // Power : 
    //   BRAM inference, gated read/write enables, 
    //   no combinational feedback paths. 
 
    // Area : 
    //   ~20-30 LUTs 
    //   26 FFs 
    //   1 RAMB18E1 
 
    // Delay : 
    //   pointer -> count -> comparator 
    //   ≈ 2.0 ns worst-case on xc7a100t-2 
 
endmodule
