! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: accessors kernel sequences arrays math math.order
combinators ;
IN: math.intervals

TUPLE: interval { from read-only } { to read-only } ;

C: <interval> interval

: open-point ( n -- endpoint ) f 2array ;

: closed-point ( n -- endpoint ) t 2array ;

: [a,b] ( a b -- interval )
    >r closed-point r> closed-point <interval> ; foldable

: (a,b) ( a b -- interval )
    >r open-point r> open-point <interval> ; foldable

: [a,b) ( a b -- interval )
    >r closed-point r> open-point <interval> ; foldable

: (a,b] ( a b -- interval )
    >r open-point r> closed-point <interval> ; foldable

: [a,a] ( a -- interval )
    closed-point dup <interval> ; foldable

: [-inf,a] ( a -- interval ) -1./0. swap [a,b] ; inline

: [-inf,a) ( a -- interval ) -1./0. swap [a,b) ; inline

: [a,inf] ( a -- interval ) 1./0. [a,b] ; inline

: (a,inf] ( a -- interval ) 1./0. (a,b] ; inline

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
    [ from>> ] [ to>> ] bi ;

: points>interval ( seq -- interval )
    dup first
    [ [ endpoint-min ] reduce ] 2keep
    [ endpoint-max ] reduce <interval> ;

: (interval-op) ( p1 p2 quot -- p3 )
    2over >r >r
    >r [ first ] bi@ r> call
    r> r> [ second ] both? 2array ; inline

: interval-op ( i1 i2 quot -- i3 )
    {
        [ [ from>> ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ to>>   ] [ ] tri* (interval-op) ]
        [ [ from>> ] [ to>>   ] [ ] tri* (interval-op) ]
    } 3cleave 4array points>interval ; inline

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

: interval-sq ( i1 -- i2 ) dup interval* ;

: make-interval ( from to -- int )
    over first over first {
        { [ 2dup > ] [ 2drop 2drop f ] }
        { [ 2dup = ] [
            2drop over second over second and
            [ <interval> ] [ 2drop f ] if
        ] }
        [ 2drop <interval> ]
    } cond ;

: interval-intersect ( i1 i2 -- i3 )
    2dup and [
        [ interval>points ] bi@ swapd
        [ swap endpoint> ] most
        >r [ swap endpoint< ] most r>
        make-interval
    ] [
        or
    ] if ;

: interval-union ( i1 i2 -- i3 )
    2dup and [
        [ interval>points 2array ] bi@ append points>interval
    ] [
        2drop f
    ] if ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

: interval-contains? ( x int -- ? )
    >r [a,a] r> interval-subset? ;

: interval-singleton? ( int -- ? )
    interval>points
    2dup [ second ] bi@ and
    [ [ first ] bi@ = ]
    [ 2drop f ] if ;

: interval-length ( int -- n )
    dup
    [ interval>points [ first ] bi@ swap - ]
    [ drop 0 ] if ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] bi@ [a,b] ] when ;

: interval-shift ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ [ shift ] interval-op ] interval-integer-op interval-closure ;

: interval-shift-safe ( i1 i2 -- i3 )
    dup to>> first 100 > [
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
    interval>points [ first ] bi@ (a,b) ;

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
    [ from>> ] bi@ =
    and and ;

: right-endpoint-< ( i1 i2 -- ? )
    [ interval-subset? ] 2keep
    [ drop interval-singleton? ] 2keep
    [ to>> ] bi@ =
    and and ;

: (interval<) ( i1 i2 -- i1 i2 ? )
    over from>> over from>> endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup interval-intersect not ] [ (interval<) ] }
        { [ 2dup left-endpoint-< ] [ f ] }
        { [ 2dup right-endpoint-< ] [ f ] }
        [ incomparable ]
    } cond 2nip ;

: left-endpoint-<= ( i1 i2 -- ? )
    >r from>> r> to>> = ;

: right-endpoint-<= ( i1 i2 -- ? )
    >r to>> r> from>> = ;

: interval<= ( i1 i2 -- ? )
    {
        { [ 2dup interval-intersect not ] [ (interval<) ] }
        { [ 2dup right-endpoint-<= ] [ t ] }
        [ incomparable ]
    } cond 2nip ;

: interval> ( i1 i2 -- ? )
    swap interval< ;

: interval>= ( i1 i2 -- ? )
    swap interval<= ;

: assume< ( i1 i2 -- i3 )
    to>> first [-inf,a) interval-intersect ;

: assume<= ( i1 i2 -- i3 )
    to>> first [-inf,a] interval-intersect ;

: assume> ( i1 i2 -- i3 )
    from>> first (a,inf] interval-intersect ;

: assume>= ( i1 i2 -- i3 )
    to>> first [a,inf] interval-intersect ;

: integral-closure ( i1 -- i2 )
    [ from>> first2 [ 1+ ] unless ]
    [ to>> first2 [ 1- ] unless ]
    bi [a,b] ;
