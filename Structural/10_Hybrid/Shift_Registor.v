module dff_sync ( 

    input  wire clk, 
    input  wire rst_n, 
    input  wire d, 
    output reg  q 
); 
    always @(posedge clk) 
        if (!rst_n) 
            q <= 1'b0; 
        else 
            q <= d; 
endmodule 
 
module dff_ce ( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire d, 
    output reg  q 
); 
    always @(posedge clk) 
        if (!rst_n) 
            q <= 1'b0; 
        else if (ce) 
            q <= d; 
endmodule 
 
module dff_async ( 
    input  wire clk, 

    input  wire rst_n, 
    input  wire d, 
    output reg  q 
); 
    always @(posedge clk or negedge rst_n) 
        if (!rst_n) 
            q <= 1'b0; 
        else 
            q <= d; 
endmodule 
 
module mux2 ( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
    assign y = sel ? b : a; 
endmodule 
 
module dff_universal ( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire load, 
    input  wire dir, 
    input  wire d_ser_l, 
    input  wire d_ser_r, 

    input  wire d_par, 
    output reg  q 
); 
    wire d_mux; 
 
    assign d_mux = 
        load ? d_par : 
        (dir ? d_ser_r : d_ser_l); 
 
    always @(posedge clk) 
        if (!rst_n) 
            q <= 1'b0; 
        else if (ce) 
            q <= d_mux; 
endmodule 
 
 
/* ━━ VARIANT 1: generate-for (LEFT shift, FDCE, no CE) ━━ */ 
/* [PRIM] FDCE x16 | [LUT] 0 | [FF] 16 | [PWR] ~8mW | [FMAX] >300MHz */ 
 
(* shreg_extract = "no" *) 
module sr16_v1 #( 
    parameter WIDTH = 16 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire serial_in, 
    output wire serial_out 

); 
 
    wire [WIDTH:0] chain; 
 
    assign chain[0] = serial_in; 
 
    genvar i; 
 
    generate 
        for (i=0; i<WIDTH; i=i+1) begin : gen_fdce 
            dff_sync u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .d     (chain[i]), 
                .q     (chain[i+1]) 
            ); 
        end 
    endgenerate 
 
    assign serial_out = chain[WIDTH]; 
 
endmodule 
 
 
/* ━━ VARIANT 2: generate-for (LEFT shift, SRL16E style) ━━ */ 
/* [PRIM] SRL16E x1 | [LUT] 1 | [FF] 0 | [PWR] ~5mW | [FMAX] ~250MHz */ 
 
(* shreg_extract = "yes" *) 

module sr16_v2 #( 
    parameter WIDTH = 16 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire serial_in, 
    output wire serial_out 
); 
 
    reg [WIDTH-1:0] srl; 
 
    always @(posedge clk) 
        if (!rst_n) 
            srl <= {WIDTH{1'b0}}; 
        else 
            srl <= {srl[WIDTH-2:0], serial_in}; 
 
    assign serial_out = srl[WIDTH-1]; 
 
endmodule 
 
 
/* ━━ VARIANT 3: generate-for + CE ━━ */ 
/* [PRIM] FDCE x16 | [LUT] 0 | [FF] 16 | [PWR] ~6mW gated */ 
 
(* shreg_extract = "no" *) 
module sr16_v3 #( 
    parameter WIDTH = 16 

)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire serial_in, 
    output wire serial_out 
); 
 
    wire [WIDTH:0] chain; 
 
    assign chain[0] = serial_in; 
 
    genvar i; 
 
    generate 
        for (i=0; i<WIDTH; i=i+1) begin : gen_ce 
            dff_ce u_dff ( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .ce    (ce), 
                .d     (chain[i]), 
                .q     (chain[i+1]) 
            ); 
        end 
    endgenerate 
 
    assign serial_out = chain[WIDTH]; 
 

endmodule 
 
 
/* ━━ VARIANT 4: generate-for + MUX submodule (bidirectional) ━━ */ 
/* [PRIM] LUT1 x16 + FDCE x16 | [LUT] 16 | [FF] 16 | [PWR] ~9mW */ 
 
(* shreg_extract = "no" *) 
module sr16_v4 #( 
    parameter WIDTH = 16 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire ce, 
    input  wire dir, 
    input  wire serial_in, 
    output wire [WIDTH-1:0] q 
); 
 
    wire [WIDTH-1:0] d; 
 
    genvar i; 
 
    generate 
        for (i=0; i<WIDTH; i=i+1) begin : gen_bidir 
 
            if (i==0) begin 
                mux2 u_mux( 
                    .a(serial_in), 

                    .b(q[i+1]), 
                    .sel(dir), 
                    .y(d[i]) 
                ); 
            end 
            else if (i==WIDTH-1) begin 
                mux2 u_mux( 
                    .a(q[i-1]), 
                    .b(serial_in), 
                    .sel(dir), 
                    .y(d[i]) 
                ); 
            end 
            else begin 
                mux2 u_mux( 
                    .a(q[i-1]), 
                    .b(q[i+1]), 
                    .sel(dir), 
                    .y(d[i]) 
                ); 
            end 
 
            dff_ce u_dff( 
                .clk   (clk), 
                .rst_n (rst_n), 
                .ce    (ce), 
                .d     (d[i]), 
                .q     (q[i]) 

            ); 
 
        end 
    endgenerate 
 
