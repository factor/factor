USING: vocabs.refresh ;
<< "compiler" refresh >>
USING: accessors arrays assocs benchmark.spectral-norm benchmark.nbody
benchmark.fannkuch benchmark.binary-trees compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.linear-scan.allocation.state compiler.utilities io json kernel locals math
namespaces sequences words ;
IN: compiler-greedy-measure

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

t check-allocation? set-global
[ ] yield-hook set
{ linear-scan-allocator greedy-allocator } [| allocator |
    allocator register-allocator [
        corpus [ measure-compilation drop ] each
        3 [| iteration |
            corpus [| word |
                word measure-compilation
                iteration "iteration" pick set-at >json print flush
            ] each
        ] each-integer
    ] with-variable
] each
