# 4×4 Systolic Array — RTL Implementation

A fully pipelined **4×4 systolic array** for matrix multiplication, implemented in Verilog and verified with two test cases using Icarus Verilog.

---

## Architecture

The array consists of **16 Processing Elements (PEs)** arranged in a 4×4 grid.

- **Activations** (matrix A) flow **left → right**, one row per cycle
- **Weights** (matrix B) flow **top → down**, one column per cycle
- Each PE performs a **MAC (Multiply-Accumulate)** every clock cycle
- Data is fed using **diagonal skew** to align operands at each PE

```
         w_col0   w_col1   w_col2   w_col3
           ↓        ↓        ↓        ↓
a_row0 → PE_00 → PE_01 → PE_02 → PE_03
           ↓        ↓        ↓        ↓
a_row1 → PE_10 → PE_11 → PE_12 → PE_13
           ↓        ↓        ↓        ↓
a_row2 → PE_20 → PE_21 → PE_22 → PE_23
           ↓        ↓        ↓        ↓
a_row3 → PE_30 → PE_31 → PE_32 → PE_33
```

### Processing Element (PE) — `rtl/pe.v`

| Port    | Width  | Direction | Description                  |
|---------|--------|-----------|------------------------------|
| `clk`   | 1      | Input     | Clock                        |
| `rst_n` | 1      | Input     | Active-low synchronous reset |
| `en`    | 1      | Input     | Enable                       |
| `a_in`  | 8-bit  | Input     | Activation from left         |
| `w_in`  | 8-bit  | Input     | Weight from top              |
| `a_out` | 8-bit  | Output    | Activation passed right      |
| `w_out` | 8-bit  | Output    | Weight passed down           |
| `acc`   | 32-bit | Output    | Accumulated MAC result       |

---

## File Structure

```
systolic_array/
├── rtl/
│   ├── pe.v               # Processing Element (MAC unit)
│   └── systolic_4x4.v     # 4×4 array top-level
├── tb/
│   ├── tb_systolic.v      # Test 1: A × Identity = A
│   └── tb_systolic2.v     # Test 2: A × non-trivial B
├── model/
│   ├── golden_model.py    # Python golden reference (Test 1)
│   ├── golden_model2.py   # Python golden reference (Test 2)
│   └── test_vectors.txt   # Test input vectors
├── sim/
│   ├── systolic.vcd       # Waveform dump (Test 1)
│   └── systolic2.vcd      # Waveform dump (Test 2)
└── sim.out                # Compiled simulation binary
```

---

## Test Cases

### Test 1 — Identity Matrix (`tb_systolic.v`)
Computes **A × I** and verifies the output equals A.

```
A = [[1,  2,  3,  4 ],      B = Identity (4×4)
     [5,  6,  7,  8 ],
     [9,  10, 11, 12],
     [13, 14, 15, 16]]

Expected C = A
```

### Test 2 — Non-Trivial Matrix (`tb_systolic2.v`)
Computes **A × B** for a non-trivial sparse B matrix.

```
B = [[2, 0, 1, 0],
     [0, 3, 0, 1],
     [1, 0, 2, 0],
     [0, 1, 0, 3]]

Expected C = [[5,  10, 7,  14],
              [17, 26, 19, 30],
              [29, 42, 31, 46],
              [41, 58, 43, 62]]
```

**Result: 4/4 PASS on both test cases ✅**

---

## Simulation

### Prerequisites
- [Icarus Verilog](https://github.com/steveicarus/iverilog) (`iverilog`, `vvp`)
- [GTKWave](http://gtkwave.sourceforge.net/) (optional, for waveform viewing)
- OSS CAD Suite (recommended)

### Run Test 1
```bash
iverilog -o sim/systolic_sim tb/tb_systolic.v rtl/systolic_4x4.v rtl/pe.v
vvp sim/systolic_sim
```

### Run Test 2
```bash
iverilog -o sim/systolic2_sim tb/tb_systolic2.v rtl/systolic_4x4.v rtl/pe.v
vvp sim/systolic2_sim
```

### View Waveforms
```bash
gtkwave sim/systolic.vcd    # Test 1
gtkwave sim/systolic2.vcd   # Test 2
```

---

## Key Design Details

- **Data width:** 8-bit inputs (activations & weights), 32-bit accumulator output
- **Reset:** Active-low synchronous (`rst_n`)
- **Feed method:** Diagonal skew — data for row `i` is delayed by `i` cycles at input
- **Latency:** Results are valid after `N + N - 1 = 7` cycles of data feeding + pipeline drain
- **Tool:** Simulated with Icarus Verilog 10.3 under OSS CAD Suite

---

## What is a Systolic Array?

A systolic array is a hardware architecture used to accelerate matrix operations (like those in neural networks and DSP). Data rhythmically flows through a mesh of simple processing elements — similar to how blood pulses through the heart. This design is the foundation of Google's TPU (Tensor Processing Unit).
