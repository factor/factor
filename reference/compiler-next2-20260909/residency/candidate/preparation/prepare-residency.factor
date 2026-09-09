USING: vocabs.loader ;
<< "compiler.cfg.register-allocation.chordal.spilling.residency" reload >>
USING: allocator-runtime-comparison memory namespaces ;
workloads benchmark-closure benchmark-words set-global
"reference/compiler-next-20260909/prepared.image" save-image-and-exit
