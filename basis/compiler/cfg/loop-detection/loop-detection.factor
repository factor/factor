! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit compiler.cfg
compiler.cfg.predecessors compiler.cfg.utilities deques dlists
kernel namespaces sequences sets ;
IN: compiler.cfg.loop-detection

TUPLE: natural-loop header index ends blocks ;

SYMBOL: loops

<PRIVATE

: <natural-loop> ( header index -- loop )
    HS{ } clone HS{ } clone natural-loop boa ;

: lookup-header ( header -- loop )
    loops get dup '[ _ assoc-size <natural-loop> ] cache ;

SYMBOLS: visited active ;

: record-back-edge ( from to -- )
    lookup-header ends>> adjoin ;

DEFER: find-loop-headers

: visit-edge ( from to active -- )
    dupd in?
    [ record-back-edge ]
    [ nip find-loop-headers ]
    if ;

: find-loop-headers ( bb -- )
    dup visited get ?adjoin [
        active get
        [ adjoin ]
        [ [ dup successors>> ] dip '[ _ visit-edge ] with each ]
        [ delete ]
        2tri
    ] [ drop ] if ;

: process-loop-block ( bb loop -- bbs )
    dupd { [ blocks>> ?adjoin ] [ header>> eq? not ] } 2&&
    swap predecessors>> { } ? ;

: process-loop-ends ( loop -- )
    dup ends>> members <dlist> [ push-all-front ] keep
    swap '[ _ process-loop-block ] slurp/replenish-deque ;

: process-loop-headers ( -- )
    loops get values [ process-loop-ends ] each ;

SYMBOL: loop-nesting

: compute-loop-nesting ( -- )
    loops get H{ } clone [
        [ values ] dip '[ blocks>> members [ _ inc-at ] each ] each
    ] keep loop-nesting namespaces:set ;

: detect-loops ( cfg -- cfg' )
    H{ } clone loops namespaces:set
    HS{ } clone visited namespaces:set
    HS{ } clone active namespaces:set
    H{ } clone loop-nesting namespaces:set
    [ needs-predecessors ]
    [ entry>> find-loop-headers process-loop-headers compute-loop-nesting ]
    [ ] tri ;

PRIVATE>

: loop-nesting-at ( bb -- n ) loop-nesting get at 0 or ;

: current-loop-nesting ( -- n ) basic-block get loop-nesting-at ;

: needs-loops ( cfg -- )
    dup needs-predecessors
    dup loops-valid?>> [ detect-loops t >>loops-valid? ] unless
    drop ;
