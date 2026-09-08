! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.dominance compiler.cfg.instructions compiler.cfg.rpo
continuations kernel locals math namespaces sequences sets ;
IN: compiler.cfg.checker

ERROR: bad-successors ;

: check-successors ( bb -- )
    dup successors>> [ predecessors>> member-eq? ] with all?
    [ bad-successors ] unless ;

: check-cfg ( cfg -- )
    [ check-successors ] each-basic-block ;

! Unlike needs-predecessors, checking must not prune invalid phi inputs.
! Derive the expected edges independently, before computing dominance.
SYMBOL: check-ssa?

ERROR: bad-predecessors bb ;
ERROR: stale-cfg-order cfg ;
ERROR: misplaced-phi bb insn ;
ERROR: bad-phi-inputs bb insn ;
ERROR: duplicate-ssa-definition vreg ;
ERROR: undefined-ssa-use vreg bb ;
ERROR: non-dominating-ssa-use vreg bb ;
ERROR: ssa-pass-error word pass error ;

<PRIVATE

SYMBOLS: expected-predecessors ssa-definitions ;

:: collect-edges ( blocks -- )
    H{ } clone :> edges
    blocks [ V{ } clone swap edges set-at ] each
    blocks [| bb |
        bb successors>> [| successor | bb successor edges push-at ] each
    ] each
    edges expected-predecessors namespaces:set ;

:: check-block-phis ( bb -- )
    f :> non-phi?!
    bb instructions>> [| insn |
        insn ##phi? [
            non-phi? [ bb insn misplaced-phi ] when
            insn inputs>> keys bb expected-predecessors get at set=
            [ bb insn bad-phi-inputs ] unless
        ] [ t non-phi?! ] if
    ] each ;

:: collect-definitions ( bb -- )
    bb instructions>> [| insn index |
        insn defs-vregs [| vreg |
            vreg ssa-definitions get key?
            [ vreg duplicate-ssa-definition ] when
            bb index 2array vreg ssa-definitions get set-at
        ] each
    ] each-index ;

:: check-use ( vreg bb index -- )
    vreg ssa-definitions get at
    [ vreg bb undefined-ssa-use ] unless* first2 :> ( def-bb def-index )
    def-bb bb eq?
    [ def-index index < ] [ def-bb bb dominates? ] if
    [ vreg bb non-dominating-ssa-use ] unless ;

:: check-block-uses ( bb -- )
    bb instructions>> [| insn index |
        insn ##phi? [
            insn inputs>> [| pred vreg |
                vreg pred pred instructions>> length check-use
            ] assoc-each
        ] [ insn uses-vregs [ bb index check-use ] each ] if
    ] each-index ;

PRIVATE>

:: check-ssa ( cfg -- )
    [
        cfg clone :> checked
        checked cfg-changed
        checked reverse-post-order :> blocks
        cfg post-order>> [ blocks set= [ cfg stale-cfg-order ] unless ] when*
        blocks collect-edges
        blocks [ check-block-phis ] each
        cfg predecessors-valid?>> [
            blocks [| bb |
                bb predecessors>> bb expected-predecessors get at set=
                [ bb bad-predecessors ] unless
            ] each
        ] when
        H{ } clone ssa-definitions namespaces:set
        blocks [ collect-definitions ] each
        ! Analysis tables are dynamically scoped. Do not mark the original
        ! CFG cache valid for tables that disappear when this check returns.
        checked needs-dominance
        blocks [ check-block-uses ] each
    ] with-scope ;

:: checked-ssa-pass ( cfg pass -- )
    cfg pass execute( cfg -- )
    check-ssa? get [
        [ cfg check-ssa ]
        [ cfg word>> pass rot ssa-pass-error ] recover
    ] when ; inline
