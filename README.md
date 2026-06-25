# IntershipProject

Repository of **10 LLM prompt engineering strategies** applied to generate Verilog RTL from PDF prompt collections.

Each strategy is a self-contained `.sv` file: the **prompt** is in header comments, followed by **RTL** (structural, dataflow, behavioral where applicable) and a **testbench**.

## Repository structure

```
Ripple Carry Adder/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/

Carry Lookahead Adder/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/

Booth Multiplier/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/

Sign_adder/
Carry Select Adder/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/

Synchronous FIFO/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/

Magnitude Comparator/
├── GPT-5.5/
├── Behavioural/
│   ├── 01_Zero_Shot/ … 10_Hybrid/
├── Dataflow/
│   ├── 01_Zero_Shot/ … 10_Hybrid/
└── Structural/
    ├── 01_Zero_Shot/ … 10_Hybrid/

Shift Registor/
└── GPT-5.5/
    ├── Behavioural/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    ├── Dataflow/
    │   ├── 01_Zero_Shot/ … 10_Hybrid/
    └── Structural/
        ├── 01_Zero_Shot/ … 10_Hybrid/
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

## Ripple Carry Adder (16-bit RCA)

Generated from `RIPPLE_CARRY_ADDER.pdf`. Implementations are organized under `Ripple Carry Adder/GPT-5.5/` by architectural style:

| Section | Description |
|---------|-------------|
| Behavioural | Procedural always block with an integer-indexed for-loop generating the carry chain |
| Dataflow | Continuous assign statements inside a generate-for loop driving sum and carry |
| Structural | Hierarchical instantiation of 1-bit full_adder module 16 times inside a generate-for loop |

Each prompting folder contains `Prompt.txt` (the LLM prompt) and `ripple carry adder.v` (the generated RTL).

## Carry Lookahead Adder (16-bit CLA)

Generated from `CARRY_LOOKAHEAD_ADDER.pdf`. Implementations are organized under `Carry Lookahead Adder/GPT-5.5/` by architectural style:

| Section | Description |
|---------|-------------|
| Structural | Gate-level hierarchy with `pg_cell`, 4-bit CLA blocks, and explicit primitive gates |
| Dataflow | Pure `assign` carry lookahead equations with expanded inter-group carries |
| Behavioural | `always @(*)` procedural logic with grouped lookahead and overflow detection |

Each prompting folder contains `Prompt.txt` (the LLM prompt) and `carry_lookahead_adder.v` (the generated RTL).

## Booth Multiplier (16-bit Signed)

Generated from `Booth Multiplier Structural.pdf`, `Booth_multiplier_dataflow.pdf`, and `Radix-2 Booth Multiplier Behavioural.pdf`. The implementation is separated into folders based on the architectural style under `Booth Multiplier/GPT-5.5/`:

| Section | Description |
|---------|-------------|
| Structural | Gate-level hierarchy with explicit `booth_encoder`, `pp_gen`, and `adder32` instantiations |
| Dataflow | Pure continuous assignments (`assign`) for partial-product generation and summation |
| Behavioural | Procedural block implementations (`always`) for multiplication logic |

## Sign Adder (16-bit Signed)

Generated from `Sign_Adder_dataflow_16bit.docx`, `sign_adder_BEHAVIORAL_16bit.pdf`, and `sign_adder_structural_16bit.pdf`. The implementation is separated into folders based on the architectural style under `Sign_adder/GPT-5.5/`:

| Section | Description |
|---------|-------------|
| Structural | Gate-level hierarchy with 16 explicit `full_adder` sub-module instantiations |
| Dataflow | Pure continuous assignments (`assign`) for sign extension and summation |
| Behavioural | Procedural block implementations (`always @(*)`) handling two's complement and overflow logic |


## Carry Select Adder (16-bit)

Generated from `carry select adder_ structural2.pdf` and `carry_select_head_dataflow_behavioral.pdf`. The implementation is separated into folders based on the architectural style under `Carry Select Adder/GPT-5.5/`:

| Section | Description |
|---------|-------------|
| Structural | Gate-level hierarchy with explicit `full_adder`, `rca4`, and `mux2` instantiations |
| Dataflow | Pure continuous assignments (`assign`) for dual-candidate sums and carry-select mux |
| Behavioural | Procedural `always @(*)` implementations with if-else carry selection |

## Synchronous FIFO (16-bit)

Generated from `SYNCHRONOUS FIFO.pdf`. Implementations are organized under `Synchronous FIFO/GPT-5.5/` by architectural style:

| Section | Description |
|---------|-------------|
| Structural | Hierarchical `fifo_top` with explicit submodule instantiations for memory, control, and flags |
| Dataflow | Continuous `assign` flag and occupancy logic with explicit pointer algebra |
| Behavioural | Procedural `always` blocks for memory, pointers, and status registers |

Each prompting folder contains `Prompt.txt` (the LLM prompt) and `synchronous FIFO.v` (the generated RTL).

## Magnitude Comparator (16-bit)

Generated from prompt collections for magnitude comparators. The implementation is separated into folders based on the architectural style under `Magnitude Comparator/`:

| Section | Description |
|---------|-------------|
| Behavioural | Procedural block implementations (`always @(*)`) handling comparisons without inferred latches |
| Dataflow | Pure continuous assignments (`assign`) for greater than, less than, and equality checks |
| Structural | Gate-level hierarchy using `cmp1`, `cmp4`, and top-level `cmp16_structural` with multi-mode synthesis options |

Each prompting folder contains `Prompt.txt` (the LLM prompt) and `magnitude comparator.v` (the generated RTL).

## Shift Registor (16-bit Universal)

This project implements a 16-bit universal shift register targeting Xilinx Artix-7 FPGAs (specifically Nexys A7, xc7a100tcsg324-2) using three distinct Verilog styles and ten different LLM prompting techniques.

### Verilog Implementation Styles

- **Behavioural**: Procedural always block with an integer-indexed for-loop / while-loop generating the shifts.
- **Dataflow**: Continuous assign statements inside generate-for loops and 4-way multiplexers.
- **Structural**: Hierarchical instantiation of 16 `dff_ce` submodules connected via generate-for loops.

Each prompting folder contains `Prompt.txt` (the LLM prompt) and `Shift_Registor.v` (the generated RTL).

## Simulation

Compile **one file at a time** (module names overlap across strategies).

```bash
iverilog -g2012 -o sim "ripple carry adder/prompts/01_zero_shot.sv"
vvp sim
```
