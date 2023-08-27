! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs binary-search
classes combinators kernel make math math.order sequences
sequences.private sorting specialized-arrays ;
SPECIALIZED-ARRAY: uint
IN: interval-sets
! Sets of positive integers

! Intervals are a pair of { start end }
TUPLE: interval-set { array uint-array read-only } ;

: interval-in? ( key set -- ? )
    interval-set check-instance array>>
    dupd [ <=> ] with search swap [
        even? [ >= ] [ 1 - <= ] if
    ] [ 2drop f ] if* ;

<PRIVATE

: spec>pairs ( sequence -- intervals )
    [ dup number? [ dup 2array ] when ] map ;

: disjoint? ( node1 node2 -- ? )
    [ second-unsafe ] [ first-unsafe ] bi* < ;

: (delete-redundancies) ( seq -- )
    dup length {
        { 0 [ drop ] }
        { 1 [ % ] }
        [
            drop dup first2 <
            [ unclip-slice , ]
            [ 2 tail-slice ] if
            (delete-redundancies)
        ]
    } case ;

: delete-redundancies ( seq -- seq' )
    ! If the next element is >= current one, leave out both
    [ (delete-redundancies) ] uint-array{ } make ;

: make-intervals ( seq -- interval-set )
    uint-array{ } like
    delete-redundancies
    interval-set boa ;

: >intervals ( seq -- seq' )
    [ 1 + ] assoc-map concat ;

PRIVATE>

: <interval-set> ( specification -- interval-set )
    spec>pairs sort-keys
    >intervals make-intervals ;

<PRIVATE

:: or-step ( set1 set2 -- set1' set2' )
    set1 first ,
    set1 second set2 first <=
    [ set1 0 ] [ set2 2 ] if
    [ second , ] [ set2 swap tail-slice ] bi*
    set1 2 tail-slice ;

: combine-or ( set1 set2 -- )
    {
        { [ over empty? ] [ % drop ] }
        { [ dup empty? ] [ drop % ] }
        [
            2dup [ first ] bi@ <=
            [ swap ] unless
            or-step combine-or
        ]
    } cond ;

PRIVATE>

: <interval-or> ( set1 set2 -- set )
    [ array>> ] bi@
    [ combine-or ] uint-array{ } make
    make-intervals ;

<PRIVATE

: prefix-0 ( seq -- 0seq )
    0 over ?nth zero? [ rest ] [ 0 prefix ] if ;

: interval-max ( interval-set1 interval-set2 -- n )
    [ array>> [ 0 ] [ last ] if-empty ] bi@ max ;

PRIVATE>

: <interval-not> ( set maximum -- set' )
    [ array>> prefix-0 ] dip suffix make-intervals ;

: <interval-and> ( set1 set2 -- set )
    2dup interval-max
    [ '[ _ <interval-not> ] bi@ <interval-or> ] keep
    <interval-not> ;
