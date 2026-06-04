# IntershipProject

Repository of **10 LLM prompt engineering strategies** applied to generate a **4-bit ripple carry adder** in Verilog (from `RIPPLEADDER_PROMPTS.pdf`).

Each strategy is a self-contained `.sv` file: the **prompt** is in header comments, followed by **RTL** and a **testbench**.

## Repository structure

```
ripple carry adder/
└── prompts/
    ├── 01_zero_shot.sv
    ├── 02_few_shot.sv
    ├── 03_chain_of_thought.sv
    ├── 04_role_prompting.sv
    ├── 05_instruction_format.sv
    ├── 06_negative_prompting.sv
    ├── 07_constraints_first.sv
    ├── 08_self_planning.sv
    ├── 09_iterative_correction.sv
    └── 10_hybrid.sv
```

## Prompt strategies

| # | File | Strategy |
|---|------|----------|
| 1 | `01_zero_shot.sv` | Zero-shot — minimal instruction |
| 2 | `02_few_shot.sv` | Few-shot — examples then task |
| 3 | `03_chain_of_thought.sv` | Chain-of-thought — step-by-step plan |
| 4 | `04_role_prompting.sv` | Role — senior VLSI engineer persona |
| 5 | `05_instruction_format.sv` | Instruction + strict output format |
| 6 | `06_negative_prompting.sv` | Negative — explicit “do not” rules |
| 7 | `07_constraints_first.sv` | Constraints-first — area/power/timing PPA |
| 8 | `08_self_planning.sv` | Self-planning — phased design plan |
| 9 | `09_iterative_correction.sv` | Iterative correction — `rca_4bit_iterative` |
| 10 | `10_hybrid.sv` | Hybrid — structural lower + behavioral upper bits |

## Simulation

Compile **one file at a time** (module names overlap across strategies except 9 and 10).

```bash
iverilog -g2012 -o sim "ripple carry adder/prompts/01_zero_shot.sv"
vvp sim
```
