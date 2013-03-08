! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators deques dlists fry kernel
namespaces sequences sets compiler.cfg compiler.cfg.predecessors ;
FROM: namespaces => set ;
IN: compiler.cfg.loop-detection

TUPLE: natural-loop header index ends blocks ;

SYMBOL: loops

<PRIVATE

: <natural-loop> ( header index -- loop )
    H{ } clone H{ } clone natural-loop boa ;

: lookup-header ( header -- loop )
    loops get [
        loops get assoc-size <natural-loop>
    ] cache ;

SYMBOLS: visited active ;

: record-back-edge ( from to -- )
    lookup-header ends>> conjoin ;

DEFER: find-loop-headers

: visit-edge ( from to -- )
    dup active get in?
    [ record-back-edge ]
    [ nip find-loop-headers ]
    if ;

: find-loop-headers ( bb -- )
    dup visited get in? [ drop ] [
        {
            [ visited get adjoin ]
            [ active get adjoin ]
            [ dup successors>> [ visit-edge ] with each ]
            [ active get delete ]
        } cleave
    ] if ;

SYMBOL: work-list

: process-loop-block ( bb loop -- )
    2dup blocks>> key? [ 2drop ] [
        [ blocks>> conjoin ] [
            2dup header>> eq? [ 2drop ] [
                drop predecessors>> work-list get push-all-front
            ] if
        ] 2bi
    ] if ;

: process-loop-ends ( loop -- )
    [ ends>> keys <dlist> [ push-all-front ] [ work-list set ] [ ] tri ] keep
    '[ _ process-loop-block ] slurp-deque ;

: process-loop-headers ( -- )
    loops get values [ process-loop-ends ] each ;

SYMBOL: loop-nesting

: compute-loop-nesting ( -- )
    loops get H{ } clone [
        [ values ] dip '[ blocks>> values [ _ inc-at ] each ] each
    ] keep loop-nesting set ;

: detect-loops ( cfg -- cfg' )
    needs-predecessors
    H{ } clone loops set
    HS{ } clone visited set
    HS{ } clone active set
    H{ } clone loop-nesting set
    dup entry>> find-loop-headers process-loop-headers compute-loop-nesting ;

PRIVATE>

: loop-nesting-at ( bb -- n ) loop-nesting get at 0 or ;

: current-loop-nesting ( -- n ) basic-block get loop-nesting-at ;

: needs-loops ( cfg -- cfg' )
    needs-predecessors
    dup loops-valid?>> [ detect-loops t >>loops-valid? ] unless ;
