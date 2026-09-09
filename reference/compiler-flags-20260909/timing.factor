USING: alien.syntax alien.c-types command-line compiler.units compiler.errors compiler.utilities compiler.cfg.checker compiler.cfg.linear-scan.allocation.state compiler.cfg.value-numbering arrays assocs io json kernel locals math memory namespaces sequences tools.time math.parser words compiler.cfg.metrics ;
IN: allocator-runtime-comparison
LIBRARY: allocator-counters
FUNCTION: int compiler_foreground ( )
FUNCTION: int compiler_background ( )
CONSTANT: batch-counts H{
    { "allocator-runtime-comparison:norm-work" 14 }
    { "allocator-runtime-comparison:nbody-work" 2 }
    { "allocator-runtime-comparison:nbody-simd-work" 28 }
    { "allocator-runtime-comparison:trees-work" 2 }
    { "allocator-runtime-comparison:fannkuch-work" 5 }
    { "allocator-runtime-comparison:sieve-work" 2 }
    { "allocator-runtime-comparison:pi-work" 4 }
    { "allocator-runtime-comparison:md5-work" 4 }
    { "allocator-runtime-comparison:sha1-work" 3 }
    { "allocator-runtime-comparison:base64-work" 7 }
    { "allocator-runtime-comparison:base32-work" 1 }
    { "benchmark.csv:csv-benchmark" 4 }
    { "allocator-runtime-comparison:json-work" 2 }
    { "benchmark.msgpack:msgpack-benchmark" 1 }
    { "benchmark.lcs:lcs-benchmark" 1 }
    { "benchmark.tuple-arrays:tuple-arrays-benchmark" 1 }
    { "allocator-runtime-comparison:struct-work" 27 }
    { "allocator-runtime-comparison:matrix-work" 1 }
    { "allocator-runtime-comparison:matrix-simd-work" 29 }
    { "allocator-runtime-comparison:gc-work" 9 }
    { "allocator-runtime-comparison:float-pressure-work" 600 }
    { "allocator-runtime-comparison:ffi-pressure-work" 600 }
    { "allocator-runtime-comparison:branch-pressure-work" 600 }
    { "allocator-runtime-comparison:integer-pressure-work" 600 }
    { "allocator-runtime-comparison:simd-pressure-work" 600 }
    { "allocator-runtime-comparison:gc-pressure-work" 1 }
}
:: invoke-batch ( word iterations -- output )
    f :> output!
    iterations [
        word invoke
        output [ dup output assert= ] when
        output!
    ] times output ;
:: sample ( word trial -- )
    word word-id batch-counts at :> iterations
    compiler_foreground 0 assert=
    gc
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ word iterations invoke-batch ] benchmark :> ( output ns )
    compiler_background :> background
    compiler_cpu_seconds cpu - :> elapsed
    compiler_instructions before - :> instructions
    background 0 = [
    H{ } clone
    "runtime" "kind" pick set-at
    word word-id "word" pick set-at
    trial "trial" pick set-at
    iterations "iterations" pick set-at
    output "output" pick set-at
    ns "ns" pick set-at
    elapsed "cpu_seconds" pick set-at
    instructions "instructions" pick set-at emit
    ] [
        H{ } clone "retry" "kind" pick set-at
        word word-id "word" pick set-at
        trial "trial" pick set-at
        "background policy changed during sample" "reason" pick set-at emit
        word trial sample
    ] if ;
:: optional-flag ( index name vocab -- enabled )
    command-line get :> args
    args length index > [ index args nth "on" = ] [ f ] if :> enabled
    name vocab lookup-word :> key
    key [ enabled key namespaces:set ] [ enabled f assert= ] if
    enabled ;
:: main ( -- )
    command-line get first :> allocator
    command-line get second "check" = :> checked
    allocator select-allocator
    3 "rematerialize-constants?" "compiler.cfg.register-allocation.rematerialization" optional-flag :> rematerialize
    4 "backtracking-loop-spills?" "compiler.cfg.register-allocation.spill-sites" optional-flag :> loop-spills
    checked check-allocation? namespaces:set
    checked check-ssa? namespaces:set
    6 "global-value-numbering?" "compiler.cfg.value-numbering" optional-flag :> requested-gvn
    global-value-numbering? get :> gvn
    requested-gvn gvn assert=
    [ compiler_foreground 0 assert= ] yield-hook namespaces:set
    benchmark-words get-global :> selected
    H{ } clone "scope" "kind" pick set-at
    allocator "allocator" pick set-at
    command-line get dup length 5 > [ 5 swap nth ] [ drop "unrecorded" ] if "source" pick set-at
    checked "checked" pick set-at
    H{ { "rematerialize_constants" rematerialize }
       { "backtracking_loop_spills" loop-spills } { "gvn" gvn } } "options" pick set-at
    selected [ [ word-id ] [ number>string ] bi* "|" glue ] map-index "words" pick set-at emit
    compiler_foreground 0 assert=
    compiler_instructions :> before
    compiler_cpu_seconds :> cpu
    [ selected compile ] benchmark :> ns
    compiler-errors get assoc-size 0 assert=
    H{ } clone "compile" "kind" pick set-at
    ns "ns" pick set-at
    compiler_cpu_seconds cpu - "cpu_seconds" pick set-at
    compiler_instructions before - "instructions" pick set-at emit
    metric-workloads [ measure-compilation H{ } clone "code" "kind" pick set-at swap "report" pick set-at emit ] each
    workloads [| word | word -1 sample ] each
    checked [ ] [ command-line get third string>number [| trial | workloads [| word | word trial sample ] each ] each-integer ] if ;
main
