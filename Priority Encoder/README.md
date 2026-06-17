# Priority Encoder

This directory contains 10 LLM prompt engineering strategies applied to generate a synthesizable **16-to-4 Priority Encoder** in Verilog. The project is structured into three main architectural styles: Behavioural, Dataflow, and Structural, each containing 10 prompting technique folders.

---

## Implementations

### 1. Behavioural Implementation
The behavioral model implements the priority encoder using a procedural block (`always @(*)`) with a loop that scans input bits from `0` to `15` or vice versa. Since later assignments override earlier ones in Verilog blocking assignments, scanning from index 0 upwards ensures that the highest index bit active takes precedence, resulting in the correct priority encoding. This description is highly abstract, synthesizes into an optimized mux chain, and is clean to read.

### 2. Dataflow Implementation
The dataflow model uses continuous `assign` statements. The priority encoding is implemented as a cascade of conditional (`? :`) operators, checking inputs from MSB (`in[15]`) down to LSB (`in[1]`). The valid bit is computed as the reduction OR of all input bits (`assign valid = |in;`). This model is direct, combinatorial, and maps clearly to standard logic synthesis.

### 3. Structural Implementation
The structural model avoids behavioral blocks and continuous assignments in the core encoder. Instead, it defines:
*   A **4-to-2 Priority Encoder cell** using gate primitives (`or`, `not`, `and`).
*   A **4-to-1 2-bit Multiplexer** using gate primitives.
*   A top-level module that instantiates 4 group cells (each encoding 4 bits of the 16-bit input), 1 group cell to resolve the priority among the 4 groups, and a 4-to-1 2-bit multiplexer to select the lower 2 bits of the active group.

---

## Prompting Techniques

1.  **Zero-Shot**: Standard direct instruction without examples, testing the model's base knowledge.
2.  **Few-Shot**: Prompts that include short examples of smaller encoders (e.g. 4-bit) to guide the style.
3.  **Chain of Thought**: Prompts that force step-by-step thinking before outputting code.
4.  **Role Prompting**: Assigns a persona (e.g. Principal RTL Designer) to elevate the quality of design.
5.  **Instruction Format**: Specifies a strict formatting template for deliverables.
6.  **Negative Prompting**: Lists explicit constraints and prohibitions (e.g. what NOT to do).
7.  **Constraints First**: Prioritizes performance-power-area (PPA) synthesis constraints.
8.  **Self Planning**: Prompts the model to plan its approach before implementing the module.
9.  **Iterative Correction**: Reviews draft logic, checks against checklist rules, and corrects bugs.
10. **Hybrid**: Combines several techniques (role, constraints, negative rules) for high-reliability outputs.
