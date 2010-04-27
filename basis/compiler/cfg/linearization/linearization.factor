! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math accessors sequences namespaces make
combinators assocs arrays locals layouts hashtables
cpu.architecture generalizations
compiler.cfg
compiler.cfg.comparisons
compiler.cfg.stack-frame
compiler.cfg.instructions
compiler.cfg.utilities
compiler.cfg.linearization.order ;
IN: compiler.cfg.linearization

<PRIVATE

SYMBOL: numbers

: block-number ( bb -- n ) numbers get at ;

: number-blocks ( bbs -- ) [ 2array ] map-index >hashtable numbers set ;

GENERIC: linearize-insn ( basic-block insn -- )

M: insn linearize-insn , drop ;

: useless-branch? ( basic-block successor -- ? )
    ! If our successor immediately follows us in linearization
    ! order then we don't need to branch.
    [ block-number ] bi@ 1 - = ; inline

: emit-branch ( bb successor -- )
    2dup useless-branch? [ 2drop ] [ nip block-number _branch ] if ;

M: ##branch linearize-insn
    drop dup successors>> first emit-branch ;

GENERIC: negate-insn-cc ( insn -- )

M: conditional-branch-insn negate-insn-cc
    [ negate-cc ] change-cc drop ;

M: ##test-vector-branch negate-insn-cc
    [ negate-vcc ] change-vcc drop ;

M:: conditional-branch-insn linearize-insn ( bb insn -- )
    bb successors>> first2 :> ( first second )
    bb second useless-branch?
    [ bb second first ]
    [ bb first second insn negate-insn-cc ] if
    block-number insn _conditional-branch
    emit-branch ;

M: ##dispatch linearize-insn
    , successors>> [ block-number _dispatch-label ] each ;

: linearize-basic-block ( bb -- )
    [ block-number _label ]
    [ dup instructions>> [ linearize-insn ] with each ]
    bi ;

: linearize-basic-blocks ( cfg -- insns )
    [
        [
            linearization-order
            [ number-blocks ]
            [ [ linearize-basic-block ] each ] bi
        ] [ spill-area-size>> _spill-area-size ] bi
    ] { } make ;

PRIVATE>

: flatten-cfg ( cfg -- mr )
    [ linearize-basic-blocks ] [ word>> ] [ label>> ] tri
    <mr> ;
