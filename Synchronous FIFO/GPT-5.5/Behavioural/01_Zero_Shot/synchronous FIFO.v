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
    output reg  [PTR_WIDTH-1:0]  count 
); 
 
    /*═══════════════════════════════════════════════ 
      MEMORY ARRAY 
    ═══════════════════════════════════════════════*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    reg [DATA_WIDTH-1:0] dout_pre; 
 
    /*═══════════════════════════════════════════════ 
      POINTERS 
    ═══════════════════════════════════════════════*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    /*═══════════════════════════════════════════════ 
      COUNT ARRAY (required by specification) 
    ═══════════════════════════════════════════════*/ 
    reg count_arr [0:DEPTH-1]; 
 
    integer k; 
 
    /*═══════════════════════════════════════════════ 
      NEXT-STATE WIRES 
    ═══════════════════════════════════════════════*/ 
    wire wr_fire; 
    wire rd_fire; 
 
    assign wr_fire = wr_en && !full; 
    assign rd_fire = rd_en && !empty; 
 
    wire [PTR_WIDTH-1:0] wr_ptr_next; 
    wire [PTR_WIDTH-1:0] rd_ptr_next; 
 
    assign wr_ptr_next = wr_ptr + (wr_fire ? 1'b1 : 1'b0); 
    assign rd_ptr_next = rd_ptr + (rd_fire ? 1'b1 : 1'b0); 
 
    wire [PTR_WIDTH-1:0] count_next; 
 
    assign count_next = 
        count + 
        (wr_fire ? {{(PTR_WIDTH-1){1'b0}},1'b1} : {PTR_WIDTH{1'b0}}) 
        - 
        (rd_fire ? {{(PTR_WIDTH-1){1'b0}},1'b1} : {PTR_WIDTH{1'b0}}); 
 
    wire full_next; 
    wire empty_next; 
 
    assign full_next = 
           (wr_ptr_next[PTR_WIDTH-1] != rd_ptr_next[PTR_WIDTH-1]) 
        && (wr_ptr_next[ADDR_WIDTH-1:0] == 
            rd_ptr_next[ADDR_WIDTH-1:0]); 
 
    assign empty_next = (wr_ptr_next == rd_ptr_next); 
 
    /*═══════════════════════════════════════════════ 
      LOOP F — Generate-for 
      Structural reset hook 
    ═══════════════════════════════════════════════*/ 
    genvar i; 
    generate 
        for (i = 0; i < PTR_WIDTH; i = i + 1) 
        begin : ptr_reset_gen 
            wire ptr_rst_tieoff; 
            assign ptr_rst_tieoff = 1'b0; 
        end 
    endgenerate 
 
    /*═══════════════════════════════════════════════ 
      LOOP A — Pointer FFs 
      Power: Low 
      Area : ~10 FFs 
      Delay: ~0.20 ns 
    ═══════════════════════════════════════════════*/ 
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
 
    /*═══════════════════════════════════════════════ 
      LOOP B — BRAM Write Port 
      Power: Medium 
      Area : BRAM inferred 
      Delay: BRAM write path 
    ═══════════════════════════════════════════════*/ 
    always @(posedge clk) 
    begin 
        if (wr_en && !full) 
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; 
    end 
 
    /*═══════════════════════════════════════════════ 
      LOOP C — BRAM Read Port (Read-First) 
      Power: Medium 
      Area : BRAM inferred 
      Delay: BRAM read path 
    ═══════════════════════════════════════════════*/ 
    always @(posedge clk) 
    begin 
        dout_pre <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
    end 
 
    /*═══════════════════════════════════════════════ 
      LOOP D — Registered Flag Logic 
      Power: Low 
      Area : ~20 FFs + LUTs 
      Delay: ~0.5 ns 
    ═══════════════════════════════════════════════*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
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
 
            full  <= full_next; 
            empty <= empty_next; 
 
            almost_full  <= (count_next >= (DEPTH-1)); 
            almost_empty <= (count_next <= 1); 
        end 
    end 
 
    /*═══════════════════════════════════════════════ 
      LOOP E — Registered Output 
      Power: Low 
      Area : DATA_WIDTH FFs 
      Delay: ~0.2 ns 
    ═══════════════════════════════════════════════*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            dout <= {DATA_WIDTH{1'b0}}; 
        end 
        else if (rd_en && !empty) 
        begin 
            dout <= dout_pre; 
        end 
        else 
        begin 
            dout <= dout; 
        end 
    end 
 
    /*═══════════════════════════════════════════════ 
      LOOP G — For Loop Reset of Count Array 
      Power: Reset only 
      Area : DEPTH FFs 
      Delay: N/A 
    ═══════════════════════════════════════════════*/ 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            for (k = 0; k < DEPTH; k = k + 1) 
                count_arr[k] <= 1'b0; 
        end 
        else 
        begin 
            if (wr_fire) 
                count_arr[wr_ptr[ADDR_WIDTH-1:0]] <= 1'b1; 
 
            if (rd_fire) 
                count_arr[rd_ptr[ADDR_WIDTH-1:0]] <= 1'b0; 
        end 
    end 
 
endmodule
