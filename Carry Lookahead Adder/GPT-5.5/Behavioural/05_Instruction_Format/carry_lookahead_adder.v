// ===== SECTION 1: MODULE HEADER & PARAMETERS (5 lines max) ===== 
`timescale 1ns/1ps 
module cla16_behavioral #(parameter WIDTH=16, GROUP=4) 
( 
    a,b,cin,sum,cout,overflow,zero,negative 
); 
 
// ===== SECTION 2: PORT DECLARATION (8 lines max) ===== 
input  [WIDTH-1:0] a,b; 
input              cin; 
output reg [WIDTH-1:0] sum; 
output reg         cout,overflow,zero,negative; 
 
// ===== SECTION 3: INTERNAL SIGNAL DECLARATIONS (6 lines max) ===== 
reg [WIDTH-1:0] g,p; 
reg [WIDTH:0]   c; 
reg [3:0]       gg,gp; 
integer i; 
 
// ===== SECTION 4: GENERATE & PROPAGATE (always block, 6 lines max) ===== 
always @(*) begin 
    for(i=0;i<WIDTH;i=i+1) begin 
        g[i]=a[i]&b[i]; 
        p[i]=a[i]^b[i]; 
    end 
 
// ===== SECTION 5: INTRA-GROUP CARRIES (16 lines — 4 per group) ===== 
    c[0]=cin; 
    c[1]=g[0]|(p[0]&c[0]); c[2]=g[1]|(p[1]&g[0])|(p[1]&p[0]&c[0]); 
c[3]=g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0])|(p[2]&p[1]&p[0]&c[0]); 
c[4]=g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0])|(p[3]&p[2]&p[1]&p[0]&c[0]); 
    c[5]=g[4]|(p[4]&c[4]); c[6]=g[5]|(p[5]&g[4])|(p[5]&p[4]&c[4]); 
c[7]=g[6]|(p[6]&g[5])|(p[6]&p[5]&g[4])|(p[6]&p[5]&p[4]&c[4]); 
c[8]=g[7]|(p[7]&g[6])|(p[7]&p[6]&g[5])|(p[7]&p[6]&p[5]&g[4])|(p[7]&p[6]&p[5]&p[4]&c[4]); 
    c[9]=g[8]|(p[8]&c[8]); c[10]=g[9]|(p[9]&g[8])|(p[9]&p[8]&c[8]); 
c[11]=g[10]|(p[10]&g[9])|(p[10]&p[9]&g[8])|(p[10]&p[9]&p[8]&c[8]); 
c[12]=g[11]|(p[11]&g[10])|(p[11]&p[10]&g[9])|(p[11]&p[10]&p[9]&g[8])|(p[11]&p[10]&p[9]&p[8]&
c[8]); 
    c[13]=g[12]|(p[12]&c[12]); c[14]=g[13]|(p[13]&g[12])|(p[13]&p[12]&c[12]); 
c[15]=g[14]|(p[14]&g[13])|(p[14]&p[13]&g[12])|(p[14]&p[13]&p[12]&c[12]); 
c[16]=g[15]|(p[15]&g[14])|(p[15]&p[14]&g[13])|(p[15]&p[14]&p[13]&g[12])|(p[15]&p[14]&p[13]&p
[12]&c[12]); 
 
// ===== SECTION 6: GROUP LOOKAHEAD (12 lines max) ===== 
    gp[0]=p[3]&p[2]&p[1]&p[0];    gg[0]=g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0]); 
    gp[1]=p[7]&p[6]&p[5]&p[4];    gg[1]=g[7]|(p[7]&g[6])|(p[7]&p[6]&g[5])|(p[7]&p[6]&p[5]&g[4]); 
    gp[2]=p[11]&p[10]&p[9]&p[8];  
gg[2]=g[11]|(p[11]&g[10])|(p[11]&p[10]&g[9])|(p[11]&p[10]&p[9]&g[8]); 
    
gp[3]=p[15]&p[14]&p[13]&p[12];gg[3]=g[15]|(p[15]&g[14])|(p[15]&p[14]&g[13])|(p[15]&p[14]&p[1
3]&g[12]); 
    c[4]=gg[0]|(gp[0]&c[0]); 
    c[8]=gg[1]|(gp[1]&gg[0])|(gp[1]&gp[0]&c[0]); 
    c[12]=gg[2]|(gp[2]&gg[1])|(gp[2]&gp[1]&gg[0])|(gp[2]&gp[1]&gp[0]&c[0]); 
    
c[16]=gg[3]|(gp[3]&gg[2])|(gp[3]&gp[2]&gg[1])|(gp[3]&gp[2]&gp[1]&gg[0])|(gp[3]&gp[2]&gp[1]&gp
[0]&c[0]); 
 
// ===== SECTION 7: OUTPUT FLAGS (5 lines max) ===== 
    for(i=0;i<WIDTH;i=i+1) sum[i]=p[i]^c[i]; 
    cout=c[16]; 
    overflow=(a[15]==b[15])&&(sum[15]!=a[15]); 
    zero=(sum==16'b0); 
    negative=sum[15]; 
end 
endmodule 
 
// ===== SECTION 8: PPA SUMMARY COMMENT BLOCK ===== 
// Power  : ~0.10–0.20 mW @ 100 MHz, 1.2 V (technology dependent) 
// Area   : ~150–180 gate equivalents after synthesis 
// Delay  : ~5–6 logic levels from input to cout 
// Delay vs RCA: CLA ≈ O(log N) style hierarchy, RCA ≈ O(N) carry propagation
