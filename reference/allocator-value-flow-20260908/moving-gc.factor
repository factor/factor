! Standalone native regression: original object identity must survive GC.
USING: vocabs.loader vocabs.refresh ;
<< { "compiler.cfg.register-allocation" "compiler.cfg.liveness"
     "compiler.cfg.ssa.destruction" "compiler.cfg.ssa.interference.live-ranges" "compiler.cfg.linear-scan.allocation.spilling"
     "compiler.cfg.linear-scan.numbering" "compiler.cfg.linear-scan.assignment"
     "compiler.cfg.linear-scan.resolve" } [ reload ] each >>
USING: accessors arrays assocs compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.registers compiler.cfg.utilities compiler.codegen compiler.units
hashtables kernel locals namespaces prettyprint sequences tools.test words ;
IN: allocator-moving-gc-regression

:: compile-moving-root ( allocator -- word )
    H{ { 0 tagged-rep } { 1 int-rep } { 2 int-rep } { 3 int-rep } }
    clone representations set
    4 vreg-counter set
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##tagged>integer { dst 1 } { src 0 } }
        T{ ##save-context { temp1 2 } { temp2 3 } }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##replace { src 1 } { loc D: 0 } }
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map insns>cfg :> graph
    graph cfg set
    allocator register-allocator set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

:: compile-moving-offset ( allocator -- word )
    H{ { 0 tagged-rep } { 1 int-rep } { 2 int-rep }
       { 3 int-rep } { 4 int-rep } { 5 int-rep } }
    clone representations set
    6 vreg-counter set
    {
        T{ ##prologue }
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##tagged>integer { dst 1 } { src 0 } }
        T{ ##add-imm { dst 2 } { src1 1 } { src2 16 } }
        T{ ##save-context { temp1 3 } { temp2 4 } }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##sub-imm { dst 5 } { src1 2 } { src2 16 } }
        T{ ##replace { src 5 } { loc D: 0 } }
        T{ ##epilogue }
        T{ ##return }
    } [ clone ] map insns>cfg :> graph
    graph cfg set
    allocator register-allocator set
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;


{
    linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator
} [| allocator |
    [
        t check-allocation? set
        allocator compile-moving-root :> plain
        allocator compile-moving-offset :> offset
        20 <iota> [ 1array dup plain execute( x -- x ) eq? ] all? :> plain-ok
        20 <iota> [ 1array dup offset execute( x -- x ) eq? ] all? :> offset-ok
        allocator plain-ok offset-ok 3array .
        plain-ok offset-ok and t assert=
    ] with-scope
] each
