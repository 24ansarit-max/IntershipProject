// Strategy: 06 Negative Prompting
// Style: Behavioural
`timescale 1ns/1ps

module priority_encoder_16 (
    input  wire [15:0] in,
    output reg  [3:0]  out,
    output reg         valid
);

    integer i;
    always @(*) begin
        out = 4'd0;
        valid = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            if (in[i]) begin
                out = i[3:0];
                valid = 1'b1;
            end
        end
    end

endmodule
