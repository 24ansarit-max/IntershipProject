module barrel_shifter_16 ( 
    input  wire [15:0] data_in, 
    input  wire [3:0]  shift, 
    output reg  [15:0] data_out 
); 
 
always @(*) begin 
    (* parallel_case *) 
    case (shift[3:0]) 
 
        // No shift 

        4'd0  : data_out = data_in; 
 
        // Shift left by 1 
        4'd1  : data_out = {data_in[14:0], 1'b0}; 
 
        // Shift left by 2 
        4'd2  : data_out = {data_in[13:0], 2'b00}; 
 
        // Shift left by 3 
        4'd3  : data_out = {data_in[12:0], 3'b000}; 
 
        // Shift left by 4 
        4'd4  : data_out = {data_in[11:0], 4'b0000}; 
 
        // Shift left by 5 
        4'd5  : data_out = {data_in[10:0], 5'b00000}; 
 
        // Shift left by 6 
        4'd6  : data_out = {data_in[9:0], 6'b000000}; 
 
        // Shift left by 7 
        4'd7  : data_out = {data_in[8:0], 7'b0000000}; 
 
        // Shift left by 8 
        4'd8  : data_out = {data_in[7:0], 8'b00000000}; 
 
        // Shift left by 9 
        4'd9  : data_out = {data_in[6:0], 9'b000000000}; 

 
        // Shift left by 10 
        4'd10 : data_out = {data_in[5:0], 10'b0000000000}; 
 
        // Shift left by 11 
        4'd11 : data_out = {data_in[4:0], 11'b00000000000}; 
 
        // Shift left by 12 
        4'd12 : data_out = {data_in[3:0], 12'b000000000000}; 
 
        // Shift left by 13 
        4'd13 : data_out = {data_in[2:0], 13'b0000000000000}; 
 
        // Shift left by 14 
        4'd14 : data_out = {data_in[1:0], 14'b00000000000000}; 
 
        // Shift left by 15 
        4'd15 : data_out = {data_in[0], 15'b000000000000000}; 
 
        // Prevent latch inference 
        default : data_out = 16'h0000; 
 
    endcase 
end 
 
endmodule