! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: accessors kernel sequences arrays math math.order
combinators generic ;
IN: math.intervals

SYMBOL: empty-interval

TUPLE: interval { from read-only } { to read-only } ;

: <interval> ( from to -- int )
    over first over first {
        { [ 2dup > ] [ 2drop 2drop empty-interval ] }
        { [ 2dup = ] [
            2drop over second over second and
            [ interval boa ] [ 2drop empty-interval ] if
        ] }
        [ 2drop interval boa ]
    } cond ;

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

: [-inf,inf] ( -- interval )
    T{ interval f { -1./0. t } { 1./0. t } } ; inline

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
    [ [ first ] [ first ] [ ] tri* call ]
    [ drop [ second ] both? ]
    3bi 2array ; inline

: interval-op ( i1 i2 quot -- i3 )
    {
        [ [ from>> ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ to>>   ] [ ] tri* (interval-op) ]
        [ [ from>> ] [ to>>   ] [ ] tri* (interval-op) ]
    } 3cleave 4array points>interval ; inline

: do-empty-interval ( i1 i2 quot -- i3 )
    {
        { [ pick empty-interval eq? ] [ drop drop ] }
        { [ over empty-interval eq? ] [ drop nip ] }
        [ call ]
    } cond ; inline

: interval+ ( i1 i2 -- i3 )
    [ [ + ] interval-op ] do-empty-interval ;

: interval- ( i1 i2 -- i3 )
    [ [ - ] interval-op ] do-empty-interval ;

: interval* ( i1 i2 -- i3 )
    [ [ * ] interval-op ] do-empty-interval ;

: interval-1+ ( i1 -- i2 ) 1 [a,a] interval+ ;

: interval-1- ( i1 -- i2 ) -1 [a,a] interval+ ;

: interval-neg ( i1 -- i2 ) -1 [a,a] interval* ;

: interval-bitnot ( i1 -- i2 ) interval-neg interval-1- ;

: interval-sq ( i1 -- i2 ) dup interval* ;

: interval-intersect ( i1 i2 -- i3 )
    {
        { [ dup empty-interval eq? ] [ nip ] }
        { [ over empty-interval eq? ] [ drop ] }
        [
            2dup and [
                [ interval>points ] bi@ swapd
                [ [ swap endpoint< ] most ]
                [ [ swap endpoint> ] most ] 2bi*
                <interval>
            ] [
                or
            ] if
        ]
    } cond ;

: intervals-intersect? ( i1 i2 -- ? )
    interval-intersect empty-interval eq? not ;

: interval-union ( i1 i2 -- i3 )
    {
        { [ dup empty-interval eq? ] [ drop ] }
        { [ over empty-interval eq? ] [ nip ] }
        [
            2dup and [
                [ interval>points 2array ] bi@ append points>interval
            ] [
                2drop f
            ] if
        ]
    } cond ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

: interval-contains? ( x int -- ? )
    >r [a,a] r> interval-subset? ;

: interval-singleton? ( int -- ? )
    dup empty-interval eq? [
        drop f
    ] [
        interval>points
        2dup [ second ] bi@ and
        [ [ first ] bi@ = ]
        [ 2drop f ] if
    ] if ;

: interval-length ( int -- n )
    {
        { [ dup empty-interval eq? ] [ drop 0 ] }
        { [ dup not ] [ drop 0 ] }
        [ interval>points [ first ] bi@ swap - ]
    } cond ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] bi@ [a,b] ] when ;

: interval-integer-op ( i1 i2 quot -- i3 )
    >r 2dup
    [ interval>points [ first integer? ] both? ] both?
    r> [ 2drop [-inf,inf] ] if ; inline

: interval-shift ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [
        [
            [ interval-closure ] bi@
            [ shift ] interval-op
        ] interval-integer-op
    ] do-empty-interval ;

: interval-shift-safe ( i1 i2 -- i3 )
    [
        dup to>> first 100 > [
            2drop [-inf,inf]
        ] [
            interval-shift
        ] if
    ] do-empty-interval ;

: interval-max ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ [ interval-closure ] bi@ [ max ] interval-op ] do-empty-interval ;

: interval-min ( i1 i2 -- i3 )
    #! Inaccurate; could be tighter
    [ [ interval-closure ] bi@ [ min ] interval-op ] do-empty-interval ;

: interval-interior ( i1 -- i2 )
    dup empty-interval eq? [
        interval>points [ first ] bi@ (a,b)
    ] unless ;

: interval-division-op ( i1 i2 quot -- i3 )
    >r 0 over interval-closure interval-contains?
    [ 2drop [-inf,inf] ] r> if ; inline

: interval/ ( i1 i2 -- i3 )
    [ [ [ / ] interval-op ] interval-division-op ] do-empty-interval ;

