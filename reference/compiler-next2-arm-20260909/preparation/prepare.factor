USING: vocabs.loader ;
<< "compiler.tree.propagation.info" reload
"compiler.cfg.register-allocation.chordal.spilling.residency" reload >>
USING: allocator-runtime-comparison memory namespaces ;
workloads benchmark-closure benchmark-words set-global
"reference/compiler-next2-20260909/prepared.image" save-image-and-exit
