USING: parser vocabs vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh
"compiler.cfg.register-allocation.greedy" require
"compiler.cfg.register-allocation.backtracking" require
"compiler.cfg.register-allocation.chordal" require
"compiler.cfg.register-allocation.verifier" require
"compiler.cfg.register-allocation.verifier.rematerialization" require >>
! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.cfg compiler.cfg.def-use
compiler.cfg.build-stack-frame compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.linear-scan
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.numbering
compiler.cfg.linearization
compiler.cfg.register-allocation compiler.cfg.register-allocation.verifier
compiler.cfg.registers compiler.cfg.ssa.destruction compiler.cfg.utilities
compiler.codegen compiler.units cpu.architecture hashtables kernel layouts
locals make math math.libm math.order math.vectors namespaces sequences sets words ;
IN: allocator-baseline-gc-probe

: init-validation-representations ( -- )
    H{ } clone representations namespaces:set
    256 <iota> [ int-rep swap set-rep-of ] each
    tagged-rep 0 set-rep-of
    256 vreg-counter namespaces:set ;

:: compile-validation-cfg ( graph allocator -- word )
    graph cfg namespaces:set
    allocator register-allocator namespaces:set
    t check-allocation? namespaces:set
    t check-numbering? namespaces:set
    value-flow-verifier-enabled? [ ] [
        "Missing value-flow verifier" throw
    ] if
    graph allocate-registers
    graph build-stack-frame
    gensym [ graph generate ] dip
    [ associate >alist t t modify-code-heap ] keep ;

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
        V{ } clone H{ } clone gc-map boa ##call-gc,
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
        V{ } clone H{ } clone gc-map boa ##call-gc,
        16 13 9 ##sub, 16 D: 0 ##replace,
        ##epilogue, ##return,
    ] { } make 3 insns>block :> join
    entry left connect-bbs entry right connect-bbs
    left join connect-bbs right join connect-bbs
    entry block>cfg ;

USING: compiler.cfg.register-allocation.greedy compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.rematerialization
io prettyprint ;
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
[| allocator |
    { f t } [| enabled? |
        { [ <validation-moving-phi> ] [ <validation-moving-tagged-phi> ] }
        [| constructor |
            [
                enabled? rematerialize-constants? namespaces:set
                constructor call( -- graph ) allocator compile-validation-cfg
                check-validation-moving-phi t assert=
            ] with-scope
        ] each
    ] each
    allocator . "native moving raw/tagged phi OFF/ON passed" print
] each
