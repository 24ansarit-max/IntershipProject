module booth_multiplier_16bit ( 
    input  signed [15:0] multiplicand, 
    input  signed [15:0] multiplier, 

    output signed [31:0] product 
); 
 
    // Sign-extended multiplicand 
    wire signed [31:0] m_ext; 
 
    // Extended multiplier for Booth encoding 
    wire [16:0] q_ext; 
 
    assign m_ext = {{16{multiplicand[15]}}, multiplicand}; 
    assign q_ext = {multiplier, 1'b0}; 
 
    // Partial products 
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
 
    assign pp0  = (q_ext[1:0]    == 2'b01) ? (m_ext <<< 0)  : 
                  (q_ext[1:0]    == 2'b10) ? -(m_ext <<< 0) : 
                  32'sd0; 
 
    assign pp1  = (q_ext[2:1]    == 2'b01) ? (m_ext <<< 1)  : 
                  (q_ext[2:1]    == 2'b10) ? -(m_ext <<< 1) : 
                  32'sd0; 
 
    assign pp2  = (q_ext[3:2]    == 2'b01) ? (m_ext <<< 2)  : 
                  (q_ext[3:2]    == 2'b10) ? -(m_ext <<< 2) : 
                  32'sd0; 
 
    assign pp3  = (q_ext[4:3]    == 2'b01) ? (m_ext <<< 3)  : 
                  (q_ext[4:3]    == 2'b10) ? -(m_ext <<< 3) : 
                  32'sd0; 
 
    assign pp4  = (q_ext[5:4]    == 2'b01) ? (m_ext <<< 4)  : 
                  (q_ext[5:4]    == 2'b10) ? -(m_ext <<< 4) : 
                  32'sd0; 
 
    assign pp5  = (q_ext[6:5]    == 2'b01) ? (m_ext <<< 5)  : 
                  (q_ext[6:5]    == 2'b10) ? -(m_ext <<< 5) : 

                  32'sd0; 
 
    assign pp6  = (q_ext[7:6]    == 2'b01) ? (m_ext <<< 6)  : 
                  (q_ext[7:6]    == 2'b10) ? -(m_ext <<< 6) : 
                  32'sd0; 
 
    assign pp7  = (q_ext[8:7]    == 2'b01) ? (m_ext <<< 7)  : 
                  (q_ext[8:7]    == 2'b10) ? -(m_ext <<< 7) : 
                  32'sd0; 
 
    assign pp8  = (q_ext[9:8]    == 2'b01) ? (m_ext <<< 8)  : 
                  (q_ext[9:8]    == 2'b10) ? -(m_ext <<< 8) : 
                  32'sd0; 
 
    assign pp9  = (q_ext[10:9]   == 2'b01) ? (m_ext <<< 9)  : 
                  (q_ext[10:9]   == 2'b10) ? -(m_ext <<< 9) : 
                  32'sd0; 
 
    assign pp10 = (q_ext[11:10]  == 2'b01) ? (m_ext <<< 10) : 
                  (q_ext[11:10]  == 2'b10) ? -(m_ext <<< 10) : 
                  32'sd0; 
 
    assign pp11 = (q_ext[12:11]  == 2'b01) ? (m_ext <<< 11) : 
                  (q_ext[12:11]  == 2'b10) ? -(m_ext <<< 11) : 
                  32'sd0; 
 

    assign pp12 = (q_ext[13:12]  == 2'b01) ? (m_ext <<< 12) : 
                  (q_ext[13:12]  == 2'b10) ? -(m_ext <<< 12) : 
                  32'sd0; 
 
    assign pp13 = (q_ext[14:13]  == 2'b01) ? (m_ext <<< 13) : 
                  (q_ext[14:13]  == 2'b10) ? -(m_ext <<< 13) : 
                  32'sd0; 
 
    assign pp14 = (q_ext[15:14]  == 2'b01) ? (m_ext <<< 14) : 
                  (q_ext[15:14]  == 2'b10) ? -(m_ext <<< 14) : 
                  32'sd0; 
 
    assign pp15 = (q_ext[16:15]  == 2'b01) ? (m_ext <<< 15) : 
                  (q_ext[16:15]  == 2'b10) ? -(m_ext <<< 15) : 
                  32'sd0; 
 
    // Reduction tree 
    wire signed [31:0] s0; 
    wire signed [31:0] s1; 
    wire signed [31:0] s2; 
    wire signed [31:0] s3; 
    wire signed [31:0] s4; 
    wire signed [31:0] s5; 
    wire signed [31:0] s6; 
    wire signed [31:0] s7; 
 

    assign s0 = pp0  + pp1; 
    assign s1 = pp2  + pp3; 
    assign s2 = pp4  + pp5; 
    assign s3 = pp6  + pp7; 
    assign s4 = pp8  + pp9; 
    assign s5 = pp10 + pp11; 
    assign s6 = pp12 + pp13; 
    assign s7 = pp14 + pp15; 
 
    wire signed [31:0] t0; 
    wire signed [31:0] t1; 
    wire signed [31:0] t2; 
    wire signed [31:0] t3; 
 
    assign t0 = s0 + s1; 
    assign t1 = s2 + s3; 
    assign t2 = s4 + s5; 
    assign t3 = s6 + s7; 
 
    wire signed [31:0] u0; 
    wire signed [31:0] u1; 
 
    assign u0 = t0 + t1; 
    assign u1 = t2 + t3; 
 
    wire signed [31:0] final_sum; 

 
    assign final_sum = u0 + u1; 
 
    assign product = final_sum; 
 
endmodule