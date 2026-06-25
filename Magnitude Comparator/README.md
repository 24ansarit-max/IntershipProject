# Magnitude Comparator

This directory contains LLM-generated implementations of a **16-bit Magnitude Comparator** extracted from the prompt collections. Each design is organized by model (`GPT-5.5`), RTL style, and prompting technique.

## Repository layout

```
Magnitude Comparator/
├── GPT-5.5/              # Empty reference directory
├── Behavioural/
│   ├── 01_Zero_Shot/ … 10_Hybrid/
├── Dataflow/
│   ├── 01_Zero_Shot/ … 10_Hybrid/
└── Structural/
    ├── 01_Zero_Shot/ … 10_Hybrid/
```

Every prompting folder contains:

| File | Purpose |
|------|---------|
| `Prompt.txt` | The exact prompt used to generate the RTL |
| `magnitude comparator.v` | The generated Verilog implementation |

## RTL implementation styles

### Behavioural

Procedural RTL using `always @(*)` blocks with `if/else if/else` statements. The outputs are declared as `reg` and assigned in every single branch to prevent inferred latches. This style provides high-level algorithmic description suitable for synthesis tools to optimize down to LUTs on target FPGAs such as the Xilinx Artix-7.

### Dataflow

Continuous-assignment style (`assign` only). Outputs are driven by continuous relational operators (`A > B`, `A < B`, `A == B`, etc.) directly on input operands. No procedural blocks (`always`), no structural instantiations, and no gate primitives are used. This style highlights direct Boolean mappings and combinational propagation.

### Structural

Hierarchical gate-level gate-primitive instantiations. No `always` blocks and no continuous relational operators are used for the main comparison chain. The design utilizes sub-modules:
- `cmp1`: 1-bit comparator cell using structural gates (`not`, `and`, `xor`).
- `cmp4`: 4-bit comparator group instantiating `cmp1` sub-modules.
- `cmp16_structural`: Top-level module instantiating four `cmp4` modules and combining the results hierarchically.
It features synthesized PPA optimization parameters (`POWER_OPT`, `AREA_OPT`, `DELAY_OPT`) using conditional generate constructs.

## Common specification

| Parameter | Value |
|-----------|-------|
| Width | 16 bits |
| Inputs | `A[15:0]`, `B[15:0]` |
| Outputs | `A_gt_B` (A > B), `A_lt_B` (A < B), `A_eq_B` (A == B) |
| Additional Outputs (Dataflow) | `A_gte_B` (A >= B), `A_lte_B` (A <= B), `eq_bitwise` |

## Prompting techniques

| Folder | Technique | Purpose |
|--------|-----------|---------|
| `01_Zero_Shot` | Zero-shot | Minimal instruction with no examples; tests baseline LLM RTL ability |
| `02_Few_Shot` | Few-shot | Reference snippets provided as style anchors before the main task |
| `03_Chain_of_Thought` | Chain-of-thought | Step-by-step reasoning required before code generation |
| `04_Role_Prompting` | Role prompting | Senior VLSI engineer persona with deliverable-oriented framing |
| `05_Instruction_Format` | Instruction + format | Strict output structure and module naming conventions |
| `06_Negative_Prompting` | Negative prompting | Explicit "do not" rules to avoid invalid styles and latch inference |
| `07_Constraints_First` | Constraints-first | Area, power, and timing (PPA) constraints stated before design |
| `08_Self_Planning` | Self-planning | Phased design plan (signals, critical path, PPA estimates) before RTL |
| `09_Iterative_Correction` | Iterative correction | Multi-pass refinement with self-correction checklist loops |
| `10_Hybrid` | Hybrid | Combines role, planning, constraints, negative rules, and self-check |

## Simulation

Compile one folder at a time (module names may overlap across techniques):

```bash
iverilog -g2012 -o sim "Magnitude Comparator/Behavioural/01_Zero_Shot/magnitude comparator.v"
vvp sim
```
