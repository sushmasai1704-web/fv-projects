# Bug 3: FSM missing default — illegal state reachable

## Bug description
A 2-bit state register encodes 3 states (IDLE/WORK/DONE) but
has no `default` clause. State `2'b11` is unhandled — outputs
float and the FSM never recovers. Simulation almost never
catches this; it requires forcing the state register directly.

## Buggy behaviour
state = 2'b11 (illegal):
grant = undefined
busy  = undefined
next state = undefined — FSM stuck
## Fix
Add a `default` clause that drives outputs to safe values
and recovers state to IDLE:
```systemverilog
// Buggy: no default
// Fixed:
default: begin
    grant <= 0;
    busy  <= 0;
    state <= IDLE;
end
```

## Induction strengthening required
The fixed design needed invariant assumptions on `grant` and
`busy` to help k-induction. Without them, the prover imagines
`state=IDLE` with `grant=1` — unreachable from reset but not
ruled out by the FSM alone. Adding:
```systemverilog
assume(grant == (state == WORK));
assume(busy  == (state == WORK));
```
constrains the inductive step to reset-reachable states only.

## Formal verification results
| File | Tool | Result | Detail |
|------|------|--------|--------|
| `fsm_buggy.sv` | k-induction, depth 10 | FAIL | Step 3, 2 assertions |
| `fsm_fixed.sv` | k-induction, depth 10 | PASS | Proved in <1 second |

## Properties
```systemverilog
assert(state == IDLE || state == WORK || state == DONE);
assert(grant == (state == WORK));
assert(busy  == (state == WORK));
cover(state == IDLE && $past(state) == DONE);
```

## Relevance
Missing FSM defaults are common in GPU control logic where
state encodings are dense and synthesis tools may not warn.
Formal catches the illegal state exhaustively; simulation
requires explicit state-forcing which is rarely done.
