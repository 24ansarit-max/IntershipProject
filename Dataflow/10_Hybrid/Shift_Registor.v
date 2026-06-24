module shift_reg_16 #( 
    parameter WIDTH = 16 
)( 
    input  wire              clk, 
    input  wire              rst, 
    input  wire [1:0]        mode, 
    input  wire              serial_in, 
    input  wire [WIDTH-1:0]  data_in, 
    output reg  [WIDTH-1:0]  q 
); 
 
    wire [WIDTH-1:0] r_tap; 
    wire [WIDTH-1:0] l_tap; 
    wire [WIDTH-1:0] next_q; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right 
            assign r_tap[i] = q[i+1]; 
        end 

    endgenerate 
 
    assign r_tap[WIDTH-1] = serial_in; 
 
    genvar j; 
 
    generate 
        for (j = WIDTH-1; j > 0; j = j - 1) begin : gen_left 
            assign l_tap[j] = q[j-1]; 
        end 
    endgenerate 
 
    assign l_tap[0] = serial_in; 
 
    assign next_q = 
           (mode == 2'b01) ? r_tap   : 
           (mode == 2'b10) ? l_tap   : 
           (mode == 2'b11) ? data_in : 
                             q; 
 
    always @(posedge clk) begin 
        if (rst) 
            q <= {WIDTH{1'b0}}; 
        else if (mode != 2'b00) 
            q <= next_q; 
    end 
 
endmodule