module barrel_shifter_16 ( 
    input  wire [15:0] data_in, 
    input  wire [3:0]  shift, 
    output wire [15:0] data_out 
); 
 
wire [15:0] s0; 
wire [15:0] s1; 
wire [15:0] s2; 
wire [15:0] s3; 
 
assign s0 = shift[0] ? {data_in[14:0], 1'b0} : data_in; 
assign s1 = shift[1] ? {s0[13:0], 2'b00} : s0; 
assign s2 = shift[2] ? {s1[11:0], 4'b0000} : s1; 
assign s3 = shift[3] ? {s2[7:0], 8'b00000000} : s2; 
 
assign data_out = s3; 
 
endmodule