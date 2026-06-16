//============================================================== 
// ITERATION 1 - Initial implementation 
//============================================================== 
 
module ripple_carry_adder_16 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 
    input  wire        cin, 
    output reg  [15:0] sum, 
    output reg         cout 
); 
 
    reg [16:0] carry; 
    integer i; 
 
    always @(*) begin 
        carry[0] = cin; 
 
        for (i = 0; i < 16; i = i + 1) begin 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            carry[i+1] = 

                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
        end 
 
        cout = carry[16]; 
    end 
 
endmodule 
 
 
 
//============================================================== 
// ITERATION 2 - Latch elimination pass 
//============================================================== 
// 
// Review: 
// ✓ sum[i] assigned every loop iteration 
// ✓ carry[i+1] assigned every loop iteration 
// ✓ carry[] now fully initialized 
// ✓ cout initialized 
// 
//============================================================== 
 
module ripple_carry_adder_16_v2 
( 
    input  wire [15:0] a, 
    input  wire [15:0] b, 

    input  wire        cin, 
    output reg  [15:0] sum, 
    output reg         cout 
); 
 
    reg [16:0] carry; 
    integer i; 
 
    always @(*) begin 
 
        carry = 17'b0;          // fix: latch eliminated 
        sum   = 16'b0;          // fix: latch eliminated 
        cout  = 1'b0;           // fix: latch eliminated 
 
        carry[0] = cin; 
 
        for (i = 0; i < 16; i = i + 1) begin 
 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
        cout = carry[16]; 

 
    end 
 
endmodule 
 
 
 
//============================================================== 
// ITERATION 3 - Parameterization pass 
//============================================================== 
 
module ripple_carry_adder 
#( 
    parameter WIDTH = 16      // fix: parameterized for reuse 
) 
( 
    input  wire [WIDTH-1:0] a, 
    input  wire [WIDTH-1:0] b, 
    input  wire             cin, 
 
    output reg  [WIDTH-1:0] sum, 
    output reg              cout 
); 
 
    reg [WIDTH:0] carry;      // fix: parameterized for reuse 
 
    integer i; 
 

    always @(*) begin 
 
        carry = {(WIDTH+1){1'b0}};   // fix: latch eliminated 
        sum   = {WIDTH{1'b0}};       // fix: latch eliminated 
        cout  = 1'b0;                // fix: latch eliminated 
 
        carry[0] = cin; 
 
        for (i = 0; i < WIDTH; i = i + 1) begin 
            // fix: parameterized for reuse 
 
            sum[i] = a[i] ^ b[i] ^ carry[i]; 
 
            carry[i+1] = 
                (a[i] & b[i]) | 
                (a[i] & carry[i]) | 
                (b[i] & carry[i]); 
 
        end 
 
        cout = carry[WIDTH]; 
 
    end 
 
endmodule