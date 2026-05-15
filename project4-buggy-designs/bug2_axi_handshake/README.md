# Bug 2: AXI4-Lite response channel handshake violation

## Bug description
`bvalid` deasserted after 1 cycle regardless of `bready`.
AXI spec rule A3.2: a slave must hold `valid` high until
the corresponding `ready` is seen. Violating this causes
the master to miss the response — transaction hangs silently.

## Buggy behaviour
cycle 1: bvalid=1, bready=0  ← master not ready
cycle 2: bvalid=0            ← BUG: slave drops valid early
Master never sees bvalid=1 && bready=1. Transaction lost.

## Fix
In the RESP state, gate the `bvalid` deassertion on `bready`:
```systemverilog
// Buggy
bvalid <= 0;  // unconditional

// Fixed
if (bready) bvalid <= 0;  // only deassert after handshake
```

## Formal verification results
| File | Tool | Result | Detail |
|------|------|--------|--------|
| `axi_resp_buggy.sv` | BMC, depth 10 | FAIL | Counterexample at step 4 |
| `axi_resp_fixed.sv` | k-induction, depth 15 | PASS | Proved in <1 second |

## Property
```systemverilog
// AXI rule A3.2 — valid stable until handshake
if ($past(bvalid) && !$past(bready))
    assert(bvalid);
```

## Relevance
This class of bug appears in GPU fabric interconnects where
AXI response channels are heavily pipelined. A single missed
handshake can stall an entire memory transaction queue.
