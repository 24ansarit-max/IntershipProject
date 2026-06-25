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

 
    wire [WIDTH-1:0] r_taps;             // AREA: right-shift tap network (wire-only) 
    wire [WIDTH-1:0] right_shifted;      // AREA: right-shift datapath 
    wire [WIDTH-1:0] left_shifted;       // AREA: left-shift datapath 
    wire [WIDTH-1:0] next_q;             // TIMING: mux output driving FDRE D inputs 
    wire             ce;                 // POWER: CE inference signal 
 
    genvar i; 
 
    generate 
        for (i = 0; i < WIDTH-1; i = i + 1) begin : gen_right_taps 
            assign r_taps[i] = q[i+1];   // AREA: wire tap, 0 LUTs 
        end 
    endgenerate 
 
    assign r_taps[WIDTH-1] = serial_in;  // AREA: wire insertion, 0 LUTs 
 
    assign right_shifted = {serial_in, (q >> 1)[WIDTH-2:0]}; 
                                         // AREA: shift wiring only 
                                         // TIMING: routing + mux input 
 
    assign left_shifted  = {(q << 1)[WIDTH-1:1], serial_in}; 
                                         // AREA: shift wiring only 
                                         // TIMING: routing + mux input 
 
    assign next_q = 
           (mode == 2'b01) ? right_shifted : 
           (mode == 2'b10) ? left_shifted  : 

           (mode == 2'b11) ? data_in       : 
                             q; 
                                         // TIMING: critical path = mode decode 
                                         // TIMING: -> mux network -> FDRE D pin 
                                         // TIMING: expected >100 MHz on Artix-7 -2 
 
    assign ce = (mode != 2'b00);         // POWER: enables CE inference 
                                         // POWER: prevents FF toggling in hold mode 
 
    always @(posedge clk) begin 
        if (rst) 
            q <= {WIDTH{1'b0}}; 
        else if (ce) 
            q <= next_q; 
    end 
 
    // AREA: SRL=NO (explicit FF-based register chain intended) 
 
endmodule