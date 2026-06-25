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
 
    integer i; 
    integer j; 
 
    wire ce; 
    assign ce = (mode != 2'b00); 
 
    genvar g; 
    generate 
        for (g = 0; g < WIDTH; g = g + 1) begin : ff_array 
            // Expected inferred storage element: FDRE 
        end 
    endgenerate 

 
    always @(posedge clk) begin 
        if (rst) begin 
            q <= {WIDTH{1'b0}}; 
        end 
        else if (ce) begin 
            case (mode) 
 
                2'b01: begin 
                    for (i = 0; i < WIDTH-1; i = i + 1) begin 
                        q[i] <= q[i+1]; 
                    end 
                    q[WIDTH-1] <= serial_in; 
                end 
 
                2'b10: begin 
                    j = WIDTH - 1; 
                    while (j > 0) begin 
                        q[j] <= q[j-1]; 
                        j = j - 1; 
                    end 
                    q[0] <= serial_in; 
                end 
 
                2'b11: begin 
                    q <= data_in; 
                end 
 

                default: begin 
                    q <= q; 
                end 
 
            endcase 
        end 
        else begin 
            q <= q; 
        end 
    end 
 
endmodule