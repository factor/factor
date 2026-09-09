! Run only against the common prepared round-3 benchmark image.
! No refresh, new witness definitions, optimizer overrides, or timed batches.
! The caller records the exact executable/image/source provenance externally.
USING: allocator-runtime-comparison arrays assocs compiler
compiler-next3.benchmark compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.metrics
compiler.cfg.register-allocation compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.value-numbering compiler.errors compiler.units
compiler.utilities io kernel locals math math.parser namespaces
sequences strings system words ;
IN: compiler-next3.combined-corpus-check

: assert-combined-options ( -- )
    register-allocator get linear-scan-allocator assert=
    check-ssa? get t assert=
    check-allocation? get t assert=
    value-flow-verifier-enabled? t assert=
    global-value-numbering? get f assert=
    rematerialize-constants? get f assert=
    backtracking-loop-spills? get f assert=
    global-feature-options dup assoc-size 4 assert=
    values [ t assert= ] each ;

: selected-word-ids ( -- ids )
    benchmark-words get-global
    [ [ word-id ] [ number>string ] bi* "|" glue ] map-index ;

:: check-combined-corpus ( -- )
    linear-scan-allocator register-allocator set-global
    t check-ssa? set-global t check-allocation? set-global
    f global-value-numbering? set-global
    f rematerialize-constants? set-global
    f backtracking-loop-spills? set-global
    feature-options values [
        first2 swap lookup-word dup f eq? f assert=
        t swap set-global
    ] each
    assert-combined-options
    compiler-errors get assoc-size 0 assert=
    benchmark-runtime-workloads length 30 assert=
    benchmark-metric-workloads length 16 assert=
    benchmark-words get-global :> selected
    selected empty? f assert=
    benchmark-runtime-workloads benchmark-metric-workloads append
    [ selected member? t assert= ] each
    selected-word-ids :> scope
    global-feature-options :> features
    selected length :> selected-count
    H{
        { "kind" "scope" }
        { "expected-core" "020b74ce5d" }
        { "allocator" "linear-scan" }
        { "checked" t }
        { "words" scope }
        { "options" H{
            { "features" features }
            { "gvn" f }
            { "rematerialize_constants" f }
            { "backtracking_loop_spills" f }
            { "ssa_checks" t }
            { "interval_checks" t }
            { "final_value_flow_checks" t }
        } }
    } emit

    ! Compile the frozen selected sequence, including the selected typed
    ! witness methods. Do not reconstruct or replace the prepared closure.
    selected compile
    compiler-errors get assoc-size 0 assert=
    selected-word-ids scope assert=
    assert-combined-options
    H{ { "kind" "compile" } { "errors" 0 }
       { "selected-word-count" selected-count } } emit

    benchmark-metric-workloads [| target |
        target measure-compilation :> report
        report "procedures" of dup empty? f assert=
        [ "code-bytes" of 0 > t assert= ] each
        compiler-errors get assoc-size 0 assert=
        assert-combined-options
        target word-id :> id
        H{ { "kind" "code" } { "metric-word" id }
           { "report" report } } emit
    ] each

    ! Dynamic invocation uses the freshly installed selected closure. Work
    ! wrappers retain their independent assertions; printed results are
    ! recorded for comparison with the accepted all-OFF corpus outputs.
    benchmark-runtime-workloads [| word |
        word invoke :> output
        word word-id :> id
        H{ { "kind" "runtime" } { "word" id }
           { "iterations" 1 } { "output" output } } emit
    ] each
    compiler-errors get assoc-size 0 assert=
    selected-word-ids scope assert=
    assert-combined-options
    H{ { "kind" "complete" } { "metric-targets" 16 }
       { "runtime-workloads" 30 } { "compiler-errors" 0 } } emit
    "NEXT3 COMBINED CORPUS CHECK PASS" print ;

check-combined-corpus
0 exit
