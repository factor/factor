USING: vocabs.loader ;
<< "classes.algebra" reload "compiler.cfg.register-allocation.greedy" reload "compiler.cfg.register-allocation.backtracking" reload "compiler.cfg.register-allocation.chordal" reload >>
USING: allocator-runtime-comparison memory namespaces ;
workloads benchmark-closure benchmark-words set-global
"reference/compiler-next-20260909/prepared.image" save-image-and-exit
