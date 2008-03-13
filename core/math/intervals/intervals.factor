! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: kernel sequences arrays math combinators ;
IN: math.intervals

TUPLE: interval from to ;

C: <interval> interval

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

: [-inf,a] ( a -- interval ) -1./0. swap [a,b] ;

: [-inf,a) ( a -- interval ) -1./0. swap [a,b) ;

: [a,inf] ( a -- interval ) 1./0. [a,b] ;

: (a,inf] ( a -- interval ) 1./0. (a,b] ;

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

: interval>points ( int -- from to )
    dup interval-from swap interval-to ;

: points>interval ( seq -- interval )
    dup first
    [ [ endpoint-min ] reduce ] 2keep
    [ endpoint-max ] reduce <interval> ;

: (interval-op) ( p1 p2 quot -- p3 )
    2over >r >r
    >r [ first ] 2apply r> call
    r> r> [ second ] both? 2array ; inline

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
    [ interval>points [ first integer? ] both? ] both?
    r> [ 2drop f ] if ; inline

: interval-1+ ( i1 -- i2 ) 1 [a,a] interval+ ;

: interval-1- ( i1 -- i2 ) -1 [a,a] interval+ ;

: interval-neg ( i1 -- i2 ) -1 [a,a] interval* ;

: interval-bitnot ( i1 -- i2 ) interval-neg interval-1- ;

: make-interval ( from to -- int )
    over first over first {
        { [ 2dup > ] [ 2drop 2drop f ] }
        { [ 2dup = ] [
            2drop over second over second and
            [ <interval> ] [ 2drop f ] if
        ] }
        { [ t ] [ 2drop <interval> ] }
    } cond ;

: interval-intersect ( i1 i2 -- i3 )
    2dup and [
        [ interval>points ] 2apply swapd
        [ swap endpoint> ] most
        >r [ swap endpoint< ] most r>
        make-interval
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

: interval-singleton? ( int -- ? )
    interval>points
    2dup [ second ] 2apply and
    [ [ first ] 2apply = ]
    [ 2drop f ] if ;

: interval-length ( int -- n )
    dup
    [ interval>points [ first ] 2apply swap - ]
    [ drop 0 ] if ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] 2apply [a,b] ] when ;

: interval-shift ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ [ shift ] interval-op ] interval-integer-op interval-closure ;

: interval-shift-safe ( i1 i2 -- i3 )
    dup interval-to first 100 > [
        2drop f
    ] [
        interval-shift
    ] if ;

: interval-max ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ max ] interval-op interval-closure ;

: interval-min ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ min ] interval-op interval-closure ;

: interval-interior ( i1 -- i2 )
    interval>points [ first ] 2apply (a,b) ;

: interval-division-op ( i1 i2 quot -- i3 )
    >r 0 over interval-closure interval-contains?
    [ 2drop f ] r> if ; inline

: interval/ ( i1 i2 -- i3 )
    [ [ / ] interval-op ] interval-division-op ;

: interval/i ( i1 i2 -- i3 )
    [
        [ [ /i ] interval-op ] interval-integer-op
    ] interval-division-op interval-closure ;

: interval-recip ( i1 -- i2 ) 1 [a,a] swap interval/ ;

: interval-2/ ( i1 -- i2 ) -1 [a,a] interval-shift ;

SYMBOL: incomparable

: left-endpoint-< ( i1 i2 -- ? )
    [ swap interval-subset? ] 2keep
    [ nip interval-singleton? ] 2keep
    [ interval-from ] 2apply =
    and and ;

: right-endpoint-< ( i1 i2 -- ? )
    [ interval-subset? ] 2keep
    [ drop interval-singleton? ] 2keep
    [ interval-to ] 2apply =
    and and ;

: (interval<) over interval-from over interval-from endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup interval-intersect not ] [ (interval<) ] }
        { [ 2dup left-endpoint-< ] [ f ] }
        { [ 2dup right-endpoint-< ] [ f ] }
        { [ t ] [ incomparable ] }
    } cond 2nip ;

: left-endpoint-<= ( i1 i2 -- ? )
    >r interval-from r> interval-to = ;

: right-endpoint-<= ( i1 i2 -- ? )
    >r interval-to r> interval-from = ;

: interval<= ( i1 i2 -- ? )
    {
        { [ 2dup interval-intersect not ] [ (interval<) ] }
        { [ 2dup right-endpoint-<= ] [ t ] }
        { [ t ] [ incomparable ] }
    } cond 2nip ;

: interval> ( i1 i2 -- ? )
    swap interval< ;

: interval>= ( i1 i2 -- ? )
    swap interval<= ;

: assume< ( i1 i2 -- i3 )
    interval-to first [-inf,a) interval-intersect ;

: assume<= ( i1 i2 -- i3 )
    interval-to first [-inf,a] interval-intersect ;

: assume> ( i1 i2 -- i3 )
    interval-from first (a,inf] interval-intersect ;

: assume>= ( i1 i2 -- i3 )
    interval-to first [a,inf] interval-intersect ;

: integral-closure ( i1 -- i2 )
    dup interval-from first2 [ 1+ ] unless
    swap interval-to first2 [ 1- ] unless
    [a,b] ;
