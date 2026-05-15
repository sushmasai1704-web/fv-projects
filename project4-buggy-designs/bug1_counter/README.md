# Bug 1: Saturating Counter — Off-by-One in Saturation Check

## Bug Description
Saturating counter with `MAX=200` contained an off-by-one error in the
increment saturation guard:

```systemverilog
// BUGGY
if (count < MAX + 1)   // allows count to reach 201 — exceeds MAX
    count <= count + 1;

// FIXED
if (count < MAX)       // correctly saturates at 200
    count <= count + 1;
```

## How FV Found It
- BMC (depth 15 from reset): PASS — bug unreachable in 15 steps
- Induction with `assume(count <= MAX+2)`: FAIL in step 0
  - Solver started with count=200, applied inc=1, reached count=201
  - Violated `assert(count <= MAX)`

## Key Lesson: Induction Strengthening
Plain BMC couldn't find this bug without 201+ steps (impractical).
Adding `assume(count <= MAX+2)` as a **strengthening invariant** told
the induction engine to explore boundary states, exposing the bug
in 1 second instead of 40+ minutes.

## Properties Proved on Fixed Design
1. count never exceeds MAX
2. Correct increment below MAX
3. Correct decrement above 0
4. Saturates at MAX (no overflow)
5. Saturates at 0 (no underflow)
6. Simultaneous inc+dec = no change

## Files
- `counter_buggy.sv` — original buggy design
- `counter_fixed.sv` — fixed design (one character change)
- `counter.sby` — SymbiYosys configuration
