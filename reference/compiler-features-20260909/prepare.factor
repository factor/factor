USING: vocabs.loader vocabs.refresh memory namespaces parser ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
<< "reference/allocator-speed-crossarch-20260908/workloads.factor" run-file
"reference/allocator-speed-crossarch-20260908/pressure.factor" run-file >>
IN: allocator-runtime-comparison
workloads benchmark-closure benchmark-words set-global
"reference/compiler-features-20260909/prepared.image" save-image-and-exit
