USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.rematerialization compiler.cfg.value-numbering
compiler.test io kernel namespaces parser prettyprint sequences system words ;
<< "reference/allocator-speed-crossarch-20260908/workloads.factor" run-file
   "reference/allocator-speed-crossarch-20260908/pressure.factor" run-file >>
USE: allocator-runtime-comparison
backtracking-allocator register-allocator set-global
f global-value-numbering? set-global
t rematerialize-constants? set-global
t check-allocation? set-global
t check-ssa? set-global
value-flow-verifier-enabled? t assert=
{ ffi-pressure branch-pressure integer-pressure } [ measure-compilation . ] each
0.0 \ branch-pressure def>> compile-call 3672.0 assert=
17.0 \ branch-pressure def>> compile-call 16712.0 assert=
"PROFITABILITY-PROBE PASS" print
0 exit
