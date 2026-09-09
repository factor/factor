# Ordinary backtracking entry transports

Baseline `c1f7e4d34c`; production/tests/docs `784a05ead7`. Assets are clones
of `allocator-tuning-final-candidate/{factor,libfactor.dylib,
full-tuning-default.factor.image}`, with explicit resource path, `refresh-all`
and `-no-user-init`. Root/default assets remain unchanged. ARM correctness
runs used CPU slots assigned by the comparison agent; no timing claims are
made from these instrumented probes.

A register fragment reloaded at ordinary block entry used to publish its
spill slot as the incoming destination. A predecessor holding that original
value in a register therefore stored it, and the successor immediately
reloaded it. The change publishes the allocated register and lets shared SSA
parallel edge resolution supply each predecessor's actual register or memory
value. It only applies to original live-ins at exact entry with slot reloads,
nonempty all-nonkill predecessors, nonkill successors, and non-phi/non-GC/
non-clobber first instructions. All outgoing spill obligations remain intact.

The same-source FFI probe replaces only `reify-entry-transports` with a no-op
for its `off` run. Both runs compile the selected `ffi-pressure` word through
public backtracking with SSA, interval, final-value and rematerialization
checks, then execute the frozen 32,000-call numerical oracle. Both pass.

| ARM FFI metric | Off | On |
|---|---:|---:|
| Delegated entry reloads | 0 | 2 |
| Final spills | 60 | 56 |
| Final reloads | 57 | 55 |
| Final copies | 20 | 20 |
| Final CFG blocks | 8 | 6 |
| Code bytes | 1344 | 1312 |
| Frame / spill bytes | 304 / 280 | 304 / 280 |

Other allocation counters match. The redundant edge blocks disappear along
with the store/reload round trips. The final backtracking subtree run passes
with zero failures, strict checks enabled, rematerialization on and optional
loop placement off. Added tests include mixed register/memory predecessors
with a simultaneous register swap, a deleted-required-copy mutation, mixed
kill-predecessor and phi/GC/ABI/non-live-in exclusions, and native three-register
distinct-phi loops with zero through seventeen iterations and a GC backedge.

Reproduction from this checkout (with architecture-matched counter library):

```
./factor -i=ABS/next.factor.image -resource-path=ABS -no-user-init \
  reference/compiler-next-backtracking-20260909/ffi-entry-probe.factor off
./factor -i=ABS/next.factor.image -resource-path=ABS -no-user-init \
  reference/compiler-next-backtracking-20260909/ffi-entry-probe.factor on
./factor -i=ABS/next.factor.image -resource-path=ABS -no-user-init \
  reference/allocator-tuning-backtracking-20260909/checked-tests.factor backtracking on off
```

The independent native runtime/retired-instruction pair and broader combined
acceptance remain pending. Static reductions alone are not a runtime claim.
