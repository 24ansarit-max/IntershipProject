`timescale 1ns / 1ps 
/*═══════════════════════════════════════════════════
════════════ 
  16-bit Synchronous FIFO (DATAFLOW STYLE) 
  Target : Nexys A7 (xc7a100tcsg324-2) 
 
  HARD CONSTRAINT COMPLIANCE 
  -------------------------- 
  [DATAFLOW]  All combinational outputs use assign only 
  [TIMING]    Registered full/empty outputs 
  [AREA]      <40 LUTs assign logic, <30 FFs control logic 
  [POWER]     Mandatory BRAM enable gating 
  [BRAM]      Block RAM inference required 
 
  Parameters 
  ---------- 
  DATA_WIDTH = 16 
  DEPTH      = 16 
  ADDR_WIDTH = 4 
  PTR_WIDTH  = 5 
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
      ASSIGN CLUSTER #1 
      Pointer Derived Signals 
    ───────────────────────────────────────────*/ 
 
    assign full_c = 
           (wr_ptr[4] ^ rd_ptr[4]) & 
           (wr_ptr[3:0] == rd_ptr[3:0]); 
 
    assign empty_c = 
           (wr_ptr == rd_ptr); 
 
    assign count = 
           wr_ptr - rd_ptr; 
 
    assign wr_addr = 
           wr_ptr[ADDR_WIDTH-1:0]; 
 
    assign rd_addr = 
           rd_ptr[ADDR_WIDTH-1:0]; 
 
    // Constraint compliance: 
    // [DATAFLOW]✓ [TIMING]✓ [AREA]✓ [POWER]✓ 
    // 
    // Power: 
    //   Comparator activity only when pointers change 
    // 
    // Area: 
    //   ~8 LUTs total 
    // 
    // Delay: 
    //   full_c  : XOR + compare ≈ 2 LUT levels 
    //   empty_c : compare ≈ 1 LUT level 
    //   count   : carry-chain subtractor ≈ 2-3 levels 
    //   ≈ 1.5-2.0 ns 
 
    /*─────────────────────────────────────────── 
      ASSIGN CLUSTER #2 
      Threshold Flags 
    ───────────────────────────────────────────*/ 
 
    assign almost_full_c = 
           (count >= (DEPTH - 2)); 
 
    assign almost_empty_c = 
           (count <= 2); 
 
    assign overflow = 
           wr_en & full_c; 
 
    assign underflow = 
           rd_en & empty_c; 
 
    // Constraint compliance: 
    // [DATAFLOW]✓ [TIMING]✓ [AREA]✓ [POWER]✓ 
    // 
    // Power: 
    //   Low toggle rate, event-driven 
    // 
    // Area: 
    //   ~6 LUTs 
    // 
    // Delay: 
    //   Comparator path ≈ 1-2 LUT levels 
    //   ≈ 0.8-1.2 ns 
 
    /*─────────────────────────────────────────── 
      ASSIGN CLUSTER #3 
      Mandatory BRAM Enable Gating 
    ───────────────────────────────────────────*/ 
 
    assign wr_en_safe = 
           wr_en & ~full_c; 
 
    assign rd_en_safe = 
           rd_en & ~empty_c; 
 
    // Constraint compliance: 
    // [DATAFLOW]✓ [TIMING]✓ [AREA]✓ [POWER]✓ 
    // 
    // Power: 
    //   Primary power-saving mechanism. 
    //   Prevents invalid BRAM accesses. 
    //   Reduces BRAM address/data toggling. 
    // 
    // Area: 
    //   ~2 LUTs 
    // 
    // Delay: 
    //   1 LUT level 
    //   ≈ 0.2-0.3 ns 
 
    /*─────────────────────────────────────────── 
      Pointer FFs 
      Sync Active-Low Reset 
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
      BRAM Storage 
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
      Output Flag Registers 
      Adds 1-Cycle Latency 
      Removes Flags From Critical Path 
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
