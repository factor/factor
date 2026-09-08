USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: benchmark.spectral-norm benchmark.nbody benchmark.fannkuch benchmark.binary-trees accessors alien alien.c-types alien.libraries alien.syntax arrays
assocs command-line compiler compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.linear-scan.allocation.state compiler.cfg.value-numbering
compiler.cfg compiler.cfg.debugger compiler.cfg.finalization compiler.cfg.optimizer compiler.codegen compiler.units compiler.utilities io json kernel locals math memory namespaces sequences system tools.time
prettyprint vocabs vocabs.refresh words ;
IN: compiler-allocator-comparison
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
    check-allocation? get "allocation-checks" report set-at
    "compile" "phase" report set-at
    report >json print flush ;

: tree-workload ( -- n )
    20 [ 0 10 bottom-up-tree item-check ] replicate sum ;

: norm-workload ( -- x ) 100 spectral-norm ;

: runtime-words ( -- words ) { tree-workload norm-workload } ;

:: measure-runtime ( word -- )
    word execute( -- result ) drop
    5 [
        gc
        compiler_instructions :> before
        compiler_cpu_seconds :> cpu
        [ word execute( -- result ) ] benchmark :> ( result ns )
        compiler_cpu_seconds cpu - :> elapsed
        compiler_instructions before - :> instructions
        word unparse :> input
        current-register-allocator unparse :> allocator
        H{
            { "phase" "runtime" } { "input" input }
            { "allocator" allocator } { "result" result }
            { "nanoseconds" ns } { "cpu-seconds" elapsed }
            { "instructions" instructions }
        } >json print flush
    ] times ;

:: select-allocator ( name -- )
    name "linear-scan" =
    [ "compiler.cfg.register-allocation" ]
    [ "compiler.cfg.register-allocation." name append ] if :> vocab
    vocab require
    name "-allocator" append vocab lookup-word execute( -- allocator )
    register-allocator set ;

command-line get first select-allocator
"check" command-line get member? check-allocation? set
[ ] yield-hook set
"runtime-only" command-line get member? [
    corpus [ compile-body ] each
    corpus [ measure-word ] each
] unless
{ spectral-norm tree-workload norm-workload } compile
runtime-words [ measure-runtime ] each
