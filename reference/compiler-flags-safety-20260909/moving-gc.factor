! Fresh SSA graphs exercise value-numbering before allocation in every flag configuration.
USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.chordal compiler.cfg.registers compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables kernel locals make math
io namespaces prettyprint sequences words
compiler.cfg.checker compiler.cfg.value-numbering
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization tools.test system ;
IN: allocator-derived-phi-gc-probe

: init-validation-representations ( -- )
    H{ } clone representations namespaces:set
    256 <iota> [ int-rep swap set-rep-of ] each
    tagged-rep 0 set-rep-of
    256 vreg-counter namespaces:set ;

:: <validation-moving-phi> ( -- graph )
    init-validation-representations
    tagged-rep 1 set-rep-of tagged-rep 2 set-rep-of
    [
        ##prologue,
        0 D: 2 ##peek, 1 D: 1 ##peek, 2 D: 0 ##peek,
        3 2 ##tagged>integer,
        3 0 cc> ##compare-integer-imm-branch,
    ] { } make 0 insns>block :> entry
    [
        4 0 ##tagged>integer, 5 4 16 ##add-imm,
        10 16 ##load-integer, ##branch,
    ] { } make 1 insns>block :> left
    [
        6 1 ##tagged>integer, 7 6 32 ##add-imm,
        11 32 ##load-integer, ##branch,
    ] { } make 2 insns>block :> right
    [
        8 H{ { left 5 } { right 7 } } ##phi,
        9 H{ { left 10 } { right 11 } } ##phi,
        14 15 ##save-context,
        12 8 9 ##sub,
        12 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> join
    entry left connect-bbs entry right connect-bbs
    left join connect-bbs right join connect-bbs
    entry block>cfg ;

:: check-validation-moving-phi ( word -- ? )
    12 <iota> [| seed |
        { -1 1 } [| flag |
            seed 1array seed 100 + 1array flag
            word execute( a b flag -- a b result ) :> ( a b result )
            result flag 0 > a b ? eq?
        ] all?
    ] all? ;

:: <validation-moving-tagged-phi> ( -- graph )
    init-validation-representations
    tagged-rep 1 set-rep-of tagged-rep 2 set-rep-of tagged-rep 8 set-rep-of
    [
        ##prologue,
        0 D: 2 ##peek, 1 D: 1 ##peek, 2 D: 0 ##peek,
        3 2 ##tagged>integer,
        3 0 cc> ##compare-integer-imm-branch,
    ] { } make 0 insns>block :> entry
    [ 10 16 ##load-integer, ##branch, ] { } make 1 insns>block :> left
    [ 11 32 ##load-integer, ##branch, ] { } make 2 insns>block :> right
    [
        8 H{ { left 0 } { right 1 } } ##phi,
        9 H{ { left 10 } { right 11 } } ##phi,
        12 8 ##tagged>integer, 13 12 9 ##add,
        14 15 ##save-context,
        16 13 9 ##sub, 16 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> join
    entry left connect-bbs entry right connect-bbs
    left join connect-bbs right join connect-bbs
    entry block>cfg ;

! The save-context marks the insertion point; run GVN before adding the GC
! call, matching the production optimizer/GC-check ordering. Keep the marker
! identity through value numbering, then materialize the collector call.
: insert-moving-collection ( graph -- )
    [
        dup instructions>> [ [
            dup , ##save-context? [
                V{ } clone H{ } clone gc-map boa ##call-gc,
            ] when
        ] each ] V{ } make >>instructions drop
    ] each-basic-block ;

:: compile-moving-probe ( graph allocator -- word )
    graph cfg set allocator register-allocator set t check-allocation? set
    graph \ value-numbering checked-ssa-pass
    graph insert-moving-collection
    graph allocate-registers graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

t check-allocation? set-global
t check-ssa? set-global
f restartable-tests? set-global
t backtracking-loop-spills? set-global
value-flow-verifier-enabled? t assert=
{ f t } [
    dup global-value-numbering? set-global
    "moving GC GVN=" write .
{ f t } [
    dup rematerialize-constants? set-global
    "moving GC rematerialization=" write .

{
    linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator
} [| allocator |
    [
        <validation-moving-tagged-phi> allocator compile-moving-probe
        check-validation-moving-phi :> tagged-ok
        <validation-moving-phi> allocator compile-moving-probe
        check-validation-moving-phi :> derived-ok
        allocator tagged-ok derived-ok 3array .
        tagged-ok derived-ok and t assert=
    ] with-scope
] each

] each
] each
test-failures get empty? t assert=
"MOVING-GC-MATRIX-COMPLETE: 16 configurations, 768 native answers" print
0 exit
