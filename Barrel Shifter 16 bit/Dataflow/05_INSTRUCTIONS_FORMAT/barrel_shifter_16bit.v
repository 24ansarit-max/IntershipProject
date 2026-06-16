module barrel_shifter_16 ( 
    input  [15:0] data_in, 
    input  [3:0]  shamt, 
    output [15:0] data_out 
); 
 
    // Intermediate stages 
    wire [15:0] s0; 
    wire [15:0] s1; 
    wire [15:0] s2; 
    wire [15:0] s3; 
 
    // Stage 0: Shift left by 1 bit if shamt[0] = 1 
    assign s0 = shamt[0] ? {data_in[14:0], 1'b0} : data_in; 
 
    // Stage 1: Shift left by 2 bits if shamt[1] = 1 
    assign s1 = shamt[1] ? {s0[13:0], 2'b00} : s0; 
 
    // Stage 2: Shift left by 4 bits if shamt[2] = 1 
    assign s2 = shamt[2] ? {s1[11:0], 4'b0000} : s1; 
 
    // Stage 3: Shift left by 8 bits if shamt[3] = 1 
    assign s3 = shamt[3] ? {s2[7:0], 8'b00000000} : s2; 
 

    // Final output 
    assign data_out = s3; 
 
endmodule