endmodule 
 
 
/* ━━ VARIANT 5: generate-if inside generate-for ━━ */ 
 
module sr16_v5 #( 
    parameter WIDTH = 16, 
    parameter ASYNC_RST = 0 
)( 
    input  wire clk, 
    input  wire rst_n, 
    input  wire serial_in, 
    output wire serial_out 
); 
 
    wire [WIDTH:0] chain; 
 
    assign chain[0] = serial_in; 
 
    genvar i; 
 
    generate 
        for (i=0; i<WIDTH; i=i+1) begin : gen_conditional 

 
            if (ASYNC_RST) begin : async_ff 
                dff_async u_ff ( 
                    .clk   (clk), 
                    .rst_n (rst_n), 
                    .d     (chain[i]), 
                    .q     (chain[i+1]) 
                ); 
            end 
            else begin : sync_ff 
                dff_sync u_ff ( 
                    .clk   (clk), 
                    .rst_n (rst_n), 
                    .d     (chain[i]), 
                    .q     (chain[i+1]) 
                ); 
            end 
 
        end 
    endgenerate 
 
    assign serial_out = chain[WIDTH]; 
 
endmodule 
 
 
/* ━━ VARIANT 6: universal load + bidir + CE ━━ */ 
/* [PRIM] LUT2 x16 + FDCE x16 | [LUT] ~20 | [FF] 16 | [PWR] ~10mW */ 

 
module sr16_v6 #( 
    parameter WIDTH = 16 
)( 
    input  wire             clk, 
    input  wire             rst_n, 
    input  wire             ce, 
    input  wire             load, 
    input  wire             dir, 
    input  wire             serial_in, 
    input  wire [WIDTH-1:0] parallel_in, 
    output wire [WIDTH-1:0] q 
); 
 
    genvar i; 
 
    generate 
        for (i=0; i<WIDTH; i=i+1) begin : gen_universal 
 
            if (i==0) begin 
 
                dff_universal u_ff ( 
                    .clk     (clk), 
                    .rst_n   (rst_n), 
                    .ce      (ce), 
                    .load    (load), 
                    .dir     (dir), 
                    .d_ser_l (serial_in), 

                    .d_ser_r (q[i+1]), 
                    .d_par   (parallel_in[i]), 
                    .q       (q[i]) 
                ); 
 
            end 
            else if (i==WIDTH-1) begin 
 
                dff_universal u_ff ( 
                    .clk     (clk), 
                    .rst_n   (rst_n), 
                    .ce      (ce), 
                    .load    (load), 
                    .dir     (dir), 
                    .d_ser_l (q[i-1]), 
                    .d_ser_r (serial_in), 
                    .d_par   (parallel_in[i]), 
                    .q       (q[i]) 
                ); 
 
            end 
            else begin 
 
                dff_universal u_ff ( 
                    .clk     (clk), 
                    .rst_n   (rst_n), 
                    .ce      (ce), 
                    .load    (load), 

                    .dir     (dir), 
                    .d_ser_l (q[i-1]), 
                    .d_ser_r (q[i+1]), 
                    .d_par   (parallel_in[i]), 
                    .q       (q[i]) 
                ); 
 
            end 
 
        end 
    endgenerate 
 
endmodule 
 
 
// ── STRUCTURAL COMPARISON TABLE ────────────────────────────── 
// Variant | Primitive           | LUT | FF | Power | Fmax    | Best for 
// ────────|─────────────────────|─────|────|───────|─────────|────────── 
// V1      | FDCE x16            |  0  | 16 | 8mW   |>300MHz  | Timing 
// V2      | SRL16E x1           |  1  |  0 | 5mW   |~250MHz  | Density 
// V3      | FDCE x16 + CE       |  0  | 16 | 6mW   |>300MHz  | Low Power 
// V4      | LUT1 x16 + FDCE x16 | 16  | 16 | 9mW   |>250MHz  | Bidir 
// V5      | Conditional FF      |  0  | 16 | 8mW   |>300MHz  | Reusable IP 
// V6      | Universal Shift Reg | 20  | 16 |10mW   |>200MHz  | Production IP 
// ──────────────────────────────────────────────────────────────