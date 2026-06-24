module booth_multiplier_16 ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 
    output signed [31:0] product 
); 
 
    // Booth recoding bits 
    wire [16:0] booth_bits; 
    assign booth_bits = {multiplier, 1'b0}; 

 
    // Sign-extended multiplicand 
    wire signed [31:0] M; 
    assign M = {{16{multiplicand[15]}}, multiplicand}; 
 
    // Booth partial products 
    wire signed [31:0] pp0; 
    wire signed [31:0] pp1; 
    wire signed [31:0] pp2; 
    wire signed [31:0] pp3; 
    wire signed [31:0] pp4; 
    wire signed [31:0] pp5; 
    wire signed [31:0] pp6; 
    wire signed [31:0] pp7; 
    wire signed [31:0] pp8; 
    wire signed [31:0] pp9; 
    wire signed [31:0] pp10; 
    wire signed [31:0] pp11; 
    wire signed [31:0] pp12; 
    wire signed [31:0] pp13; 
    wire signed [31:0] pp14; 
    wire signed [31:0] pp15; 
 
    assign pp0  = (booth_bits[1:0]   == 2'b01) ? ( M <<< 0 ) : 
                  (booth_bits[1:0]   == 2'b10) ? (-M <<< 0 ) : 
                  32'sd0; 

 
    assign pp1  = (booth_bits[2:1]   == 2'b01) ? ( M <<< 1 ) : 
                  (booth_bits[2:1]   == 2'b10) ? (-M <<< 1 ) : 
                  32'sd0; 
 
    assign pp2  = (booth_bits[3:2]   == 2'b01) ? ( M <<< 2 ) : 
                  (booth_bits[3:2]   == 2'b10) ? (-M <<< 2 ) : 
                  32'sd0; 
 
    assign pp3  = (booth_bits[4:3]   == 2'b01) ? ( M <<< 3 ) : 
                  (booth_bits[4:3]   == 2'b10) ? (-M <<< 3 ) : 
                  32'sd0; 
 
    assign pp4  = (booth_bits[5:4]   == 2'b01) ? ( M <<< 4 ) : 
                  (booth_bits[5:4]   == 2'b10) ? (-M <<< 4 ) : 
                  32'sd0; 
 
    assign pp5  = (booth_bits[6:5]   == 2'b01) ? ( M <<< 5 ) : 
                  (booth_bits[6:5]   == 2'b10) ? (-M <<< 5 ) : 
                  32'sd0; 
 
    assign pp6  = (booth_bits[7:6]   == 2'b01) ? ( M <<< 6 ) : 
                  (booth_bits[7:6]   == 2'b10) ? (-M <<< 6 ) : 
                  32'sd0; 
 
    assign pp7  = (booth_bits[8:7]   == 2'b01) ? ( M <<< 7 ) : 

                  (booth_bits[8:7]   == 2'b10) ? (-M <<< 7 ) : 
                  32'sd0; 
 
    assign pp8  = (booth_bits[9:8]   == 2'b01) ? ( M <<< 8 ) : 
                  (booth_bits[9:8]   == 2'b10) ? (-M <<< 8 ) : 
                  32'sd0; 
 
    assign pp9  = (booth_bits[10:9]  == 2'b01) ? ( M <<< 9 ) : 
                  (booth_bits[10:9]  == 2'b10) ? (-M <<< 9 ) : 
                  32'sd0; 
 
    assign pp10 = (booth_bits[11:10] == 2'b01) ? ( M <<< 10 ) : 
                  (booth_bits[11:10] == 2'b10) ? (-M <<< 10 ) : 
                  32'sd0; 
 
    assign pp11 = (booth_bits[12:11] == 2'b01) ? ( M <<< 11 ) : 
                  (booth_bits[12:11] == 2'b10) ? (-M <<< 11 ) : 
                  32'sd0; 
 
    assign pp12 = (booth_bits[13:12] == 2'b01) ? ( M <<< 12 ) : 
                  (booth_bits[13:12] == 2'b10) ? (-M <<< 12 ) : 
                  32'sd0; 
 
    assign pp13 = (booth_bits[14:13] == 2'b01) ? ( M <<< 13 ) : 
                  (booth_bits[14:13] == 2'b10) ? (-M <<< 13 ) : 
                  32'sd0; 

 
    assign pp14 = (booth_bits[15:14] == 2'b01) ? ( M <<< 14 ) : 
                  (booth_bits[15:14] == 2'b10) ? (-M <<< 14 ) : 
                  32'sd0; 
 
    assign pp15 = (booth_bits[16:15] == 2'b01) ? ( M <<< 15 ) : 
                  (booth_bits[16:15] == 2'b10) ? (-M <<< 15 ) : 
                  32'sd0; 
 
    // Final summation 
    assign product = 
          pp0  + pp1  + pp2  + pp3 
        + pp4  + pp5  + pp6  + pp7 
        + pp8  + pp9  + pp10 + pp11 
        + pp12 + pp13 + pp14 + pp15; 
 
endmodule