! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs deques dlists kernel make
namespaces sequences combinators combinators.short-circuit
fry math sets compiler.cfg.rpo compiler.cfg.utilities ;
IN: compiler.cfg.linearization.order

! This is RPO except loops are rotated. Based on SBCL's src/compiler/control.lisp

<PRIVATE

SYMBOLS: work-list loop-heads visited numbers next-number ;

: visited? ( bb -- ? ) visited get key? ;

: add-to-work-list ( bb -- )
    dup visited get key? [ drop ] [
        work-list get push-back
    ] if ;

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

: assign-number ( bb -- )
    next-number [ get ] [ inc ] bi swap numbers get set-at ;

: process-block ( bb -- )
    {
        [ , ]
        [ assign-number ]
        [ visited get conjoin ]
        [ successors>> <reversed> [ process-successor ] each ]
    } cleave ;

PRIVATE>

: linearization-order ( cfg -- bbs )
    ! We call 'post-order drop' to ensure blocks receive their
    ! RPO numbers.
    <dlist> work-list set
    H{ } clone visited set
    H{ } clone numbers set
    0 next-number set
    [ post-order drop ]
    [ entry>> add-to-work-list ] bi
    [ work-list get [ process-block ] slurp-deque ] { } make ;

: block-number ( bb -- n ) numbers get at ;
