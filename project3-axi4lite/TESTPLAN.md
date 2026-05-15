# FV Testplan — AXI4-Lite Slave

## 1. Design under verification
- **Module**: `axi4lite_slave`
- **Parameters**: DATA_WIDTH=32, ADDR_WIDTH=4, NUM_REGS=16
- **Description**: AXI4-Lite compliant slave with independent write
  (AW/W/B) and read (AR/R) channels, register file backed

## 2. Verification scope
Formal verification of AXI4-Lite protocol compliance and
internal FSM correctness. Simulation coverage is out of scope.

## 3. Interface assumptions (environment constraints)
| Signal | Assumption | Rationale |
|--------|-----------|-----------|
| `aresetn` | Held low at t=0 | AXI reset requirement |
| `awvalid` | Stable until `awready` | AXI handshake rule A3.2 |
| `wvalid`  | Stable until `wready`  | AXI handshake rule A3.2 |
| `arvalid` | Stable until `arready` | AXI handshake rule A3.2 |

## 4. Properties

### 4.1 Assertions (prove mode, k-induction, depth 20)
| ID | Property | Result |
|----|----------|--------|
| A1 | `bvalid` stable until `bready` | PASS |
| A2 | `rvalid` stable until `rready` | PASS |
| A3 | `bresp` always OKAY (2'b00) | PASS |
| A4 | `rresp` always OKAY (2'b00) | PASS |
| A5 | `rdata` stable while `rvalid` high, `rready` low | PASS |
| A6 | `bresp` stable while `bvalid` high, `bready` low | PASS |
| A7 | Write FSM outputs one-hot: awready/wready/bvalid | PASS |
| A8 | Read FSM outputs one-hot: arready/rvalid | PASS |
| A9 | FSM state ↔ output signal consistency | PASS |

### 4.2 Cover properties (cover mode, depth 30)
| ID | Property | Reached at step |
|----|----------|----------------|
| C1 | Write transaction completes (`bvalid&&bready`) | 5 |
| C2 | Read transaction completes (`rvalid&&rready`) | 5 |
| C3 | Write-then-read sequence to same address | 6 |
| C4 | Back-to-back write transactions (2 complete) | 10 |
| C5 | Read OKAY with `rdata` stable through handshake | 6 |

## 5. Tool configuration
| Item | Value |
|------|-------|
| Tool | SymbiYosys (OSS CAD Suite 2024-01-17) |
| Solver | Z3 |
| Prove depth | 20 cycles |
| Cover depth | 30 cycles |
| Technique | k-induction (basecase + induction) |

## 6. Results summary
- All 9 assertions **PASS** by k-induction in <1 second
- All 5 cover properties **REACHABLE** within 10 cycles
- No spurious counterexamples; assumptions are tight
- Design is formally proven AXI4-Lite compliant under stated assumptions
