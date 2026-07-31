module shift_reg_16 #( 

    parameter WIDTH = 16 
)( 
    input  wire              clk, 
    input  wire              rst, 
    input  wire [1:0]        mode,       // 00=hold 01=right 10=left 11=load 
    input  wire              serial_in, 
    input  wire [WIDTH-1:0]  data_in, 
    output reg  [WIDTH-1:0]  q 
); 
 
    wire [WIDTH-1:0] right_taps; 
    wire [WIDTH-1:0] left_taps; 
    wire [WIDTH-1:0] right_path; 
    wire [WIDTH-1:0] left_path; 
    wire [WIDTH-1:0] next_q; 
    wire             ce; 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right 
            assign right_taps[i] = q[i+1]; 
        end 
    endgenerate 
 
    assign right_taps[WIDTH-1] = serial_in; 
 
    generate 

        for (i = 1; i < WIDTH; i = i + 1) begin : gen_left 
            assign left_taps[i] = q[i-1]; 
        end 
    endgenerate 
 
    assign left_taps[0] = serial_in; 
 
    assign right_path = right_taps; 
 
    assign left_path  = left_taps; 
 
    assign next_q = 
           (mode == 2'b01) ? right_path : 
           (mode == 2'b10) ? left_path  : 
           (mode == 2'b11) ? data_in    : 
                             q; 
 
    assign ce = (mode != 2'b00); 
 
    always @(posedge clk) begin 
        if (rst) 
            q <= {WIDTH{1'b0}}; 
        else if (ce) 
            q <= next_q; 
    end 
 
endmodule