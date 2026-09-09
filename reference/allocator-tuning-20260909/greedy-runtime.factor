USING: vocabs.loader ;
<< "compiler.cfg.register-allocation.greedy" reload >>
USING: accessors alien.c-types alien.syntax allocator-runtime-comparison arrays assocs
compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.value-numbering compiler.units
io json kernel locals math memory namespaces prettyprint sequences tools.test tools.time words ;
IN: allocator-greedy-runtime
LIBRARY: allocator-counters
FUNCTION: int compiler_foreground ( )
FUNCTION: int compiler_background ( )

: invoke-measured ( -- ) "native-measured-word" get execute( -- ) ;

:: runtime-sample ( trial -- )
    compiler_foreground 0 assert=
    gc
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ 600 [ invoke-measured ] times ] benchmark :> ns
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions before - :> retired
    compiler_background 0 assert=
    H{ } clone
    trial "trial" pick set-at
    600 "workload-iterations" pick set-at
    elapsed "cpu_seconds" pick set-at
    retired "instructions" pick set-at
    ns "ns" pick set-at
    >json print ;

f global-value-numbering? set-global
t rematerialize-constants? set-global
t backtracking-loop-spills? set-global
t check-allocation? set-global
t check-ssa? set-global
value-flow-verifier-enabled? t assert=
rematerialization-observer get >boolean t assert=
greedy-allocator register-allocator [
    { integer-pressure integer-pressure-work } compile
    \ integer-pressure "native-kernel-word" set
    32 <iota> [
        dup "native-kernel-word" get execute( x -- value )
        swap 40 * 820 + assert=
    ] each
    \ integer-pressure word-code swap - "CODE-BYTES " write .
    \ integer-pressure-work "native-measured-word" set
    -1 runtime-sample
    3 [ runtime-sample ] each-integer
] with-variable
