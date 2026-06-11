module mux2 ( 
    input  wire a, 
    input  wire b, 
    input  wire sel, 
    output wire y 
); 
    assign y = sel ? b : a; 
endmodule 
 
module barrel_shifter_16 ( 
    input  wire [15:0] data_in, 
    input  wire [3:0]  shift, 
    output wire [15:0] data_out 

); 
 
    wire [15:0] s0; 
    wire [15:0] s1; 
    wire [15:0] s2; 
 
    // Stage 0 : shift by 1 
    genvar i; 
    generate 
        for(i=0;i<16;i=i+1) begin : STAGE0 
            if(i==0) 
                mux2 m (.a(data_in[i]), .b(1'b0),         .sel(shift[0]), .y(s0[i])); 
            else 
                mux2 m (.a(data_in[i]), .b(data_in[i-1]), .sel(shift[0]), .y(s0[i])); 
        end 
    endgenerate 
 
    // Stage 1 : shift by 2 
    generate 
        for(i=0;i<16;i=i+1) begin : STAGE1 
            if(i<2) 
                mux2 m (.a(s0[i]), .b(1'b0),     .sel(shift[1]), .y(s1[i])); 
            else 
                mux2 m (.a(s0[i]), .b(s0[i-2]),  .sel(shift[1]), .y(s1[i])); 
        end 
    endgenerate 
 
    // Stage 2 : shift by 4 

    generate 
        for(i=0;i<16;i=i+1) begin : STAGE2 
            if(i<4) 
                mux2 m (.a(s1[i]), .b(1'b0),     .sel(shift[2]), .y(s2[i])); 
            else 
                mux2 m (.a(s1[i]), .b(s1[i-4]),  .sel(shift[2]), .y(s2[i])); 
        end 
    endgenerate 
 
    // Stage 3 : shift by 8 
    generate 
        for(i=0;i<16;i=i+1) begin : STAGE3 
            if(i<8) 
                mux2 m (.a(s2[i]), .b(1'b0),     .sel(shift[3]), .y(data_out[i])); 
            else 
                mux2 m (.a(s2[i]), .b(s2[i-8]),  .sel(shift[3]), .y(data_out[i])); 
        end 
    endgenerate 
 
endmodule