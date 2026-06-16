`timescale 1ns / 1ps 
 
module fifo_16bit 
#( 
    parameter DATA_WIDTH = 16, 
    parameter DEPTH      = 16, 
    parameter ADDR_WIDTH = 4, 
    parameter PTR_WIDTH  = 5 
) 
( 
    input  wire                  clk, 
    input  wire                  rst_n,      // synchronous active-low reset 
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
 
    //========================================================= 
    // Memory Storage (BRAM Inference) 
    //========================================================= 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    //========================================================= 
    // Internal Registers 
    //========================================================= 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    reg [DATA_WIDTH-1:0] dout_pre; 
 
    reg overflow_log [0:DEPTH-1]; 
 
    integer k; 
 
    //========================================================= 
    // Loop H — Generate For 
    // Parameterized replication hook 
    // Cost: 0 LUTs / 0 FFs 
    //========================================================= 
    genvar gi; 
    generate 
        for (gi = 0; gi < PTR_WIDTH; gi = gi + 1) 
        begin : gen_ptr_probe 
            wire dbg_probe; 
            assign dbg_probe = 1'b0; 
        end 
    endgenerate 
 
    //========================================================= 
    // Block A — Pointer FFs 
    // Power : Low (CE controlled) 
    // Area  : ~10 FFs 
    // Delay : ~1.2 ns 
    //========================================================= 
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
 
    //========================================================= 
    // Block B — BRAM Write Port 
    // Power : Moderate (gated write) 
    // Area  : BRAM18E1 
    // Delay : 1 cycle 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            // Intentionally empty 
            // Do NOT reset BRAM contents 
        end 
        else 
        begin 
            if (wr_en && !full) 
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; 
        end 
    end 
 
    //========================================================= 
    // Block C — BRAM Read Port (Read-First) 
    // Power : Low 
    // Area  : DATA_WIDTH FFs 
    // Delay : 1 cycle 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            dout_pre <= {DATA_WIDTH{1'b0}}; 
        else 
            dout_pre <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
    end 
 
    //========================================================= 
    // Block D — Flag Register 
    // Power : Very Low 
    // Area  : ~4 FFs 
    // Delay : ~0.5 ns 
    //========================================================= 
    always @(posedge clk) 
    begin : FLAG_REG 
 
        reg [PTR_WIDTH-1:0] wr_ptr_next; 
        reg [PTR_WIDTH-1:0] rd_ptr_next; 
        reg [PTR_WIDTH-1:0] count_next; 
 
        if (!rst_n) 
        begin 
            full         <= 1'b0; 
            empty        <= 1'b1; 
            almost_full  <= 1'b0; 
            almost_empty <= 1'b1; 
        end 
        else 
        begin 
            wr_ptr_next = 
                wr_ptr + 
                ((wr_en && !full) ? 1'b1 : 1'b0); 
 
            rd_ptr_next = 
                rd_ptr + 
                ((rd_en && !empty) ? 1'b1 : 1'b0); 
 
            count_next = 
                wr_ptr_next - rd_ptr_next; 
 
            full <= 
                (wr_ptr_next[PTR_WIDTH-1] != 
                 rd_ptr_next[PTR_WIDTH-1]) && 
                (wr_ptr_next[ADDR_WIDTH-1:0] == 
                 rd_ptr_next[ADDR_WIDTH-1:0]); 
 
            empty <= 
                (wr_ptr_next == rd_ptr_next); 
 
            almost_full <= 
                (count_next >= (DEPTH - 2)); 
 
            almost_empty <= 
                (count_next <= 2); 
        end 
    end 
 
    //========================================================= 
    // Block E — Count Register 
    // Power : Low 
    // Area  : 5 FFs 
    // Delay : ~0.3 ns 
    //========================================================= 
    always @(posedge clk) 
    begin : COUNT_REG 
 
        reg [PTR_WIDTH-1:0] wr_ptr_next; 
        reg [PTR_WIDTH-1:0] rd_ptr_next; 
 
        if (!rst_n) 
        begin 
            count <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            wr_ptr_next = 
                wr_ptr + 
                ((wr_en && !full) ? 1'b1 : 1'b0); 
 
            rd_ptr_next = 
                rd_ptr + 
                ((rd_en && !empty) ? 1'b1 : 1'b0); 
 
            count <= wr_ptr_next - rd_ptr_next; 
        end 
    end 
 
    //========================================================= 
    // Block F — Output Register 
    // Power : Very Low 
    // Area  : DATA_WIDTH FFs 
    // Delay : 1 cycle 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            dout     <= {DATA_WIDTH{1'b0}}; 
            rd_valid <= 1'b0; 
        end 
        else 
        begin 
            rd_valid <= (rd_en && !empty); 
 
            if (rd_en && !empty) 
                dout <= dout_pre; 
        end 
    end 
 
    //========================================================= 
    // Block G — Error Flags + Handshake 
    // Power : Very Low 
    // Area  : 4 FFs 
    // Delay : ~0.1 ns 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            overflow <= 1'b0; 
            underflow <= 1'b0; 
            wr_ack <= 1'b0; 
        end 
        else 
        begin 
            overflow <= (wr_en && full); 
            underflow <= (rd_en && empty); 
            wr_ack <= (wr_en && !full); 
        end 
    end 
 
    //========================================================= 
    // Loop I — For Inside Always 
    // Array reset only 
    // Synthesis unrolls into parallel reset enables 
    //========================================================= 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            for (k = 0; k < DEPTH; k = k + 1) 
                overflow_log[k] <= 1'b0; 
        end 
        else 
        begin 
            if (wr_en && full) 
                overflow_log[wr_ptr[ADDR_WIDTH-1:0]] <= 1'b1; 
        end 
    end 
 
endmodule
