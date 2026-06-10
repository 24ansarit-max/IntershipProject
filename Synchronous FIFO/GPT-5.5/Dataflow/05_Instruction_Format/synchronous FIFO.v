`timescale 1ns / 1ps 
/*═══════════════════════════════════════════════════
════════════ 
  16-bit Synchronous FIFO (DATAFLOW STYLE) 
  Target : Nexys A7 (xc7a100tcsg324-2) 
 
  Features: 
  - 16-bit data width 
  - 16-entry depth 
  - 5-bit binary pointers (MSB = wrap bit) 
  - Block RAM inference 
  - Read-first synchronous read 
  - All combinational logic via continuous assign 
  - Registered output flags 
  - Overflow / Underflow detection 
 
  Power : 
    BRAM-based storage with gated enables minimizes switching. 
    Invalid reads/writes are blocked before reaching BRAM. 
 
  Area : 
    ~25-35 LUTs 
    ~30 FFs 
    1 RAMB18E1 
 
  Delay : 
    Pointer -> subtractor -> comparator -> flag FF 
    ~2.0-2.8 ns on Artix-7 xc7a100t-2 
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
 
    output wire                    overflow, 
    output wire                    underflow, 
 
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
      Internal Signals 
    ─────────────────────────────────────────────*/ 
    wire full_c; 
    wire empty_c; 
    wire almost_full_c; 
    wire almost_empty_c; 
 
    wire [ADDR_WIDTH-1:0] wr_addr; 
    wire [ADDR_WIDTH-1:0] rd_addr; 
 
    wire wr_en_safe; 
    wire rd_en_safe; 
 
    /*───────────────────────────────────────────── 
      DATAFLOW LOGIC 
    ─────────────────────────────────────────────*/ 
 
    // Power: Comparator active only when pointers change 
    // Area : ~2 LUTs 
    // Delay: XOR + equality compare 
    assign full_c = 
           (wr_ptr[PTR_WIDTH-1] ^ rd_ptr[PTR_WIDTH-1]) & 
           (wr_ptr[ADDR_WIDTH-1:0] == 
            rd_ptr[ADDR_WIDTH-1:0]); 
 
    // Power: Very low 
    // Area : ~1 LUT 
    // Delay: Equality compare 
    assign empty_c = 
           (wr_ptr == rd_ptr); 
 
    // Power: Moderate (carry chain subtractor) 
    // Area : ~5 LUTs 
    // Delay: 5-bit subtraction 
    assign count = 
           wr_ptr - rd_ptr; 
 
    // Power: Comparator only 
    // Area : ~2 LUTs 
    // Delay: 1-2 levels 
    assign almost_full_c = 
           (count >= (DEPTH-2)); 
 
    // Power: Comparator only 
    // Area : ~2 LUTs 
    // Delay: 1-2 levels 
    assign almost_empty_c = 
           (count <= 2); 
 
    // Area : 0 LUTs 
    // Delay: Routing only 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    // Area : 0 LUTs 
    // Delay: Routing only 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    // Power: Prevents illegal BRAM writes 
    // Area : 1 LUT 
    // Delay: 1 level 
    assign wr_en_safe = 
           wr_en & ~full_c; 
 
    // Power: Prevents illegal BRAM reads 
    // Area : 1 LUT 
    // Delay: 1 level 
    assign rd_en_safe = 
           rd_en & ~empty_c; 
 
    // Power: Event flag only 
    // Area : 1 LUT 
    assign overflow = 
           wr_en & full_c; 
 
    // Power: Event flag only 
    // Area : 1 LUT 
    assign underflow = 
           rd_en & empty_c; 
 
    /*───────────────────────────────────────────── 
      Pointer Registers 
      Sync Active-Low Reset 
    ─────────────────────────────────────────────*/ 
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
 
    /*───────────────────────────────────────────── 
      BRAM Storage 
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
      Registered Output Flags 
      Removes comparator chain from critical path 
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
            full         <= full_c; 
            empty        <= empty_c; 
            almost_full  <= almost_full_c; 
            almost_empty <= almost_empty_c; 
        end 
    end 
 
endmodule
