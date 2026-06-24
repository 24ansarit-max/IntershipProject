module barrel_shifter_16 ( 
    input  [15:0] data_in, 
    input  [3:0]  shift, 
    output reg [15:0] data_out 
); 
 
always @(*) begin 
    case (shift) 
 
        4'd0  : data_out = data_in; 
        4'd1  : data_out = {data_in[14:0], 1'b0}; 
        4'd2  : data_out = {data_in[13:0], 2'b00}; 
        4'd3  : data_out = {data_in[12:0], 3'b000}; 

        4'd4  : data_out = {data_in[11:0], 4'b0000}; 
        4'd5  : data_out = {data_in[10:0], 5'b00000}; 
        4'd6  : data_out = {data_in[9:0],  6'b000000}; 
        4'd7  : data_out = {data_in[8:0],  7'b0000000}; 
        4'd8  : data_out = {data_in[7:0],  8'b00000000}; 
        4'd9  : data_out = {data_in[6:0],  9'b000000000}; 
        4'd10 : data_out = {data_in[5:0], 10'b0000000000}; 
        4'd11 : data_out = {data_in[4:0], 11'b00000000000}; 
        4'd12 : data_out = {data_in[3:0], 12'b000000000000}; 
        4'd13 : data_out = {data_in[2:0], 13'b0000000000000}; 
        4'd14 : data_out = {data_in[1:0], 14'b00000000000000}; 
        4'd15 : data_out = {data_in[0],   15'b000000000000000}; 
 
    endcase 
end 
 
endmodule