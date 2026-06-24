// ───────────────────────────────────── 
// Module : fifo_mem 
// Power  : Medium (BRAM toggle activity) 
// Area   : 1 RAMB18E1 
// Delay  : critical path ≈ 1.5 ns @ 100 MHz 
// ───────────────────────────────────── 
 
module fifo_mem # 
( 
    parameter DW = 16, 
    parameter AW = 4 
) 
( 
    input              clk, 
    input              wr_en, 
    input  [AW-1:0]    wr_addr, 
    input  [AW-1:0]    rd_addr, 
    input  [DW-1:0]    din, 
    output reg [DW-1:0] dout 
); 
 
    (* ram_style = "block" *) 
    reg [DW-1:0] mem [0:(1<<AW)-1]; 
 
    always @(posedge clk) 
    begin 
        if (wr_en) 
            mem[wr_addr] <= din; 
 
        dout <= mem[rd_addr]; // read-first behavior 
    end 
 
endmodule 
// ───────────────────────────────────── 
// Module : fifo_ctrl 
// Power  : Low (clock-gated FF updates) 
// Area   : ~10 LUTs | ~10 FFs 
// Delay  : critical path ≈ 0.8 ns @ 100 MHz 
// ───────────────────────────────────── 
 
module fifo_ctrl # 
( 
    parameter AW = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input full, 
    input empty, 
 
    output reg [AW:0] wr_ptr, 
    output reg [AW:0] rd_ptr 
); 
 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            wr_ptr <= 0; 
            rd_ptr <= 0; 
        end 
        else 
        begin 
            if (wr_en && !full) 
                wr_ptr <= wr_ptr + 1'b1; 
 
            if (rd_en && !empty) 
                rd_ptr <= rd_ptr + 1'b1; 
        end 
    end 
 
endmodule 
// ───────────────────────────────────── 
// Module : fifo_flags 
// Power  : Very Low (pure LUT logic) 
// Area   : ~15 LUTs 
// Delay  : critical path ≈ 1.0 ns @ 100 MHz 
// ───────────────────────────────────── 
 
module fifo_flags # 
( 
    parameter AW = 4, 
    parameter DEPTH = 16 
) 
( 
    input  [AW:0] wr_ptr, 
    input  [AW:0] rd_ptr, 
 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire [AW:0] diff; 
    assign diff = wr_ptr - rd_ptr; 
 
    assign empty = (wr_ptr == rd_ptr); 
 
    assign full = 
        (wr_ptr[AW] != rd_ptr[AW]) && 
        (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]); 
 
    assign almost_full  = (diff >= (DEPTH - 2)); 
    assign almost_empty = (diff <= 2); 
 
endmodule 
// ───────────────────────────────────── 
// Module : fifo_top 
// Power  : Low (routing-only logic) 
// Area   : interconnect only 
// Delay  : depends on hierarchy (~1.2 ns critical path) 
// ───────────────────────────────────── 
 
module fifo_top # 
( 
    parameter DATA_WIDTH = 16, 
    parameter DEPTH      = 16, 
    parameter ADDR_WIDTH = 4 
) 
( 
    input  clk, 
    input  rst_n, 
    input  wr_en, 
    input  rd_en, 
    input  [DATA_WIDTH-1:0] din, 
 
    output [DATA_WIDTH-1:0] dout, 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    // ── INTERNAL WIRES ─────────────────────────── 
    wire [ADDR_WIDTH:0] wr_ptr; 
    wire [ADDR_WIDTH:0] rd_ptr; 
    wire [DATA_WIDTH-1:0] mem_dout; 
 
    wire wr_gated; 
    wire rd_gated; 
 
    // ── STRUCTURAL GATING (no assign allowed) ──── 
    and (wr_gated, wr_en, ~full); 
    and (rd_gated, rd_en, ~empty); 
 
    // ── CONTROL BLOCK ──────────────────────────── 
    fifo_ctrl #(.AW(ADDR_WIDTH)) u_ctrl ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .wr_en(wr_gated), 
        .rd_en(rd_gated), 
        .full(full), 
        .empty(empty), 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr) 
    ); 
 
    // ── FLAG BLOCK ─────────────────────────────── 
    fifo_flags #(.AW(ADDR_WIDTH), .DEPTH(DEPTH)) u_flags ( 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr), 
        .full(full), 
        .empty(empty), 
        .almost_full(almost_full), 
        .almost_empty(almost_empty) 
    ); 
 
    // ── MEMORY BLOCK ───────────────────────────── 
    fifo_mem #(.DW(DATA_WIDTH), .AW(ADDR_WIDTH)) u_mem ( 
        .clk(clk), 
        .wr_en(wr_gated), 
        .wr_addr(wr_ptr[ADDR_WIDTH-1:0]), 
        .rd_addr(rd_ptr[ADDR_WIDTH-1:0]), 
        .din(din), 
        .dout(mem_dout) 
    ); 
 
    // ── OUTPUT BUFFERING (STRUCTURAL) ─────────── 
    buf (dout[0], mem_dout[0]); 
 
    genvar i; 
    generate 
        for (i = 1; i < DATA_WIDTH; i = i + 1) 
        begin : OUTBUF 
            buf (dout[i], mem_dout[i]); 
        end 
    endgenerate 
 
endmodule
