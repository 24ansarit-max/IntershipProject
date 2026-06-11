module barrel_shifter_16 ( 
    input  wire [15:0] data_in, 
    input  wire [3:0]  shift, 
    output wire [15:0] data_out 
); 
 
    // Intermediate stage wires 
    wire [15:0] s0; 
    wire [15:0] s1; 
    wire [15:0] s2; 
    wire [15:0] s3; 
 
    // Stage 0: Optional left shift by 1 bit 
    assign s0 = shift[0] ? 
                {data_in[14:0], 1'b0} : 
                data_in; 
 
    // Stage 1: Optional additional left shift by 2 bits 
    assign s1 = shift[1] ? 
                {s0[13:0], 2'b00} : 
                s0; 
 
    // Stage 2: Optional additional left shift by 4 bits 
    assign s2 = shift[2] ? 

                {s1[11:0], 4'b0000} : 
                s1; 
 
    // Stage 3: Optional additional left shift by 8 bits 
    assign s3 = shift[3] ? 
                {s2[7:0], 8'b00000000} : 
                s2; 
 
    // Final output 
    assign data_out = s3; 
 
endmodule