: interval/-safe ( i1 i2 -- i3 )
    #! Just a hack to make the compiler work if bootstrap.math
    #! is not loaded.
    \ integer \ / method [ interval/ ] [ 2drop f ] if ;

: interval/i ( i1 i2 -- i3 )
    [
        [
            [
                [ interval-closure ] bi@
                [ /i ] interval-op
            ] interval-integer-op
        ] interval-division-op
    ] do-empty-interval ;

: interval/f ( i1 i2 -- i3 )
    [ [ [ /f ] interval-op ] interval-division-op ] do-empty-interval ;

: (interval-abs) ( i1 -- i2 )
    interval>points [ first2 [ abs ] dip 2array ] bi@ 2array ;

: interval-abs ( i1 -- i2 )
    {
        { [ dup empty-interval eq? ] [ ] }
        { [ 0 over interval-contains? ] [ (interval-abs) { 0 t } suffix points>interval ] }
        [ (interval-abs) points>interval ]
    } cond ;

: interval-mod ( i1 i2 -- i3 )
    #! Inaccurate.
    [
        [
            nip interval-abs to>> first [ neg ] keep (a,b)
        ] interval-division-op
    ] do-empty-interval ;

: interval-rem ( i1 i2 -- i3 )
    #! Inaccurate.
    [
        [
            nip interval-abs to>> first 0 swap [a,b)
        ] interval-division-op
    ] do-empty-interval ;

: interval-recip ( i1 -- i2 ) 1 [a,a] swap interval/ ;

: interval-2/ ( i1 -- i2 ) -1 [a,a] interval-shift ;

SYMBOL: incomparable

: left-endpoint-< ( i1 i2 -- ? )
    [ swap interval-subset? ]
    [ nip interval-singleton? ]
    [ [ from>> ] bi@ = ]
    2tri and and ;

: right-endpoint-< ( i1 i2 -- ? )
    [ interval-subset? ]
    [ drop interval-singleton? ]
    [ [ to>> ] bi@ = ]
    2tri and and ;

: (interval<) ( i1 i2 -- i1 i2 ? )
    over from>> over from>> endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup [ empty-interval eq? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval eq? ] [ (interval<) ] }
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
        { [ 2dup [ empty-interval eq? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval eq? ] [ (interval<) ] }
        { [ 2dup right-endpoint-<= ] [ t ] }
        [ incomparable ]
    } cond 2nip ;

: interval> ( i1 i2 -- ? )
    swap interval< ;

: interval>= ( i1 i2 -- ? )
    swap interval<= ;

: interval-bitand-pos ( i1 i2 -- ? )
    [ to>> first ] bi@ min 0 swap [a,b] ;

: interval-bitand-neg ( i1 i2 -- ? )
    dup from>> first 0 < [ drop ] [ nip ] if
    0 swap to>> first [a,b] ;

: interval-nonnegative? ( i -- ? )
    from>> first 0 >= ;

: interval-bitand ( i1 i2 -- i3 )
    #! Inaccurate.
    [
        {
            {
                [ 2dup [ interval-nonnegative? ] both? ]
                [ interval-bitand-pos ]
            }
            {
                [ 2dup [ interval-nonnegative? ] either? ]
                [ interval-bitand-neg ]
            }
            [ 2drop [-inf,inf] ]
        } cond
    ] do-empty-interval ;

: interval-bitor ( i1 i2 -- i3 )
    #! Inaccurate.
    [
        2dup [ interval-nonnegative? ] both?
        [
            [ interval>points [ first ] bi@ ] bi@
            4array supremum 0 swap next-power-of-2 [a,b]
        ] [ 2drop [-inf,inf] ] if
    ] do-empty-interval ;

: interval-bitxor ( i1 i2 -- i3 )
    #! Inaccurate.
    interval-bitor ;

: assume< ( i1 i2 -- i3 )
    dup empty-interval eq? [ drop ] [
        to>> first [-inf,a) interval-intersect
    ] if ;

: assume<= ( i1 i2 -- i3 )
    dup empty-interval eq? [ drop ] [
        to>> first [-inf,a] interval-intersect
    ] if ;

: assume> ( i1 i2 -- i3 )
    dup empty-interval eq? [ drop ] [
        from>> first (a,inf] interval-intersect
    ] if ;

: assume>= ( i1 i2 -- i3 )
    dup empty-interval eq? [ drop ] [
        from>> first [a,inf] interval-intersect
    ] if ;

: integral-closure ( i1 -- i2 )
    dup empty-interval eq? [
        [ from>> first2 [ 1+ ] unless ]
        [ to>> first2 [ 1- ] unless ]
        bi [a,b]
    ] unless ;
