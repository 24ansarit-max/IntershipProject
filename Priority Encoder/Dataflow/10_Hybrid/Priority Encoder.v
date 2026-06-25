// Strategy: 10 Hybrid
// Style: Dataflow
`timescale 1ns/1ps

module priority_encoder_16 (
    input  wire [15:0] in,
    output wire [3:0]  out,
    output wire        valid
);

    assign valid = |in;

    assign out = in[15] ? 4'd15 :
                 in[14] ? 4'd14 :
                 in[13] ? 4'd13 :
                 in[12] ? 4'd12 :
                 in[11] ? 4'd11 :
                 in[10] ? 4'd10 :
                 in[9]  ? 4'd9  :
                 in[8]  ? 4'd8  :
                 in[7]  ? 4'd7  :
                 in[6]  ? 4'd6  :
                 in[5]  ? 4'd5  :
                 in[4]  ? 4'd4  :
                 in[3]  ? 4'd3  :
                 in[2]  ? 4'd2  :
                 in[1]  ? 4'd1  : 4'd0;

endmodule
