! Copyright (C) 2007, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: accessors kernel sequences arrays math math.order
combinators generic layouts ;
IN: math.intervals

SYMBOL: empty-interval

SYMBOL: full-interval

TUPLE: interval { from read-only } { to read-only } ;

: <interval> ( from to -- interval )
    2dup [ first ] bi@ {
        { [ 2dup > ] [ 2drop 2drop empty-interval ] }
        { [ 2dup = ] [
            2drop 2dup [ second ] both?
            [ interval boa ] [ 2drop empty-interval ] if
        ] }
        [ 2drop interval boa ]
    } cond ;

: open-point ( n -- endpoint ) f 2array ;

: closed-point ( n -- endpoint ) t 2array ;

: [a,b] ( a b -- interval )
    [ closed-point ] dip closed-point <interval> ; foldable

: (a,b) ( a b -- interval )
    [ open-point ] dip open-point <interval> ; foldable

: [a,b) ( a b -- interval )
    [ closed-point ] dip open-point <interval> ; foldable

: (a,b] ( a b -- interval )
    [ open-point ] dip closed-point <interval> ; foldable

: [a,a] ( a -- interval )
    closed-point dup <interval> ; foldable

: [-inf,a] ( a -- interval ) -1/0. swap [a,b] ; inline

: [-inf,a) ( a -- interval ) -1/0. swap [a,b) ; inline

: [a,inf] ( a -- interval ) 1/0. [a,b] ; inline

: (a,inf] ( a -- interval ) 1/0. (a,b] ; inline

: [0,inf] ( -- interval ) 0 [a,inf] ; foldable

: [-inf,inf] ( -- interval ) full-interval ; inline

: compare-endpoints ( p1 p2 quot -- ? )
    [ 2dup [ first ] bi@ ] dip call [
        2drop t
    ] [
        2dup [ first ] bi@ = [
            [ second ] bi@ not or
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
    dup [ first fp-nan? ] any?
    [ drop [-inf,inf] ] [
        dup first
        [ [ endpoint-min ] reduce ]
        [ [ endpoint-max ] reduce ]
        2bi <interval>
    ] if ;

: (interval-op) ( p1 p2 quot -- p3 )
    [ [ first ] [ first ] [ call ] tri* ]
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
        { [ pick empty-interval eq? ] [ 2drop ] }
        { [ over empty-interval eq? ] [ drop nip ] }
        { [ pick full-interval eq? ] [ 2drop ] }
        { [ over full-interval eq? ] [ drop nip ] }
        [ call ]
    } cond ; inline

: interval+ ( i1 i2 -- i3 )
    [ [ + ] interval-op ] do-empty-interval ;

: interval- ( i1 i2 -- i3 )
    [ [ - ] interval-op ] do-empty-interval ;

: interval-intersect ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ drop ] }
        { [ dup empty-interval eq? ] [ nip ] }
        { [ over full-interval eq? ] [ nip ] }
        { [ dup full-interval eq? ] [ drop ] }
        [
            [ interval>points ] bi@
            [ [ swap endpoint< ] most ]
            [ [ swap endpoint> ] most ] bi-curry* bi*
            <interval>
        ]
    } cond ;

: intervals-intersect? ( i1 i2 -- ? )
    interval-intersect empty-interval eq? not ;

: interval-union ( i1 i2 -- i3 )
    {
        { [ over empty-interval eq? ] [ nip ] }
        { [ dup empty-interval eq? ] [ drop ] }
        { [ over full-interval eq? ] [ drop ] }
        { [ dup full-interval eq? ] [ nip ] }
        [ [ interval>points 2array ] bi@ append points>interval ]
    } cond ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

: interval-contains? ( x int -- ? )
    dup empty-interval eq? [ 2drop f ] [
        dup full-interval eq? [ 2drop t ] [
            [ from>> first2 [ >= ] [ > ] if ]
            [ to>>   first2 [ <= ] [ < ] if ]
            2bi and
        ] if
    ] if ;

: interval-zero? ( int -- ? )
    0 swap interval-contains? ;

: interval* ( i1 i2 -- i3 )
    [ [ [ * ] interval-op ] do-empty-interval ]
    [ [ interval-zero? ] either? ]
    2bi [ 0 [a,a] interval-union ] when ;

: interval-1+ ( i1 -- i2 ) 1 [a,a] interval+ ;

: interval-1- ( i1 -- i2 ) -1 [a,a] interval+ ;

: interval-neg ( i1 -- i2 ) -1 [a,a] interval* ;

: interval-bitnot ( i1 -- i2 ) interval-neg interval-1- ;

: interval-sq ( i1 -- i2 ) dup interval* ;

: special-interval? ( interval -- ? )
    { empty-interval full-interval } memq? ;

: interval-singleton? ( int -- ? )
    dup special-interval? [
        drop f
    ] [
        interval>points
        2dup [ second ] both?
        [ [ first ] bi@ = ]
        [ 2drop f ] if
    ] if ;

: interval-length ( int -- n )
    {
        { [ dup empty-interval eq? ] [ drop 0 ] }
        { [ dup full-interval eq? ] [ drop 1/0. ] }
        [ interval>points [ first ] bi@ swap - ]
    } cond ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] bi@ [a,b] ] when ;

: interval-integer-op ( i1 i2 quot -- i3 )
    [
        2dup [ interval>points [ first integer? ] both? ] both?
    ] dip [ 2drop [-inf,inf] ] if ; inline

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
    dup special-interval? [
        interval>points [ first ] bi@ (a,b)
    ] unless ;

: interval-division-op ( i1 i2 quot -- i3 )
    {
        { [ 0 pick interval-closure interval-contains? ] [ 3drop [-inf,inf] ] }
        { [ pick interval-zero? ] [ call 0 [a,a] interval-union ] }
        [ call ]
    } cond ; inline

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
        { [ dup full-interval eq? ] [ drop [0,inf] ] }
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
    2dup [ from>> ] bi@ endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval eq? ] [ (interval<) ] }
        { [ 2dup left-endpoint-< ] [ f ] }
        { [ 2dup right-endpoint-< ] [ f ] }
        [ incomparable ]
    } cond 2nip ;

: left-endpoint-<= ( i1 i2 -- ? )
    [ from>> ] dip to>> = ;

: right-endpoint-<= ( i1 i2 -- ? )
    [ to>> ] dip from>> = ;

: interval<= ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
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
            4array supremum 0 swap >integer next-power-of-2 [a,b]
        ] [ 2drop [-inf,inf] ] if
    ] do-empty-interval ;

: interval-bitxor ( i1 i2 -- i3 )
    #! Inaccurate.
    interval-bitor ;

: interval-log2 ( i1 -- i2 )
    {
        { empty-interval [ empty-interval ] }
        { full-interval [ [0,inf] ] }
        [
            to>> first 1 max dup most-positive-fixnum >
            [ drop full-interval interval-log2 ]
            [ 1 + >integer log2 0 swap [a,b] ]
            if
        ]
    } case ;

: assume< ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,a) interval-intersect
    ] if ;

: assume<= ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,a] interval-intersect
    ] if ;

: assume> ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        from>> first (a,inf] interval-intersect
    ] if ;

: assume>= ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        from>> first [a,inf] interval-intersect
    ] if ;

: integral-closure ( i1 -- i2 )
    dup special-interval? [
        [ from>> first2 [ 1 + ] unless ]
        [ to>> first2 [ 1 - ] unless ]
        bi [a,b]
    ] unless ;
