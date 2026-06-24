# Carry Lookahead Adder

This directory contains LLM-generated implementations of a **16-bit Carry Lookahead Adder (CLA)** extracted from `CARRY_LOOKAHEAD_ADDER.pdf`. Each design is organized by model (`GPT-5.5`), RTL style, and prompting technique.

## Repository layout

```
Carry Lookahead Adder/
└── GPT-5.5/
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
| `carry_lookahead_adder.v` | The generated Verilog implementation |

## RTL implementation styles

### Structural

Gate-level hierarchy using explicit module instantiations and primitive gates (`and`, `or`, `xor`, `buf`). Typical sub-modules include `pg_cell`, 4-bit carry lookahead blocks, and a top-level 16-bit integrator. No `always` blocks; carry equations are realized as interconnected gates. Best for studying true CLA parallelism and synthesis-friendly hierarchy.

### Dataflow

Pure continuous-assignment style (`assign` only). Propagate (`P[i] = a[i] ^ b[i]`) and generate (`G[i] = a[i] & b[i]`) terms are computed first, then intra-group and inter-group carry equations are expanded explicitly. No procedural blocks. Emphasizes the Boolean carry lookahead equations directly in RTL.

### Behavioural

Procedural RTL using `always @(*)` blocks with `reg` arrays for `g`, `p`, and `c`. Carry lookahead is expressed algorithmically inside combinational logic, often with grouped 4-bit blocks and inter-group carries. Includes signed overflow detection. Easier to read and modify at the algorithm level.

## Common specification

| Parameter | Value |
|-----------|-------|
| Width | 16 bits |
| Group size | 4 bits (four groups) |
| Inputs | `a[15:0]`, `b[15:0]`, `cin` |
| Outputs | `sum[15:0]`, `cout`, `overflow` |
| Architecture | Two-level carry lookahead (not ripple carry) |

## Prompting techniques

| Folder | Technique | Purpose |
|--------|-----------|---------|
| `01_Zero_Shot` | Zero-shot | Minimal instruction with no examples; tests baseline LLM RTL ability |
| `02_Few_Shot` | Few-shot | Reference snippets provided as style anchors before the main task |
| `03_Chain_of_Thought` | Chain-of-thought | Step-by-step reasoning required before code generation |
| `04_Role_Prompting` | Role prompting | Senior VLSI engineer persona with deliverable-oriented framing |
| `05_Instruction_Format` | Instruction + format | Strict output structure and module naming conventions |
| `06_Negative_Prompting` | Negative prompting | Explicit "do not" rules to avoid ripple-carry and other anti-patterns |
| `07_Constraints_First` | Constraints-first | Area, power, and timing (PPA) constraints stated before design |
| `08_Self_Planning` | Self-planning | Phased design plan (signals, critical path, PPA estimates) before RTL |
| `09_Iterative_Correction` | Iterative correction | Multi-pass refinement with annotated corrections |
| `10_Hybrid` | Hybrid | Combines role, planning, constraints, negative rules, and self-check |

## Simulation

Compile one folder at a time (module names may overlap across techniques):

```bash
iverilog -g2012 -o sim "Carry Lookahead Adder/GPT-5.5/Structural/01_Zero_Shot/carry_lookahead_adder.v"
vvp sim
```

## Source

All prompts and RTL were derived from `CARRY_LOOKAHEAD_ADDER.pdf`.
