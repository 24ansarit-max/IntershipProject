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
 
    // ── INTERNAL WIRES ───────────────────────────── 
    wire [ADDR_WIDTH:0] wr_ptr; 
    wire [ADDR_WIDTH:0] rd_ptr; 
    wire mem_wr_en; 
 
    wire [DATA_WIDTH-1:0] mem_dout; 
 
    // ── STRUCTURAL INSTANCES ONLY ────────────────── 
 
    fifo_ctrl #(.AW(ADDR_WIDTH)) u_ctrl ( 
        .clk    (clk), 
        .rst_n  (rst_n), 
        .wr_en  (mem_wr_en), 
        .rd_en  (rd_en), 
        .full   (full), 
        .empty  (empty), 
        .wr_ptr (wr_ptr), 
        .rd_ptr (rd_ptr) 
    ); 
 
    fifo_flags #(.AW(ADDR_WIDTH), .DEPTH(DEPTH)) u_flags ( 
        .wr_ptr        (wr_ptr), 
        .rd_ptr        (rd_ptr), 
        .full          (full), 
        .empty         (empty), 
        .almost_full   (almost_full), 
        .almost_empty  (almost_empty) 
    ); 
 
    fifo_mem #(.DW(DATA_WIDTH), .AW(ADDR_WIDTH)) u_mem ( 
        .clk     (clk), 
        .wr_en   (mem_wr_en), 
        .wr_addr (wr_ptr[ADDR_WIDTH-1:0]), 
        .rd_addr (rd_ptr[ADDR_WIDTH-1:0]), 
        .din     (din), 
        .dout    (mem_dout) 
    ); 
 
    assign dout = mem_dout; 
 
    // write enable gating (still structural allowed if moduleized) 
    wire wr_ok; 
    and (wr_ok, wr_en, ~full); 
    buf (mem_wr_en, wr_ok); 
 
endmodule 
(* ram_style = "block" *) 
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
 
    // Power : Medium (BRAM switching) 
    // Area  : 1× RAMB18 
    // Delay : ~1.5 ns 
 
    reg [DW-1:0] mem [0:(1<<AW)-1]; 
 
    always @(posedge clk) 
    begin 
        if (wr_en) 
            mem[wr_addr] <= din; 
 
        dout <= mem[rd_addr]; 
    end 
 
endmodule 
module fifo_ctrl # 
( 
    parameter AW = 4 
) 
( 
    input  clk, 
    input  rst_n, 
    input  wr_en, 
    input  rd_en, 
    input  full, 
    input  empty, 
 
    output reg [AW:0] wr_ptr, 
    output reg [AW:0] rd_ptr 
); 
 
    // Power : Low 
    // Area  : ~10 FFs 
    // Delay : 0.5–0.8 ns 
 
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
 
    assign diff  = wr_ptr - rd_ptr; 
 
    assign empty = (wr_ptr == rd_ptr); 
 
    assign full = 
        (wr_ptr[AW] != rd_ptr[AW]) && 
        (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]); 
 
    assign almost_full  = (diff >= (DEPTH - 2)); 
    assign almost_empty = (diff <= 2); 
 
endmodule
