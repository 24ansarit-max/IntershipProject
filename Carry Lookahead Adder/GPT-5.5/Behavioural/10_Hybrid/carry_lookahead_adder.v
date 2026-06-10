`timescale 1ns/1ps 
 
//==================================================== 
// Behavioral CLA using Iterative Correction 
//==================================================== 
module cla_iterative #( 
    parameter N = 8 
)( 
    input  [N-1:0] A, 
    input  [N-1:0] B, 
    input          Cin, 
 
    output reg [N-1:0] Sum, 
    output reg         Cout 
); 
 
    integer i; 
    integer iter; 
 
    reg [N-1:0] G; 
    reg [N-1:0] P; 
 
    reg [N:0] C; 
    reg [N:0] C_prev; 
 
    reg converged; 
 
    always @(*) begin 
 
        //------------------------------------------------ 
        // Generate / Propagate 
        //------------------------------------------------ 
        for(i=0; i<N; i=i+1) begin 
            G[i] = A[i] & B[i]; 
            P[i] = A[i] ^ B[i]; 
        end 
 
        //------------------------------------------------ 
        // Initial Carry Estimate 
        //------------------------------------------------ 
        C = {(N+1){1'b0}}; 
        C[0] = Cin; 
 
        for(i=0; i<N; i=i+1) 
            C[i+1] = G[i] | (P[i] & C[i]); 
 
        //------------------------------------------------ 
        // Iterative Correction Loop 
        //------------------------------------------------ 
        converged = 1'b0; 
        iter      = 0; 
 
        while((!converged) && (iter < N)) begin 
 
            C_prev = C; 
 
            C[0] = Cin; 
 
            for(i=0; i<N; i=i+1) 
                C[i+1] = G[i] | (P[i] & C[i]); 
 
            if(C == C_prev) 
                converged = 1'b1; 
 
            iter = iter + 1; 
        end 
 
        //------------------------------------------------ 
        // Final Sum 
        //------------------------------------------------ 
        for(i=0; i<N; i=i+1) 
            Sum[i] = P[i] ^ C[i]; 
 
        Cout = C[N]; 
 
    end 
 
endmodule
