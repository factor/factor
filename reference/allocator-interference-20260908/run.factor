USING: alien.syntax alien.c-types allocator-runtime-comparison accessors assocs command-line compiler
compiler.errors compiler.units compiler.utilities math memory compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.value-numbering kernel locals namespaces sequences threads tools.time
vocabs.loader ;
IN: allocator-runtime-comparison
USING: parser ;
LIBRARY: allocator-counters
FUNCTION: int compiler_background ( )
SYMBOL: background-yields
SYMBOL: all-yields
: record-policy ( -- )
    all-yields [ 1 + ] change-global
    compiler_background 0 > [ background-yields [ 1 + ] change-global ] when ;
command-line get second "baseline" = [
    "work/interference-perf/baseline-backtracking.factor" run-file
    "work/interference-perf/baseline-greedy.factor" run-file
] [
    "compiler.cfg.register-allocation.backtracking" reload
    "compiler.cfg.register-allocation.greedy" reload
] if
:: wait-foreground ( -- )
    0 :> attempts!
    [ compiler_background 0 > attempts 100 < and ] [
        100000000 sleep
        attempts 1 + attempts!
    ] while
    compiler_background 0 assert= ;
:: compile-sample ( trial -- )
    gc
    wait-foreground
    0 background-yields set-global
    0 all-yields set-global
    compiler_background :> background-before
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ benchmark-words get-global compile ] benchmark :> ns
    compiler-errors get assoc-size 0 assert=
    H{ } clone
    trial "trial" pick set-at
    background-before "background_before" pick set-at
    compiler_background "background_after" pick set-at
    background-yields get-global "background_yields" pick set-at
    all-yields get-global "all_yields" pick set-at
    ns "ns" pick set-at
    compiler_cpu_seconds cpu - "cpu_seconds" pick set-at
    compiler_instructions before - "instructions" pick set-at emit ;
command-line get first select-allocator
f check-allocation? namespaces:set
f check-ssa? namespaces:set
f global-value-numbering? namespaces:set
0 background-yields set-global
0 all-yields set-global
[ record-policy ] yield-hook namespaces:set
H{ } clone
benchmark-words get-global [ word-id ] map "scope" pick set-at emit
0 compile-sample
