module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output signed [31:0] product 
); 
 
wire signed [31:0] M = {{16{multiplicand[15]}}, multiplicand}; 
 
wire q_m1 = 1'b0; 
 
wire signed [31:0] pp0  = ({multiplier[0],  q_m1}           == 2'b01) ?  (M <<< 0)  : 

                          ({multiplier[0],  q_m1}           == 2'b10) ? -(M <<< 0)  : 32'sd0; 
 
wire signed [31:0] pp1  = ({multiplier[1],  multiplier[0]}  == 2'b01) ?  (M <<< 1)  : 
                          ({multiplier[1],  multiplier[0]}  == 2'b10) ? -(M <<< 1)  : 32'sd0; 
 
wire signed [31:0] pp2  = ({multiplier[2],  multiplier[1]}  == 2'b01) ?  (M <<< 2)  : 
                          ({multiplier[2],  multiplier[1]}  == 2'b10) ? -(M <<< 2)  : 32'sd0; 
 
wire signed [31:0] pp3  = ({multiplier[3],  multiplier[2]}  == 2'b01) ?  (M <<< 3)  : 
                          ({multiplier[3],  multiplier[2]}  == 2'b10) ? -(M <<< 3)  : 32'sd0; 
 
wire signed [31:0] pp4  = ({multiplier[4],  multiplier[3]}  == 2'b01) ?  (M <<< 4)  : 
                          ({multiplier[4],  multiplier[3]}  == 2'b10) ? -(M <<< 4)  : 32'sd0; 
 
wire signed [31:0] pp5  = ({multiplier[5],  multiplier[4]}  == 2'b01) ?  (M <<< 5)  : 
                          ({multiplier[5],  multiplier[4]}  == 2'b10) ? -(M <<< 5)  : 32'sd0; 
 
wire signed [31:0] pp6  = ({multiplier[6],  multiplier[5]}  == 2'b01) ?  (M <<< 6)  : 
                          ({multiplier[6],  multiplier[5]}  == 2'b10) ? -(M <<< 6)  : 32'sd0; 
 
wire signed [31:0] pp7  = ({multiplier[7],  multiplier[6]}  == 2'b01) ?  (M <<< 7)  : 
                          ({multiplier[7],  multiplier[6]}  == 2'b10) ? -(M <<< 7)  : 32'sd0; 
 
wire signed [31:0] pp8  = ({multiplier[8],  multiplier[7]}  == 2'b01) ?  (M <<< 8)  : 
                          ({multiplier[8],  multiplier[7]}  == 2'b10) ? -(M <<< 8)  : 32'sd0; 
 

wire signed [31:0] pp9  = ({multiplier[9],  multiplier[8]}  == 2'b01) ?  (M <<< 9)  : 
                          ({multiplier[9],  multiplier[8]}  == 2'b10) ? -(M <<< 9)  : 32'sd0; 
 
wire signed [31:0] pp10 = ({multiplier[10], multiplier[9]}  == 2'b01) ?  (M <<< 10) : 
                          ({multiplier[10], multiplier[9]}  == 2'b10) ? -(M <<< 10) : 32'sd0; 
 
wire signed [31:0] pp11 = ({multiplier[11], multiplier[10]} == 2'b01) ?  (M <<< 11) : 
                          ({multiplier[11], multiplier[10]} == 2'b10) ? -(M <<< 11) : 32'sd0; 
 
wire signed [31:0] pp12 = ({multiplier[12], multiplier[11]} == 2'b01) ?  (M <<< 12) : 
                          ({multiplier[12], multiplier[11]} == 2'b10) ? -(M <<< 12) : 32'sd0; 
 
wire signed [31:0] pp13 = ({multiplier[13], multiplier[12]} == 2'b01) ?  (M <<< 13) : 
                          ({multiplier[13], multiplier[12]} == 2'b10) ? -(M <<< 13) : 32'sd0; 
 
wire signed [31:0] pp14 = ({multiplier[14], multiplier[13]} == 2'b01) ?  (M <<< 14) : 
                          ({multiplier[14], multiplier[13]} == 2'b10) ? -(M <<< 14) : 32'sd0; 
 
wire signed [31:0] pp15 = ({multiplier[15], multiplier[14]} == 2'b01) ?  (M <<< 15) : 
                          ({multiplier[15], multiplier[14]} == 2'b10) ? -(M <<< 15) : 32'sd0; 
 
assign product = 
       pp0  + pp1  + pp2  + pp3 
     + pp4  + pp5  + pp6  + pp7 
     + pp8  + pp9  + pp10 + pp11 
     + pp12 + pp13 + pp14 + pp15; 

 
endmodule