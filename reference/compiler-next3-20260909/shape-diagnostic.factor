! Untimed source/physical-IR diagnostic. Static loop depth is not execution count.
USING: accessors allocator-runtime-comparison arrays assocs classes
compiler.cfg compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.loop-detection compiler.cfg.metrics compiler.cfg.rpo compiler.cfg.register-allocation
compiler.cfg.register-allocation.rematerialization compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.utilities compiler.cfg.value-numbering
io kernel locals namespaces prettyprint prettyprint.config sequences system words ;
IN: compiler-next3.shape
SYMBOLS: original-measure-pass current-target ;
<< \ measure-pass def>> \ original-measure-pass set-global >>
:: record-shape ( graph pass -- )
    graph f >>loops-valid? needs-loops
    graph [| bb |
        bb instructions>> [| insn |
            insn class-of name>> :> kind
            insn unparse :> ir
            H{ { "class" kind } { "ir" ir } }
        ] map :> instructions
        current-target get word-id :> target
        graph label>> unparse :> procedure
        pass name>> :> phase
        bb number>> :> number
        bb loop-nesting-at :> depth
        H{ { "kind" "static-block" }
           { "target" target }
           { "procedure" procedure }
           { "phase" phase }
           { "block" number }
           { "loop-depth" depth }
           { "instructions" instructions } } emit
    ] each-basic-block ;
USE: compiler-next3.shape
IN: compiler.cfg.metrics
:: measure-pass ( graph pass -- metrics )
    graph pass original-measure-pass get call( cfg pass -- metrics ) :> metrics
    pass name>> { "optimize-ssa" "select-representations" "insert-gc-checks" "allocate-registers" } member?
    [ graph pass record-shape ] when
    metrics ;
IN: compiler-next3.shape
: run-shapes ( -- )
    20 length-limit set 5 nesting-limit set
    linear-scan-allocator register-allocator set
    f global-value-numbering? set f rematerialize-constants? set f backtracking-loop-spills? set
    t check-ssa? set t check-allocation? set
    metric-workloads [| target |
        target current-target set
        target measure-compilation H{ } clone "code" "kind" pick set-at swap "report" pick set-at emit
    ] each
    "SHAPE-DIAGNOSTIC-COMPLETE: 12 targets" print ;
