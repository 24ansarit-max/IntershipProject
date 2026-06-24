# 16-Bit Universal Shift Register Experiments

This project implements a 16-bit universal shift register targeting Xilinx Artix-7 FPGAs (specifically Nexys A7, xc7a100tcsg324-2) using three distinct Verilog styles and ten different LLM prompting techniques.

---

## Verilog Implementation Styles

### 1. Behavioural Implementation
The Behavioural style models the hardware using procedural blocks. It leverages clocked `always @(posedge clk)` blocks to describe the register's behavior at a high level. Control paths, multiplexers, and shifts are implemented using procedural constructs such as `case` statements, `if-else` branches, and procedural loops (`for` and `while`). It focuses on *what* the circuit does sequentially rather than its gate-level structure.

### 2. Dataflow Implementation
The Dataflow style models hardware using continuous assignment statements (`assign`) for all combinational logic, keeping it separate from sequential storage. It uses Verilog shift operators (`>>`, `<<`) and concatenation (`{}`) to specify shift pathways, and the ternary conditional operator (`?:`) for multiplexer mode selection. The computed next-state wire (`next_q`) is then registered in a single, simple clocked sequential block. This style mimics the physical logic paths feeding the flip-flop inputs.

### 3. Structural Implementation
The Structural style defines the hardware by instantiating and connecting smaller submodules (components). In this project, a D-type flip-flop (either basic `dff` or with clock enable `dff_ce`) is defined as a separate module. The top-level shift register contains no behavioural logic; instead, it instantiates 16 separate flip-flop submodules and connects them using `generate`/`for` loops. Muxes and control wiring are described using continuous assigns at the top level to drive the `D` inputs of the flip-flops.

---

## Prompting Techniques and Their Purpose

Each implementation directory contains 10 subfolders corresponding to different prompting techniques:

1. **01_Zero_Shot**: Evaluates the model's ability to generate the correct synthesizable Verilog code directly from a specification without any code examples or guidance.
2. **02_Few_Shot**: Provides the model with a few small reference examples (e.g., 4-bit left or right shift registers) to guide it in generating a 16-bit version in the correct style.
3. **03_Chain_of_Thought**: Instructs the model to think step-by-step about structural decisions, loop selection, and critical paths before writing code, documenting its reasoning in comments.
4. **04_Role_Prompting**: Assigns a specific persona to the model (e.g., senior RTL engineer, low-power design specialist) to focus on optimization metrics like power reduction and clock gating.
5. **05_Instruction_Format**: Enforces strict formatting constraints, requiring specific module headers, parameter sections, port declaration tables, and inline comments in a precise order.
6. **06_Negative_Prompting**: Lists anti-patterns and rules of what the model must *not* do (e.g., do not infer latches, do not use blocking assignments, do not use asynchronous resets) to ensure high-quality synthesizable RTL.
7. **07_Constraints_First**: Establishes strict design boundaries (e.g., Fmax > 100/200 MHz, LUT count ≤ 28/30, exactly 16 flip-flops) that must be reviewed and met before any code is written.
8. **08_Self_Planning**: Mandates that the model document a design plan as comments at the top of the file before writing the implementation, ensuring architectural alignment.
9. **09_Iterative_Correction**: Guides the model through building the design iteratively (e.g., baseline right-shift, add left-shift, add parallel load, add annotations, self-check), matching human design workflows.
10. **10_Hybrid**: Combines the most effective techniques (Role Prompting, Hard Constraints, Negative Guards, Chain-of-Thought, and Post-Module Constraint Verification blocks) to produce a production-grade IP.
