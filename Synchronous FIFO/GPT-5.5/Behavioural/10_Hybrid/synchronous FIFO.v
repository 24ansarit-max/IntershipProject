module fifo16_bram 
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
 
    output reg                   overflow, 
    output reg                   underflow 
); 
 
    // ------------------------------------------------------------ 
    // BRAM storage 
    // ------------------------------------------------------------ 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
 
    // ------------------------------------------------------------ 
    // Internal registers 
    // ------------------------------------------------------------ 
    reg [PTR_WIDTH-1:0] wr_ptr; 
    reg [PTR_WIDTH-1:0] rd_ptr; 
 
    reg [PTR_WIDTH-1:0] count; 
 
    reg [DATA_WIDTH-1:0] bram_q; 
 
    // ------------------------------------------------------------ 
    // Transfer qualifiers 
    // ------------------------------------------------------------ 
    wire wr_fire; 
    wire rd_fire; 
 
    assign wr_fire = wr_en && !full; 
    assign rd_fire = rd_en && !empty; 
 
    // ------------------------------------------------------------ 
    // Next-state look-ahead 
    // ------------------------------------------------------------ 
    wire [PTR_WIDTH-1:0] wr_ptr_next; 
    wire [PTR_WIDTH-1:0] rd_ptr_next; 
    wire [PTR_WIDTH-1:0] count_next; 
 
    assign wr_ptr_next = 
        wr_ptr + (wr_fire ? {{PTR_WIDTH-1{1'b0}},1'b1} 
                           : {PTR_WIDTH{1'b0}}); 
 
    assign rd_ptr_next = 
        rd_ptr + (rd_fire ? {{PTR_WIDTH-1{1'b0}},1'b1} 
                           : {PTR_WIDTH{1'b0}}); 
 
    assign count_next = 
           count 
         + (wr_fire ? {{PTR_WIDTH-1{1'b0}},1'b1} 
                    : {PTR_WIDTH{1'b0}}) 
         - (rd_fire ? {{PTR_WIDTH-1{1'b0}},1'b1} 
                    : {PTR_WIDTH{1'b0}}); 
 
    // ───────────────────────────────────────────── 
    // Block A — Pointer FFs 
    // Power   : CE via wr_fire/rd_fire 
    // Area    : 10 FFs 
    // Delay   : pointer increment path 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            wr_ptr <= {PTR_WIDTH{1'b0}}; 
            rd_ptr <= {PTR_WIDTH{1'b0}}; 
        end 
        else 
        begin 
            if (wr_fire) 
                wr_ptr <= wr_ptr_next; 
 
            if (rd_fire) 
                rd_ptr <= rd_ptr_next; 
        end 
    end 
 
    // ───────────────────────────────────────────── 
    // Block B — BRAM write 
    // Power   : write port gated 
    // Area    : BRAM18E1 
    // Delay   : BRAM write path 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (wr_fire) 
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din; 
    end 
 
    // ───────────────────────────────────────────── 
    // Block C — BRAM read 
    // Power   : active on read 
    // Area    : 16 FFs 
    // Delay   : synchronous BRAM read 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            bram_q <= {DATA_WIDTH{1'b0}}; 
        else if (rd_fire) 
            bram_q <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
    end 
 
    // ───────────────────────────────────────────── 
    // Block D — Flag register 
    // Power   : low toggle rate 
    // Area    : 4 FFs 
    // Delay   : count comparator 
    // Loop    : none 
    // ───────────────────────────────────────────── 
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
            full         <= (count_next == DEPTH); 
            empty        <= (count_next == 0); 
 
            almost_full  <= (count_next >= (DEPTH-1)); 
            almost_empty <= (count_next <= 1); 
        end 
    end 
 
    // ───────────────────────────────────────────── 
    // Block E — Count register 
    // Power   : updates only on transfer 
    // Area    : 5 FFs 
    // Delay   : add/subtract 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            count <= {PTR_WIDTH{1'b0}}; 
        else 
            count <= count_next; 
    end 
 
    // ───────────────────────────────────────────── 
    // Block F — Output register 
    // Power   : CE on successful read 
    // Area    : 16 FFs 
    // Delay   : FF only 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
            dout <= {DATA_WIDTH{1'b0}}; 
        else if (rd_fire) 
            dout <= bram_q; 
    end 
 
    // ───────────────────────────────────────────── 
    // Block G — Error flags 
    // Power   : toggles only on error 
    // Area    : 2 FFs 
    // Delay   : simple logic 
    // Loop    : none 
    // ───────────────────────────────────────────── 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
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
 
endmodule
