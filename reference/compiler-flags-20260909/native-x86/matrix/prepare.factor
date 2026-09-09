USING: vocabs.loader vocabs.refresh ;
<< "compiler.tree.propagation.info" reload
   "compiler.cfg.register-allocation.chordal.spilling.residency" reload
   refresh-all >>
USING: allocator-runtime-comparison assocs compiler.cfg.register-allocation
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
compiler.errors memory namespaces tools.test ;
linear-scan-allocator register-allocator set-global
f global-value-numbering? set-global
f rematerialize-constants? set-global
f backtracking-loop-spills? set-global
compiler-errors get assoc-size 0 assert=
workloads benchmark-closure benchmark-words set-global
"reference/compiler-flags-20260909/prepared.image" save-image-and-exit
