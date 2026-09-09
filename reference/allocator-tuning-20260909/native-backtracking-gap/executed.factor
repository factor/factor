USING: vocabs.loader ;
<< "compiler.cfg.register-allocation.backtracking" reload >>
USING: accessors alien.c-types alien.syntax allocator-runtime-comparison arrays assocs
compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.value-numbering compiler.units
io json kernel locals math memory namespaces prettyprint sequences tools.test tools.time words ;
IN: allocator-backtracking-ffi-runtime
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
backtracking-allocator register-allocator [
    { ffi-pressure ffi-pressure-work } compile
    \ ffi-pressure "native-kernel-word" set
    32 <iota> [
        >float dup "native-kernel-word" get execute( x -- value )
        swap [ dup * 16.0 * ] [ 530.0 * ] bi + 3675.0 + assert=
    ] each
    \ ffi-pressure word-code swap - "CODE-BYTES " write .
    \ ffi-pressure-work "native-measured-word" set
    -1 runtime-sample
    3 [ runtime-sample ] each-integer
] with-variable
