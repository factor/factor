! Complete frozen compiler/workload closure; no runtime workload timing here.
USING: alien.c-types alien.syntax allocator-runtime-comparison arrays assocs
command-line compiler.errors compiler.units compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites compiler.cfg.value-numbering
io kernel locals math.parser namespaces sequences tools.test tools.time words ;
IN: allocator-tuning-compile
LIBRARY: allocator-counters
FUNCTION: int compiler_foreground ( )
FUNCTION: int compiler_background ( )

:: compile-selected ( -- )
    command-line get first select-allocator
    f check-allocation? set
    f check-ssa? set
    f global-value-numbering? set
    t rematerialize-constants? set
    t backtracking-loop-spills? set
    benchmark-words get-global :> selected
    H{ } clone "scope" "kind" pick set-at
    command-line get first "allocator" pick set-at
    command-line get second "source" pick set-at
    selected [ [ word-id ] [ number>string ] bi* "|" glue ] map-index
    "words" pick set-at emit
    compiler_foreground 0 assert=
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ selected compile ] benchmark :> ns
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions before - :> retired
    compiler_background 0 assert=
    compiler-errors get assoc-size 0 assert=
    H{ } clone "compile" "kind" pick set-at
    ns "ns" pick set-at
    elapsed "cpu_seconds" pick set-at
    retired "instructions" pick set-at emit ;
compile-selected
