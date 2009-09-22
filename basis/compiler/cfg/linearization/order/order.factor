! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists kernel make sorting
namespaces sequences combinators combinators.short-circuit
fry math sets compiler.cfg.rpo compiler.cfg.utilities
compiler.cfg.loop-detection compiler.cfg.predecessors ;
IN: compiler.cfg.linearization.order

! This is RPO except loops are rotated. Based on SBCL's src/compiler/control.lisp

<PRIVATE

SYMBOLS: work-list loop-heads visited ;

: visited? ( bb -- ? ) visited get key? ;

: add-to-work-list ( bb -- )
    dup visited get key? [ drop ] [
        work-list get push-back
    ] if ;

: init-linearization-order ( cfg -- )
    <dlist> work-list set
    H{ } clone visited set
    entry>> add-to-work-list ;

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

: predecessors-ready? ( bb -- ? )
    [ predecessors>> ] keep '[
        _ 2dup back-edge?
        [ 2drop t ] [ drop visited? ] if
    ] all? ;

: process-successor ( bb -- )
    dup predecessors-ready? [
        dup loop-entry? [ find-alternate-loop-head ] when
        add-to-work-list
    ] [ drop ] if ;

: sorted-successors ( bb -- seq )
    successors>> <reversed> [ loop-nesting-at ] sort-with ;

: process-block ( bb -- )
    dup visited? [ drop ] [
        [ , ]
        [ visited get conjoin ]
        [ sorted-successors [ process-successor ] each ]
        tri
    ] if ;

: (linearization-order) ( cfg -- bbs )
    init-linearization-order

    [ work-list get [ process-block ] slurp-deque ] { } make ;

PRIVATE>

: linearization-order ( cfg -- bbs )
    needs-post-order needs-loops needs-predecessors

    dup linear-order>> [ ] [
        dup (linearization-order)
        >>linear-order linear-order>>
    ] ?if ;