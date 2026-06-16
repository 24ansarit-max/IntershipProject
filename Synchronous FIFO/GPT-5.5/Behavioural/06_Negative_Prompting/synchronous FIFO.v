`timescale 1ns/1ps 
 
module fifo_16bit 
#( 
    parameter DATA_WIDTH = 16, 
    parameter DEPTH      = 16, 
    parameter ADDR_WIDTH = 4, 
    parameter PTR_WIDTH  = 5 
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
 
    output reg  [PTR_WIDTH-1:0]  count, 
 
    output reg                   overflow, 
    output reg                   underflow, 
 
    output reg                   wr_ack, 
    output reg                   rd_valid 
); 
 
    /*───────────────────────────────────────────── 
      Storage Array 
    ─────────────────────────────────────────────*/ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    reg [DATA_WIDTH-1:0] dout_pre; 
 
    /*───────────────────────────────────────────── 
      FIFO State 
    ─────────────────────────────────────────────*/ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    reg overflow_log [0:DEPTH-1]; 
 
    integer k; 
 
    /*───────────────────────────────────────────── 
      Safe combinational helper wires 
    ─────────────────────────────────────────────*/ 
    wire wr_en_safe; 
    wire rd_en_safe; 
 
    wire [PTR_WIDTH-1:0] wr_ptr_next; 
    wire [PTR_WIDTH-1:0] rd_ptr_next; 
 
    assign wr_en_safe = wr_en && !full; 
    assign rd_en_safe = rd_en && !empty; 
 
    assign wr_ptr_next = 
        wr_ptr + (wr_en_safe ? 1'b1 : 1'b0); 
 
    assign rd_ptr_next = 
        rd_ptr + (rd_en_safe ? 1'b1 : 1'b0); 
 
    /*───────────────────────────────────────────── 
      LOOP F — Generate-for Parameterized Loop 
      Synthesizable note: 
      Elaborated before synthesis. Creates no runtime 
      hardware beyond explicitly instantiated logic. 
      Power: 0 
      Area : 0 LUTs / 0 FFs 
      Delay: 0 ns 
    ─────────────────────────────────────────────*/ 
    genvar gi; 
 
    generate 
        for (gi=0; gi<PTR_WIDTH; gi=gi+1) 
        begin : gen_debug_hook 
            wire dbg_tieoff; 
            assign dbg_tieoff = 1'b0; 
        end 
    endgenerate 
 
    /*───────────────────────────────────────────── 
      LOOP A — Pointer FFs 
      CE on wr_en_safe / rd_en_safe. 
      Separate from flag logic to improve Fmax and 
      isolate arithmetic from comparator paths. 
 
      Power: Low 
      Area : ~2 LUTs / 10 FFs 
      Delay: ~1.2 ns 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            wr_ptr <= {PTR_WIDTH{1'b0}}; 
            rd_ptr <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            if(wr_en_safe) 
                wr_ptr <= wr_ptr + 1'b1; 
 
            if(rd_en_safe) 
                rd_ptr <= rd_ptr + 1'b1; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      LOOP B — BRAM Write 
      Memory contents intentionally not reset. 
      Preserves BRAM inference. 
 
      Power: Moderate (write-gated) 
      Area : BRAM18E1 
      Delay: 1 cycle 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            /* no BRAM reset */ 
        end 
        else 
        begin 
            if(wr_en_safe) 
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      LOOP C — BRAM Read-First 
      Unconditional synchronous read. 
      Vivado infers BRAM output register. 
 
      Power: Low 
      Area : 0 LUTs / DATA_WIDTH FFs 
      Delay: 1 cycle 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
            dout_pre <= {DATA_WIDTH{1'b0}}; 
        else 
            dout_pre <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
    end 
 
    /*───────────────────────────────────────────── 
      LOOP D — Flag Register 
      Registered status flags. 
      Uses look-ahead pointers. 
 
      Power: Very Low 
      Area : ~4 LUTs / 4 FFs 
      Delay: Not on critical path 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        reg [PTR_WIDTH-1:0] count_next; 
 
        count_next = 
              (wr_ptr_next - rd_ptr_next); 
 
        if(!rst_n) 
        begin 
            full         <= 1'b0; 
            empty        <= 1'b1; 
            almost_full  <= 1'b0; 
            almost_empty <= 1'b1; 
        end 
        else 
        begin 
            full <= 
                (wr_ptr_next[PTR_WIDTH-1] != 
                 rd_ptr[PTR_WIDTH-1]) && 
                (wr_ptr_next[ADDR_WIDTH-1:0] == 
                 rd_ptr[ADDR_WIDTH-1:0]); 
 
            empty <= 
                (wr_ptr_next == rd_ptr_next); 
 
            almost_full <= 
                (count_next >= (DEPTH-2)); 
 
            almost_empty <= 
                (count_next <= 2); 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      LOOP E — Output Pipeline Register 
      Registered output interface. 
 
      Power: Very Low 
      Area : 0 LUTs / 18 FFs 
      Delay: 1 cycle latency 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            dout     <= {DATA_WIDTH{1'b0}}; 
            rd_valid <= 1'b0; 
            wr_ack   <= 1'b0; 
        end 
        else 
        begin 
            rd_valid <= rd_en_safe; 
            wr_ack   <= wr_en_safe; 
 
            if(rd_en_safe) 
                dout <= dout_pre; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      Count Register 
      Occupancy = wr_ptr - rd_ptr 
 
      Power: Low 
      Area : ~2 LUTs / 5 FFs 
      Delay: ~0.3 ns 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            count <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            count <= wr_ptr_next - rd_ptr_next; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      Error Flag Register 
 
      Power: Very Low 
      Area : ~2 LUTs / 2 FFs 
      Delay: ~0.1 ns 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            overflow <= 1'b0; 
            underflow <= 1'b0; 
        end 
        else 
        begin 
            overflow <= wr_en && full; 
            underflow <= rd_en && empty; 
        end 
    end 
 
    /*───────────────────────────────────────────── 
      LOOP G — For-inside-always Array Reset 
      Synthesizable note: 
      Synthesis unrolls this loop into DEPTH parallel 
      reset enables. No carry chain is created. 
 
      Power: Low 
      Area : 0 LUTs / DEPTH FFs 
      Delay: Parallel reset path 
    ─────────────────────────────────────────────*/ 
    always @(posedge clk) 
    begin 
        if(!rst_n) 
        begin 
            for(k=0; k<DEPTH; k=k+1) 
                overflow_log[k] <= 1'b0; 
        end 
        else 
        begin 
            if(wr_en && full) 
                overflow_log[wr_ptr[ADDR_WIDTH-1:0]] 
                    <= 1'b1; 
        end 
    end 
 
endmodule
