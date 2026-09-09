# GC and spill-boundary repairs

`3e38c333d8` moves backtracking's scheduled parallel register transitions into
paired SSA assignment. A transition at a phi pseudo-instruction now runs before
that instruction disappears. A transition at a GC point runs before the
instruction's generated save/GC/restore sequence. Every scheduled prefix must
be consumed. Late reload validation runs before transports are suppressed.
Only the prefix binding is restored after assignment; the newly produced phi
and edge maps remain available to the resolver.

The concrete failing word was `M\ ipv6 make-sockaddr`. Three phis preceded
`htons`; the former postpass dropped transitions at the second/third phi's
positions and later spilled stale registers into root slots. The repaired
native x86 probe passes all four rematerialization/loop-policy combinations
and 400 executed IPv6 construction/parse round trips. ARM tests also compile
the exact method and execute both port branches. The independent comparison
vocabulary retains the original/final native IR and execution logs.

`0f3c5628ba` repairs spill-tail expansion across a liveness hole. Native checked
compilation of `compiler.cfg.register-allocation.greedy:local-split-plan` under
backtracking found an input fragment `[424,425]` and a bundled result starting
at 425. The input's original range ended at 424, but a later disjoint range made
the old overall-end cap ineffective. The new cap uses the range containing the
last mandatory use. In paired assignment an end at 424 expires at late point
425: its store executes before the original instruction defines its result.
Raw synchronization splitting now preserves the original bound until trimming.
Checked bundle construction additionally rejects internal range overlap before
inserting that bundle into the disjoint occupancy index.

The ARM backtracking subtree, direct hole/synchronization regressions, and
exact `local-split-plan` compilation passed with SSA, interval and final-value
checks. The next native x86 full compilation closure passed (40 records,
26 workload outputs). These results precede the separately discovered hidden
callback return-pointer / whole-register-file Factor-call clobber repair;
final acceptance must include that repair and the stricter checker. They are
correctness results, not runtime performance measurements.
