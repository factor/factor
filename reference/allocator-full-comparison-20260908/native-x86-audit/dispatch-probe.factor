USING: parser vocabs vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh
"compiler.cfg.register-allocation.chordal" require
"compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require
"reference/allocator-full-comparison-20260908/dispatch.factor" run-file >>
USING: allocator-full-dispatch-audit compiler.cfg compiler.cfg.debugger
compiler.cfg.optimizer compiler.cfg.finalization compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.linear-scan.allocation.state
compiler.cfg.value-numbering compiler.cfg.register-allocation.rematerialization io kernel kernel.private math namespaces prettyprint sequences ;
instrument-methods
"allocate-registers" "compiler.cfg.linear-scan.allocation" "policy:linear-scan-engine" instrument-policy
"assign-register" "compiler.cfg.linear-scan.allocation" "policy:linear-scan-choice" instrument-policy
"greedy-allocate-intervals" "compiler.cfg.register-allocation.greedy" "policy:greedy" instrument-policy
"backtracking-allocation" "compiler.cfg.register-allocation.backtracking" "policy:backtracking" instrument-policy
"spill-ssa" "compiler.cfg.register-allocation.chordal.spilling" "policy:chordal-pressure" instrument-policy
"assign-certified-colors" "compiler.cfg.register-allocation.chordal" "policy:chordal-colors" instrument-policy
f global-value-numbering? set
f rematerialize-constants? set
t check-allocation? set
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
[ dup . register-allocator set
  begin-body-audit
  [ { fixnum fixnum } declare + ] test-builder
  [ dup cfg set dup optimize-cfg finalize-cfg ] each
  print-body-audit
] each
