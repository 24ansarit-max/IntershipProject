# Carry Select Adder (16-bit)

Repository of **10 LLM prompt engineering strategies** applied to generate Verilog RTL for a 16-bit Carry Select Adder (CSA) from PDF prompt collections.

Each strategy folder contains:
- `Prompt.txt` — the engineering prompt used to generate the design
- `carry_select_adder.v` — the synthesizable RTL implementation

Generated from `carry select adder_ structural2.pdf` and `carry_select_head_dataflow_behavioral.pdf`. Implementations are organized under `GPT-5.5/` by architectural style.

## Repository structure

```
Carry Select Adder/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/
```

## Architectural styles

### Structural implementation

Gate-level and module-instantiation RTL. A 16-bit CSA is built from explicit sub-modules:

- **full_adder** — XOR/AND/OR gate primitives
- **rca4** — 4-bit ripple-carry adder (chain of full adders)
- **mux2 / mux2_4b** — 2:1 multiplexers for sum and carry selection

Each 4-bit block (except block 0 in some variants) runs two RCAs in parallel with `cin=0` and `cin=1`. A mux selects the correct result once the incoming carry is known. Block 0 propagates the external `cin` directly; blocks 1–3 select based on the carry out of the previous block. This trades **2× area** for **shorter critical path** (~one RCA delay + mux per stage vs. 16-bit ripple carry).

PPA parameters (`DELAY_PS`, `AREA_UM2`, `POWER_UW`) and `specify` blocks annotate timing for synthesis and SDF back-annotation.

### Dataflow implementation

Pure continuous-assignment (`assign`) style with **no module instantiation** and **no `always` blocks**. Each 4-bit block computes:

1. `{cout_c0, sum_c0} = a_block + b_block` (carry-in = 0)
2. `{cout_c1, sum_c1} = a_block + b_block + 1` (carry-in = 1)
3. Ternary mux: `sum_block = carry_in ? sum_c1 : sum_c0`

All four blocks are explicitly unrolled. The carry chain runs `cin → carry_b0 → carry_b1 → carry_b2 → cout`. Synthesis maps assign statements to the same combinational netlist as structural RTL.

### Behavioural implementation

Procedural RTL using a **single `always @(*)`** block. For each 4-bit block:

1. Compute both candidates: `{c0, s0} = a + b` and `{c1, s1} = a + b + 1`
2. Select with `if/else` based on the block's carry-in

Intermediate values are declared as `reg` at module scope. Default assignments at the top of the `always` block prevent latch inference. This style is ideal for simulation reference models and readable golden-check implementations.

## CSA architecture summary

| Block | Bit range | Carry-in source |
|-------|-----------|-----------------|
| 0 | [3:0] | External `cin` |
| 1 | [7:4] | Carry out of block 0 |
| 2 | [11:8] | Carry out of block 1 |
| 3 | [15:12] | Carry out of block 2 |

`BLOCK_SIZE = 4` → 4 blocks × 2 candidate adders = 8 parallel 4-bit add paths + 3–4 mux stages.

## Prompt strategies

| # | Folder | Strategy |
|---|--------|----------|
| 1 | `01_Zero_Shot` | Zero-shot — minimal instruction |
| 2 | `02_Few_Shot` | Few-shot — examples then task |
| 3 | `03_Chain_of_Thought` | Chain-of-thought — step-by-step plan before code |
| 4 | `04_Role_Prompting` | Role — senior VLSI / synthesis engineer persona |
| 5 | `05_Instruction_Format` | Instruction + strict output format |
| 6 | `06_Negative_Prompting` | Negative — explicit "do not" rules |
| 7 | `07_Constraints_First` | Constraints-first — area/power/timing PPA targets |
| 8 | `08_Self_Planning` | Self-planning — phased design plan before RTL |
| 9 | `09_Iterative_Correction` | Iterative correction — skeleton → connectivity → PPA |
| 10 | `10_Hybrid` | Hybrid — combines role, constraints, CoT, format, and iteration |

## Simulation

Compile **one file at a time** (module names overlap across strategies).

```bash
iverilog -g2012 -o sim "Carry Select Adder/GPT-5.5/Structural/01_Zero_Shot/carry_select_adder.v"
vvp sim
```
