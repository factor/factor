! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.debugger
compiler.cfg.finalization compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.optimizer compiler.cfg.register-allocation
compiler.cfg.utilities compiler.codegen kernel
locals namespaces prettyprint sequences tools.time words ;
IN: compiler.cfg.metrics

ERROR: unrecognized-pass-pipeline word ;

! Read the production pass lists instead of maintaining a parallel pipeline.
! Fail explicitly if their shape changes; silently omitting a pass would
! make a compiler comparison meaningless.
:: pass-list ( word -- passes )
    word def>> :> definition
    definition length 2 = [
        definition first array?
        definition second \ apply-passes eq? and
    ] [ f ] if
    [ definition first ] [ word unrecognized-pass-pipeline ] if ;

:: cfg-metrics ( cfg -- metrics )
    cfg cfg>insns :> insns
    insns length :> instructions
    insns [ ##spill? ] count :> spills
    insns [ ##reload? ] count :> reloads
    insns [ ##copy? ] count :> copies
    cfg linearization-order length :> blocks
    cfg stack-frame>> [ spill-area-size>> ] [ 0 ] if* :> spill-bytes
    cfg stack-frame>> [ total-size>> ] [ 0 ] if* :> frame-bytes
    H{
        { "instructions" instructions } { "blocks" blocks }
        { "spills" spills } { "reloads" reloads } { "copies" copies }
        { "spill-bytes" spill-bytes } { "frame-bytes" frame-bytes }
    } ;

:: measure-pass ( cfg pass -- metrics )
    [ cfg pass execute( cfg -- ) ] benchmark :> ns
    cfg cfg-metrics :> metrics
    pass name>> "pass" metrics set-at
    ns "nanoseconds" metrics set-at
    metrics ;

:: measure-cfg ( procedure -- metrics )
    [
        procedure cfg set
        \ optimize-cfg pass-list \ finalize-cfg pass-list append
        [ procedure swap measure-pass ] map :> passes
        [ procedure generate ] benchmark :> ( code ns )
        ! generate returns parameter/literal/relocation/label tables, code
        ! bytes, and frame size. No generated code is installed here.
        4 code nth length :> code-bytes
        H{
            { "passes" passes }
            { "code-bytes" code-bytes }
            { "codegen-nanoseconds" ns }
        }
    ] with-scope ;

:: measure-compilation ( word/quot -- metrics )
    [
        [ word/quot test-builder ] benchmark :> ( cfgs ns )
        cfgs [ measure-cfg ] map :> procedures
        word/quot unparse :> input
        current-register-allocator unparse :> allocator
        H{
            { "input" input }
            { "allocator" allocator }
            { "frontend-nanoseconds" ns }
            { "procedures" procedures }
        }
    ] with-scope ;

:: compare-allocators ( word/quot allocators -- reports )
    allocators [| allocator |
        allocator register-allocator
        [ word/quot measure-compilation ] with-variable
    ] map ;
