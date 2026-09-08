USING: vocabs.loader vocabs.refresh ;
<< "resource:reference/compiler-gvn-20260908/metrics-root" add-vocab-root "compiler" refresh >>
USING: benchmark.spectral-norm benchmark.nbody benchmark.fannkuch benchmark.binary-trees accessors alien alien.c-types alien.libraries alien.syntax arrays
assocs command-line compiler compiler.cfg.metrics compiler.cfg.value-numbering
compiler.cfg compiler.cfg.debugger compiler.cfg.finalization compiler.cfg.optimizer compiler.codegen compiler.units compiler.utilities io json kernel locals math memory namespaces sequences system
vocabs.refresh words ;
IN: compiler-gvn-measure
<< "compiler-counters" "/Users/erg/factor/reference/compiler-throughput-20260907/counters.dylib" cdecl add-library >>
LIBRARY: compiler-counters
FUNCTION: ulonglong compiler_instructions ( )
FUNCTION: double compiler_cpu_seconds ( )
: corpus ( -- words )
    {
        { "mismatch" "sequences" }
        { "rehash" "hashtables" }
        { "post-order" "compiler.cfg.rpo" }
        { "compute-def-use" "compiler.tree.def-use" }
        { "build-stack-frame" "compiler.cfg.build-stack-frame" }
        { "linear-scan" "compiler.cfg.linear-scan" }
        { "propagate" "compiler.tree.propagation" }
        { "build-tree" "compiler.tree.builder" }
        { "generate" "compiler.codegen" }
        { "spectral-norm" "benchmark.spectral-norm" }
        { "nbody" "benchmark.nbody" }
        { "fannkuch" "benchmark.fannkuch" }
        { "binary-trees-benchmark" "benchmark.binary-trees" }
    } [ first2 lookup-word ] map ;
: compile-body ( word -- )
    [ test-builder [ dup cfg set dup optimize-cfg dup finalize-cfg generate drop ] each ] with-scope ;

:: measure-word ( word -- )
    gc
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    word compile-body
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions before - :> instructions
    word measure-compilation :> report
    elapsed "compile-cpu-seconds" report set-at
    instructions "compile-instructions" report set-at
    report >json print flush ;
"compiler" refresh
command-line get first "global" = global-value-numbering? set
[ ] yield-hook set
corpus [ compile-body ] each
corpus [ measure-word ] each
