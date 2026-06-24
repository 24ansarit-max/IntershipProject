`timescale 1ns/1ps 
 
module cla_iterative #( 
    parameter N = 8 
)( 
    input  [N-1:0] A, 
    input  [N-1:0] B, 
    input          Cin, 
    output reg [N-1:0] Sum, 
    output reg         Cout 
); 
 
    reg [N-1:0] G; 
    reg [N-1:0] P; 
    reg [N:0]   C; 
 
    reg [N:0]   C_prev; 
 
    integer i; 
    integer iter; 
    reg changed; 
 
    always @(*) begin 
 
        //-------------------------------------------------- 
        // Generate and Propagate 
        //-------------------------------------------------- 
        for(i = 0; i < N; i = i + 1) begin 
            G[i] = A[i] & B[i]; 
            P[i] = A[i] ^ B[i]; 
        end 
 
        //-------------------------------------------------- 
        // Initial carry estimate 
        //-------------------------------------------------- 
        C = {(N+1){1'b0}}; 
        C[0] = Cin; 
 
        for(i = 0; i < N; i = i + 1) 
            C[i+1] = G[i] | (P[i] & C[i]); 
 
        //-------------------------------------------------- 
        // Iterative correction 
        //-------------------------------------------------- 
        for(iter = 0; iter < N; iter = iter + 1) begin 
 
            C_prev = C; 
            changed = 1'b0; 
 
            C[0] = Cin; 
 
            for(i = 0; i < N; i = i + 1) 
                C[i+1] = G[i] | (P[i] & C[i]); 
 
            if(C != C_prev) 
                changed = 1'b1; 
 
            if(!changed) 
                iter = N; 
        end 
 
        //-------------------------------------------------- 
        // Final sum 
        //-------------------------------------------------- 
        for(i = 0; i < N; i = i + 1) 
            Sum[i] = P[i] ^ C[i]; 
 
        Cout = C[N]; 
    end 
 
endmodule
