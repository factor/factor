! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: kernel sequences arrays math errors words ;
IN: intervals

TUPLE: interval from to ;

: open-point f 2array ;

: closed-point t 2array ;

: [a,b] ( a b -- interval )
    >r closed-point r> closed-point <interval> ;

: (a,b) ( a b -- interval )
    >r open-point r> open-point <interval> ;

: [a,b) ( a b -- interval )
    >r closed-point r> open-point <interval> ;

: (a,b] ( a b -- interval )
    >r open-point r> closed-point <interval> ;

: [a,a] ( a -- interval ) closed-point dup <interval> ;

: compare-endpoints ( p1 p2 quot -- ? )
    >r over first over first r> call [
        2drop t
    ] [
        over first over first = [
            swap second swap second not or
        ] [
            2drop f
        ] if
    ] if ; inline

: endpoint< ( p1 p2 -- ? ) [ < ] compare-endpoints ;

: endpoint<= ( p1 p2 -- ? ) [ endpoint< ] 2keep = or ;

: endpoint> ( p1 p2 -- ? ) [ > ] compare-endpoints ;

: endpoint>= ( p1 p2 -- ? ) [ endpoint> ] 2keep = or ;

: endpoint-min ( p1 p2 -- p3 ) [ endpoint< ] most ;

: endpoint-max ( p1 p2 -- p3 ) [ endpoint> ] most ;

: interval>points ( i -- p1 p2 )
    dup interval-from swap interval-to ;

: points>interval ( seq -- interval )
    dup first
    [ [ endpoint-min ] reduce ] 2keep
    [ endpoint-max ] reduce <interval> ;

: (interval-op) ( p1 p2 quot -- p3 )
    pick pick >r >r
    >r >r first r> first r> call
    r> second r> second and 2array ; inline

: interval-op ( i1 i2 quot -- i3 )
    pick interval-from pick interval-from pick (interval-op) >r
    pick interval-to pick interval-from pick (interval-op) >r
    pick interval-to pick interval-to pick (interval-op) >r
    pick interval-from pick interval-to pick (interval-op) >r
    3drop r> r> r> r> 4array points>interval ; inline

: interval+ ( i1 i2 -- i3 ) [ + ] interval-op ;

: interval- ( i1 i2 -- i3 ) [ - ] interval-op ;

: interval* ( i1 i2 -- i3 ) [ * ] interval-op ;

: interval-integer-op ( i1 i2 quot -- i3 )
    >r 2dup
    [ interval>points [ first integer? ] 2apply and ] 2apply and
    r> [ 2drop f ] if ; inline

: interval-shift ( i1 i2 -- i3 )
    [ [ shift ] interval-op ] interval-integer-op ;

: interval-shift-safe ( i1 i2 -- i3 )
    dup interval-to first 100 > [
        2drop f
    ] [
        interval-shift
    ] if ;

: interval-max ( i1 i2 -- i3 ) [ max ] interval-op ;

: interval-min ( i1 i2 -- i3 ) [ min ] interval-op ;

: interval-1+ ( i1 -- i2 ) 1 [a,a] interval+ ;

: interval-1- ( i1 -- i2 ) -1 [a,a] interval+ ;

: interval-neg ( i1 -- i2 ) -1 [a,a] interval* ;

: interval-bitnot ( i1 -- i3 ) interval-neg interval-1- ;

: interval-intersect ( i1 i2 -- i3 )
    2dup and [
        [ interval>points ] 2apply swapd
        [ swap endpoint> ] most
        >r [ swap endpoint< ] most r>
        <interval>
    ] [
        or
    ] if ;

: interval-union ( i1 i2 -- i3 )
    2dup and [
        [ interval>points 2array ] 2apply append points>interval
    ] [
        2drop f
    ] if ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

: interval-contains? ( x int -- ? )
    >r [a,a] r> interval-subset? ;

: interval-closure ( i1 -- i2 )
    interval>points [ first ] 2apply [a,b] ;

: interval-division-op ( i1 i2 quot -- i3 )
    >r 0 over interval-closure interval-contains?
    [ 2drop f ] r> if ; inline

: interval/ ( i1 i2 -- i3 )
    [ [ / ] interval-op ] interval-division-op ;

: interval/i ( i1 i2 -- i3 )
    [
        [ [ /i ] interval-op ] interval-integer-op
    ] interval-division-op ;

: interval-recip ( i1 -- i2 ) 1 [a,a] swap interval/ ;

: interval-2/ ( i1 -- i2 ) -1 [a,a] interval-shift ;

: assume< ( i1 i2 -- i3 )
    interval-to first -1./0. swap [a,b) interval-intersect ;

: assume<= ( i1 i2 -- i3 )
    interval-to first -1./0. swap [a,b] interval-intersect ;

: assume> ( i1 i2 -- i3 )
    interval-from first 1./0. (a,b] interval-intersect ;

: assume>= ( i1 i2 -- i3 )
    interval-to first 1./0. [a,b] interval-intersect ;

: integral-closure ( i1 -- i2 )
    dup interval-from first2 [ 1+ ] unless
    swap interval-to first2 [ 1- ] unless
    [a,b] ;
