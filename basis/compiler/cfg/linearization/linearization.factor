! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg.loop-detection compiler.cfg.predecessors
compiler.cfg.rpo compiler.cfg.utilities deques dlists kernel
make math namespaces sequences sets sorting ;
IN: compiler.cfg.linearization

! This is RPO except loops are rotated and unlikely blocks go
! at the end. Based on SBCL's src/compiler/control.lisp

<PRIVATE

SYMBOLS: loop-heads visited ;

: visited? ( bb -- ? ) visited get in? ;

: predecessors-ready? ( bb -- ? )
    [ predecessors>> ] keep '[
        _ 2dup back-edge?
        [ 2drop t ] [ drop visited? ] if
    ] all? ;

: (find-alternate-loop-head) ( bb -- bb' )
    dup {
        [ predecessor visited? not ]
        [ predecessors>> length 1 = ]
        [ predecessor successors>> length 1 = ]
        [ [ number>> ] [ predecessor number>> ] bi > ]
    } 1&& [ predecessor (find-alternate-loop-head) ] when ;

: find-back-edge ( bb -- pred )
    [ predecessors>> ] keep '[ _ back-edge? ] find nip ;

: find-alternate-loop-head ( bb -- bb' )
    dup find-back-edge dup visited? [ drop ] [
        nip (find-alternate-loop-head)
    ] if ;

: sorted-successors ( bb -- seq )
    successors>> <reversed> [ loop-nesting-at ] sort-by ;

: process-block ( bb -- bbs )
    dup visited get ?adjoin [ dup , sorted-successors ] [ drop { } ] if
    [ predecessors-ready? ] filter
    [ dup loop-entry? [ find-alternate-loop-head ] when ] map
    [ visited? ] reject ;

: (linearization-order) ( cfg -- bbs )
    HS{ } clone visited namespaces:set
    entry>> <dlist> [ push-back ] keep
    [ dup '[ process-block _ push-all-back ] slurp-deque ] { } make ;

PRIVATE>

: linearization-order ( cfg -- bbs )
    {
        [ needs-post-order ]
        [ needs-loops ]
        [ needs-predecessors ]
        [
            [ linear-order>> ] [
                dup (linearization-order)
                >>linear-order linear-order>>
            ] ?unless
        ]
    } cleave ;

: number-blocks ( bbs -- )
    [ >>number drop ] each-index ;

: blocks>insns ( bbs -- insns )
    [ instructions>> ] map concat ;

: cfg>insns ( cfg -- insns )
    linearization-order blocks>insns ;

: cfg>insns-rpo ( cfg -- insns )
    reverse-post-order blocks>insns ;
