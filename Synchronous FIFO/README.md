# Synchronous FIFO

This directory contains LLM-generated implementations of a **16-bit synchronous FIFO** extracted from `SYNCHRONOUS FIFO.pdf`. Each design targets the Nexys A7 FPGA (Xilinx Artix-7 `xc7a100tcsg324-2`) and is organized by model (`GPT-5.5`), RTL style, and prompting technique.

## Repository layout

```
Synchronous FIFO/
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
| `synchronous FIFO.v` | The generated Verilog implementation |

## RTL implementation styles

### Structural

Hierarchical RTL with explicit module instantiations. The top module (`fifo_top`) contains only wire declarations and submodule port maps. Typical hierarchy includes pointer increment logic, flag generation, memory storage, and control blocks built from instantiated primitives or leaf modules. Emphasizes clean separation of memory, control, and status logic for synthesis on FPGA.

### Dataflow

Continuous-assignment style using `assign` statements for combinational logic such as full/empty detection, occupancy count, and flag generation. Pointer updates and memory may still use clocked logic where required, but status equations are expressed as explicit Boolean dataflow. Highlights the FIFO pointer algebra and flag equations directly in RTL.

### Behavioural

Procedural RTL using `always` blocks for memory, pointers, and status registers. Uses `reg` arrays for storage and sequential pointer management with synchronous active-low reset. Often includes `almost_full` / `almost_empty` thresholds and occupancy `count`. Most readable for understanding FIFO control flow and simulation.

## Common specification

| Parameter | Value |
|-----------|-------|
| Data width | 16 bits |
| Depth | 16 entries |
| Address width | 4 bits |
| Pointer width | 5 bits (MSB = wrap bit) |
| Clock / reset | `clk`, active-low synchronous `rst_n` |
| Handshake | `wr_en`, `rd_en`, `full`, `empty` |
| Data ports | `din[15:0]`, `dout[15:0]` |
| Optional flags | `almost_full`, `almost_empty`, `count` |

## Prompting techniques

| Folder | Technique | Purpose |
|--------|-----------|---------|
| `01_Zero_Shot` | Zero-shot | Minimal instruction with no examples; tests baseline LLM RTL ability |
| `02_Few_Shot` | Few-shot | Reference snippets provided as style anchors before the main task |
| `03_Chain_of_Thought` | Chain-of-thought | Step-by-step pointer/flag reasoning required before code generation |
| `04_Role_Prompting` | Role prompting | Senior FPGA engineer persona with deliverable-oriented framing |
| `05_Instruction_Format` | Instruction + format | Strict output structure and module naming conventions |
| `06_Negative_Prompting` | Negative prompting | Explicit "do not" rules to avoid unsafe FIFO implementations |
| `07_Constraints_First` | Constraints-first | Timing, area, and power constraints stated before design |
| `08_Self_Planning` | Self-planning | Phased design plan (signals, critical path, PPA estimates) before RTL |
| `09_Iterative_Correction` | Iterative correction | Multi-pass refinement with annotated corrections |
| `10_Hybrid` | Hybrid | Combines role, planning, constraints, negative rules, and self-check |

## Simulation

Compile one folder at a time (module names may overlap across techniques):

```bash
iverilog -g2012 -o sim "Synchronous FIFO/GPT-5.5/Structural/01_Zero_Shot/synchronous FIFO.v"
vvp sim
```

## Source

All prompts and RTL were derived from `SYNCHRONOUS FIFO.pdf`.
