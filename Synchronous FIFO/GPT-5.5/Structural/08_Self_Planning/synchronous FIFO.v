// Power : Medium (BRAM switching) 
// Area  : 1 RAMB18E1 
// Delay : ~1.5 ns 
 
module fifo_mem # 
( 
    parameter DATA_WIDTH = 16, 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input wr_en, 
    input [ADDR_WIDTH-1:0] wr_addr, 
    input [ADDR_WIDTH-1:0] rd_addr, 
    input [DATA_WIDTH-1:0] din, 
    output reg [DATA_WIDTH-1:0] dout 
); 
 
    (* ram_style = "block" *) 
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1]; 
 
    always @(posedge clk) 
    begin 
        if (wr_en) 
            mem[wr_addr] <= din; 
 
        dout <= mem[rd_addr]; 
    end 
 
endmodule 
// Power : Low 
// Area  : ~10 FFs 
// Delay : ~0.8 ns 
 
module fifo_ctrl # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input full, 
    input empty, 
 
    output reg [ADDR_WIDTH:0] wr_ptr, 
    output reg [ADDR_WIDTH:0] rd_ptr 
); 
 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            wr_ptr <= 5'b00000; 
            rd_ptr <= 5'b00000; 
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
// Power : Very Low 
// Area  : ~15 LUTs 
// Delay : ~1.0 ns 
 
module fifo_flags # 
( 
    parameter ADDR_WIDTH = 4 
) 
( 
    input [ADDR_WIDTH:0] wr_ptr, 
    input [ADDR_WIDTH:0] rd_ptr, 
 
    output full, 
    output empty, 
    output almost_full, 
    output almost_empty 
); 
 
    wire [ADDR_WIDTH:0] diff; 
 
    assign diff = wr_ptr - rd_ptr; 
 
    assign empty = (wr_ptr == rd_ptr); 
 
    assign full = 
        (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && 
        (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]); 
 
    assign almost_full  = (diff >= 14); 
    assign almost_empty = (diff <= 2); 
 
endmodule 
// Power : Low 
// Area  : Interconnect + FF outputs 
// Delay : ~1.2 ns 
 
module fifo_top # 
( 
    parameter DATA_WIDTH = 16, 
    parameter ADDR_WIDTH = 4 
) 
( 
    input clk, 
    input rst_n, 
    input wr_en, 
    input rd_en, 
    input [DATA_WIDTH-1:0] din, 
 
    output reg [DATA_WIDTH-1:0] dout, 
    output reg full, 
    output reg empty, 
    output reg almost_full, 
    output reg almost_empty 
); 
 
    wire [ADDR_WIDTH:0] wr_ptr; 
    wire [ADDR_WIDTH:0] rd_ptr; 
 
    wire [DATA_WIDTH-1:0] mem_dout; 
 
    wire wr_g; 
    wire rd_g; 
 
    wire full_c; 
    wire empty_c; 
    wire af_c; 
    wire ae_c; 
 
    fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) U_CTRL ( 
        .clk(clk), 
        .rst_n(rst_n), 
        .wr_en(wr_g), 
        .rd_en(rd_g), 
        .full(full_c), 
        .empty(empty_c), 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr) 
    ); 
 
    fifo_flags #(.ADDR_WIDTH(ADDR_WIDTH)) U_FLAGS ( 
        .wr_ptr(wr_ptr), 
        .rd_ptr(rd_ptr), 
        .full(full_c), 
        .empty(empty_c), 
        .almost_full(af_c), 
        .almost_empty(ae_c) 
    ); 
 
    fifo_mem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) U_MEM ( 
        .clk(clk), 
        .wr_en(wr_g), 
        .wr_addr(wr_ptr[3:0]), 
        .rd_addr(rd_ptr[3:0]), 
        .din(din), 
        .dout(mem_dout) 
    ); 
 
    // output register stage (allowed structural FFs here) 
    always @(posedge clk) 
    begin 
        if (!rst_n) 
        begin 
            dout <= 0; 
            full <= 0; 
            empty <= 1; 
            almost_full <= 0; 
            almost_empty <= 1; 
        end 
        else 
        begin 
            dout <= mem_dout; 
            full <= full_c; 
            empty <= empty_c; 
            almost_full <= af_c; 
            almost_empty <= ae_c; 
        end 
    end 
 
endmodule
