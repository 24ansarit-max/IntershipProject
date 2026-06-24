module booth_multiplier_16 ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 

    output signed [31:0] product 
); 
 
    // Extended multiplicand for sign-preserving shifts 
    wire signed [31:0] m_ext = {{16{multiplicand[15]}}, multiplicand}; 
 
    // Booth recoding bits 
    wire [16:0] y = {multiplier, 1'b0}; 
 
    // Partial products 
    wire signed [31:0] pp0  = ( y[1]  & ~y[0] ) ?  (m_ext <<< 0 ) : 
                              (~y[1]  &  y[0] ) ? -(m_ext <<< 0 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp1  = ( y[2]  & ~y[1] ) ?  (m_ext <<< 1 ) : 
                              (~y[2]  &  y[1] ) ? -(m_ext <<< 1 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp2  = ( y[3]  & ~y[2] ) ?  (m_ext <<< 2 ) : 
                              (~y[3]  &  y[2] ) ? -(m_ext <<< 2 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp3  = ( y[4]  & ~y[3] ) ?  (m_ext <<< 3 ) : 
                              (~y[4]  &  y[3] ) ? -(m_ext <<< 3 ) : 
                              32'sd0; 
 

    wire signed [31:0] pp4  = ( y[5]  & ~y[4] ) ?  (m_ext <<< 4 ) : 
                              (~y[5]  &  y[4] ) ? -(m_ext <<< 4 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp5  = ( y[6]  & ~y[5] ) ?  (m_ext <<< 5 ) : 
                              (~y[6]  &  y[5] ) ? -(m_ext <<< 5 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp6  = ( y[7]  & ~y[6] ) ?  (m_ext <<< 6 ) : 
                              (~y[7]  &  y[6] ) ? -(m_ext <<< 6 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp7  = ( y[8]  & ~y[7] ) ?  (m_ext <<< 7 ) : 
                              (~y[8]  &  y[7] ) ? -(m_ext <<< 7 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp8  = ( y[9]  & ~y[8] ) ?  (m_ext <<< 8 ) : 
                              (~y[9]  &  y[8] ) ? -(m_ext <<< 8 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp9  = ( y[10] & ~y[9] ) ?  (m_ext <<< 9 ) : 
                              (~y[10] &  y[9] ) ? -(m_ext <<< 9 ) : 
                              32'sd0; 
 
    wire signed [31:0] pp10 = ( y[11] & ~y[10]) ?  (m_ext <<< 10) : 
                              (~y[11] &  y[10]) ? -(m_ext <<< 10) : 

                              32'sd0; 
 
    wire signed [31:0] pp11 = ( y[12] & ~y[11]) ?  (m_ext <<< 11) : 
                              (~y[12] &  y[11]) ? -(m_ext <<< 11) : 
                              32'sd0; 
 
    wire signed [31:0] pp12 = ( y[13] & ~y[12]) ?  (m_ext <<< 12) : 
                              (~y[13] &  y[12]) ? -(m_ext <<< 12) : 
                              32'sd0; 
 
    wire signed [31:0] pp13 = ( y[14] & ~y[13]) ?  (m_ext <<< 13) : 
                              (~y[14] &  y[13]) ? -(m_ext <<< 13) : 
                              32'sd0; 
 
    wire signed [31:0] pp14 = ( y[15] & ~y[14]) ?  (m_ext <<< 14) : 
                              (~y[15] &  y[14]) ? -(m_ext <<< 14) : 
                              32'sd0; 
 
    wire signed [31:0] pp15 = ( y[16] & ~y[15]) ?  (m_ext <<< 15) : 
                              (~y[16] &  y[15]) ? -(m_ext <<< 15) : 
                              32'sd0; 
 
    // Final summation 
    assign product = 
           pp0  + pp1  + pp2  + pp3 
         + pp4  + pp5  + pp6  + pp7 

         + pp8  + pp9  + pp10 + pp11 
         + pp12 + pp13 + pp14 + pp15; 
 
endmodule