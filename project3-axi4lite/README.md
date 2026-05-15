# AXI4-Lite Slave — Formal Verification

Formally verified AXI4-Lite slave register file using SymbiYosys + Z3 SMT solver.

## Design
- AXI4-Lite compliant slave with 16x32-bit register file
- Independent write (AW/W/B) and read (AR/R) channel FSMs
- rdata latched at address capture for stability guarantee

## Properties Proved (k-induction, depth=20)
1. Master VALID stability — cannot deassert until READY seen (assume)
2. Slave VALID stability — bvalid/rvalid held until handshake complete
3. RESP always OKAY (2'b00) — no error responses
4. RDATA stable while rvalid high and rready low
5. BRESP stable while bvalid high and bready low
6. FSM output consistency — each output active only in correct state
7. Write channel one-hot — awready/wready/bvalid mutually exclusive
8. Read channel one-hot — arready/rvalid mutually exclusive

## Bug Found During Development
rdata was recomputed from regfile every cycle in RD_DATA state.
A concurrent write to the same address would silently corrupt rdata
mid-transaction — violating AXI stability rule. Fixed by latching
rdata once at address capture in RD_IDLE.

## Tools
- SymbiYosys — formal verification front-end
- Z3 — SMT solver backend
- OSS CAD Suite

## Run
```bash
sby -f axi4lite.sby
```
Expected: `DONE (PASS, rc=0)` — successful proof by k-induction.
