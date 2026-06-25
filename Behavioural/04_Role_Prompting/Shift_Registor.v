module shift_reg_16 ( 
    input  wire        clk,           // System clock 
    input  wire        rst,           // Synchronous active-high reset 
    input  wire        shift_en,      // Shift enable 
    input  wire        dir,           // 0 = right shift, 1 = left shift 
    input  wire        serial_in,     // Serial input bit 
    input  wire        parallel_load, // Parallel load control 
    input  wire [15:0] data_in,       // Parallel load data 
    output reg  [15:0] q             // Shift register contents 
); 
 
    integer i; // Loop variable 
 
    // -------------------------------------------------------------------- 
    // POWER: Shared clock-enable condition. 
    // 
    // Vivado is expected to infer the CE pin on FDRE primitives because 

    // q is only updated when ce_int is asserted. 
    // 
    // CE asserted only when: 
    //   1) Parallel load requested 
    //   2) Shift operation requested 
    // 
    // During idle/hold cycles all 16 FFs retain state without toggling. 
    // -------------------------------------------------------------------- 
    wire ce_int; 
    assign ce_int = parallel_load | shift_en; 
 
    // -------------------------------------------------------------------- 
    // Universal Shift Register 
    // -------------------------------------------------------------------- 
    always @(posedge clk) begin 
 
        if (rst) begin 
            q <= 16'b0; // Synchronous reset 
        end 
 
        // POWER: Enables FDRE CE inference. 
        // AREA : Single shared enable drives all register bits. 
        else if (ce_int) begin 
 
            // ------------------------------------------------------------ 
            // Parallel Load has priority over shifting. 
            // ------------------------------------------------------------ 
            if (parallel_load) begin 

 
                // POWER: One-cycle update only when new data arrives. 
                // AREA : Direct register load minimizes logic depth. 
                q <= data_in; 
 
            end 
            else begin 
 
                // -------------------------------------------------------- 
                // Shift Right 
                // -------------------------------------------------------- 
                if (dir == 1'b0) begin 
 
                    // POWER: Register chain only toggles when shift_en=1. 
                    for (i = 0; i < 15; i = i + 1) begin 
                        q[i] <= q[i+1]; 
                    end 
 
                    q[15] <= serial_in; 
                end 
 
                // -------------------------------------------------------- 
                // Shift Left 
                // -------------------------------------------------------- 
                else begin 
 
                    // POWER: Register chain only toggles when shift_en=1. 
                    for (i = 15; i > 0; i = i - 1) begin 

                        q[i] <= q[i-1]; 
                    end 
 
                    q[0] <= serial_in; 
                end 
            end 
        end 
 
        // POWER: 
        // No assignment when ce_int=0. 
        // Vivado infers FDRE clock-enable usage rather than creating 
        // unnecessary data-path toggling. 
    end 
 
    // -------------------------------------------------------------------- 
    // SIM ONLY 
    // Conceptual repeat-loop illustration (NOT synthesised) 
    // 
    // initial begin 
    //     repeat (16) begin 
    //         // Conceptually demonstrates replicated shift stages. 
    //     end 
    // end 
    // -------------------------------------------------------------------- 
 
    // -------------------------------------------------------------------- 
    // SIM ONLY 
    // Example forever-loop clock generator (NOT synthesised) 

    // 
    // initial begin 
    //     forever #5 clk = ~clk; 
    // end 
    // -------------------------------------------------------------------- 
 
endmodule