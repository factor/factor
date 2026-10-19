! Copyright (C) 2007, 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Based on Slate's src/unfinished/interval.slate by Brian Rice.
USING: accessors kernel sequences arrays math math.order
combinators combinators.short-circuit generic layouts math.intervals.bounds memoize ;
IN: math.intervals

SINGLETON: empty-interval
SINGLETON: full-interval
UNION: special-interval empty-interval full-interval ;

TUPLE: interval { from read-only } { to read-only } ;

M: empty-interval from>> drop positive-bound f 2array ;
M: empty-interval to>> drop negative-bound f 2array ;
M: full-interval from>> drop negative-bound t 2array ;
M: full-interval to>> drop positive-bound t 2array ;

: closed-point? ( from to -- ? )
    2dup [ first ] bi@ bound=
    [ [ second ] both? ] [ 2drop f ] if ;

: (interval) ( from to -- interval )
    {
        { [ 2dup [ first ] bi@ bound> ] [ 2drop empty-interval ] }
        { [ 2dup [ first ] bi@ bound= ] [
            2dup [ second ] both?
            [ interval boa ] [ 2drop empty-interval ] if
        ] }
        { [
            2dup [ first negative-bound bound= ] [ first positive-bound bound= ] bi* and
            2over [ second ] both? and
        ] [
            2drop full-interval
        ] }
        [ interval boa ]
    } cond ;

! Exact finite endpoints and symbolic infinities retain integer range precision.
: <interval> ( from to -- interval )
    floating-point-supported?
    [ (interval) ] [
        2dup [ first valid-bound? ] both? [
            [ first2 [ normalize-bound ] dip 2array ] bi@ (interval)
        ] [ 2drop full-interval ] if
    ] if ;

: open-point ( n -- endpoint ) f 2array ;

: closed-point ( n -- endpoint ) t 2array ;

: [a,b] ( a b -- interval )
    [ closed-point ] dip closed-point <interval> ;

: (a,b) ( a b -- interval )
    [ open-point ] dip open-point <interval> ;

: [a,b) ( a b -- interval )
    [ closed-point ] dip open-point <interval> ;

: (a,b] ( a b -- interval )
    [ open-point ] dip closed-point <interval> ;

: [a,a] ( a -- interval )
    closed-point dup <interval> ;

: [-inf,b] ( b -- interval )
    negative-bound swap [a,b] ;

: [-inf,b) ( b -- interval )
    negative-bound swap [a,b) ;

: [a,inf] ( a -- interval )
    positive-bound [a,b] ;

: (a,inf] ( a -- interval )
    positive-bound (a,b] ;

: [0,b] ( b -- interval ) 0 swap [a,b] ; inline

: [0,b) ( b -- interval ) 0 swap [a,b) ; inline

: [0,inf] ( -- interval ) 0 [a,inf] ;

MEMO: fixnum-interval ( -- interval )
    most-negative-fixnum most-positive-fixnum [a,b] ; inline

MEMO: array-capacity-interval ( -- interval )
    0 max-array-capacity [a,b] ; inline

: [-inf,inf] ( -- interval ) full-interval ; inline

: compare-endpoints ( p1 p2 quot -- ? )
    [ 2dup [ first ] bi@ 2dup ] dip call [
        4drop t
    ] [
        bound= [ [ second ] bi@ not or ] [ 2drop f ] if
    ] if ; inline

: endpoint= ( p1 p2 -- ? )
    { [ [ first ] bi@ bound= ] [ [ second ] bi@ eq? ] } 2&& ;

: endpoint< ( p1 p2 -- ? )
    [ bound< ] compare-endpoints ;

: endpoint<= ( p1 p2 -- ? )
    { [ endpoint< ] [ endpoint= ] } 2|| ;

: endpoint> ( p1 p2 -- ? )
    [ bound> ] compare-endpoints ;

: endpoint>= ( p1 p2 -- ? )
    { [ endpoint> ] [ endpoint= ] } 2|| ;

: endpoint-min ( p1 p2 -- p3 ) [ endpoint< ] most ;

: endpoint-max ( p1 p2 -- p3 ) [ endpoint> ] most ;

: interval>points ( interval -- from to )
    [ from>> ] [ to>> ] bi ;

: points>interval ( seq -- interval nan? )
    [ first bound-nan? not ] partition
    [
        [ [ ] [ endpoint-min ] map-reduce ]
        [ [ ] [ endpoint-max ] map-reduce ] bi
        <interval>
    ]
    [ empty? not ]
    bi* ;

: nan-ok ( interval nan? -- interval ) drop ; inline
: nan-not-ok ( interval nan? -- interval ) [ drop full-interval ] when ; inline

: (interval-op) ( p1 p2 quot -- p3 )
    [ [ first ] [ first ] [ call ] tri* ]
    [ drop [ second ] both? ]
    3bi 2array ; inline

: interval-op ( i1 i2 quot -- i3 nan? )
    {
        [ [ from>> ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ from>> ] [ ] tri* (interval-op) ]
        [ [ to>>   ] [ to>>   ] [ ] tri* (interval-op) ]
        [ [ from>> ] [ to>>   ] [ ] tri* (interval-op) ]
    } 3cleave 4array points>interval ; inline

: do-empty-interval ( i1 i2 quot -- i3 )
    {
        { [ pick empty-interval? ] [ 2drop ] }
        { [ over empty-interval? ] [ drop nip ] }
        { [ pick full-interval? ] [ 2drop ] }
        { [ over full-interval? ] [ drop nip ] }
        [ call ]
    } cond ; inline

: interval+ ( i1 i2 -- i3 )
    [ [ bound+ ] interval-op nan-ok ] do-empty-interval ;

: interval- ( i1 i2 -- i3 )
    [ [ bound- ] interval-op nan-ok ] do-empty-interval ;

: interval-intersect ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ drop ] }
        { [ dup empty-interval? ] [ nip ] }
        { [ over full-interval? ] [ nip ] }
        { [ dup full-interval? ] [ drop ] }
        [
            [ interval>points ] bi@
            [ [ swap endpoint< ] most ]
            [ [ swap endpoint> ] most ] bi-curry* bi*
            <interval>
        ]
    } cond ;

: intervals-intersect? ( i1 i2 -- ? )
    interval-intersect empty-interval? not ;

: interval-union ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ nip ] }
        { [ dup empty-interval? ] [ drop ] }
        { [ over full-interval? ] [ drop ] }
        { [ dup full-interval? ] [ nip ] }
        [ [ interval>points 2array ] bi@ append points>interval nan-not-ok ]
    } cond ;

: interval-subset? ( i1 i2 -- ? )
    dupd interval-intersect = ;

GENERIC: interval-contains? ( x interval -- ? )
M: empty-interval interval-contains? 2drop f ;
M: full-interval interval-contains? 2drop t ;
M: interval interval-contains?
    {
        [ from>> first2 [ bound>= ] [ bound> ] if ]
        [ to>>   first2 [ bound<= ] [ bound< ] if ]
    } 2&& ;

: interval-zero? ( interval -- ? )
    0 swap interval-contains? ;

: interval* ( i1 i2 -- i3 )
    [ [ [ bound* ] interval-op nan-ok ] do-empty-interval ]
    [ [ interval-zero? ] either? ]
    2bi [ 0 [a,a] interval-union ] when ;

: interval-1+ ( i1 -- i2 ) 1 [a,a] interval+ ;

: interval-1- ( i1 -- i2 ) -1 [a,a] interval+ ;

: interval-neg ( i1 -- i2 ) -1 [a,a] interval* ;

: interval-bitnot ( i1 -- i2 ) interval-neg interval-1- ;

: interval-sq ( i1 -- i2 ) dup interval* ;

GENERIC: interval-singleton? ( interval -- ? )
M: special-interval interval-singleton? drop f ;
M: interval interval-singleton?
    interval>points
    2dup [ second ] both?
    [ [ first ] bi@ bound= ]
    [ 2drop f ] if ;

GENERIC: interval-length ( interval -- n )
M: empty-interval interval-length drop 0 ;
M: full-interval interval-length drop positive-bound ;
M: interval interval-length
    interval>points [ first ] bi@ swap bound- ;

: interval-closure ( i1 -- i2 )
    dup [ interval>points [ first ] bi@ [a,b] ] when ;

: interval-integer-op ( i1 i2 quot -- i3 )
    [
        2dup [ interval>points [ first integer? ] both? ] both?
    ] dip [ 2drop [-inf,inf] ] if ; inline

: interval-shift ( i1 i2 -- i3 )
    ! Inaccurate; could be tighter
    [
        [
            [ interval-closure ] bi@
            [ shift ] interval-op nan-not-ok
        ] interval-integer-op
    ] do-empty-interval ;

: interval-shift-safe ( i1 i2 -- i3 )
    [
        dup to>> first 100 bound> [
            2drop [-inf,inf]
        ] [
            interval-shift
        ] if
    ] do-empty-interval ;

: interval-max ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ drop ] }
        { [ dup empty-interval? ] [ nip ] }
        { [ 2dup [ full-interval? ] both? ] [ drop ] }
        { [ over full-interval? ] [ nip from>> first [a,inf] ] }
        { [ dup full-interval? ] [ drop from>> first [a,inf] ] }
        [ [ interval-closure ] bi@ [ bound-max ] interval-op nan-not-ok ]
    } cond ;

: interval-min ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ drop ] }
        { [ dup empty-interval? ] [ nip ] }
        { [ 2dup [ full-interval? ] both? ] [ drop ] }
        { [ over full-interval? ] [ nip to>> first [-inf,b] ] }
        { [ dup full-interval? ] [ drop to>> first [-inf,b] ] }
        [ [ interval-closure ] bi@ [ bound-min ] interval-op nan-not-ok ]
    } cond ;

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
    [ [ [ bound/ ] interval-op nan-not-ok ] interval-division-op ] do-empty-interval ;

: interval/-safe ( i1 i2 -- i3 )
    ! Just a hack to make the compiler work if bootstrap.math
    ! is not loaded.
    \ integer \ / ?lookup-method [ interval/ ] [ 2drop f ] if ;

: interval/i ( i1 i2 -- i3 )
    [
        [
            [
                [ interval-closure ] bi@
                [ /i ] interval-op nan-not-ok
            ] interval-integer-op
        ] interval-division-op
    ] do-empty-interval ;

: interval/f ( i1 i2 -- i3 )
    floating-point-supported? [
        [ [ [ /f ] interval-op nan-not-ok ] interval-division-op ] do-empty-interval
    ] [ 2drop full-interval ] if ;

: (interval-abs) ( i1 -- i2 )
    interval>points [ first2 [ bound-abs ] dip 2array ] bi@ 2array ;

: interval-abs ( i1 -- i2 )
    {
        { [ dup empty-interval? ] [ ] }
        { [ dup full-interval? ] [ drop [0,inf] ] }
        { [ 0 over interval-contains? ] [ (interval-abs) { 0 t } suffix points>interval nan-not-ok ] }
        [ (interval-abs) points>interval nan-not-ok ]
    } cond ;

: interval-absq ( i1 -- i2 )
    interval-abs interval-sq ;

: interval-recip ( i1 -- i2 ) 1 [a,a] swap interval/ ;

: interval-2/ ( i1 -- i2 ) -1 [a,a] interval-shift ;

SYMBOL: incomparable

: left-endpoint-< ( i1 i2 -- ? )
    {
        [ swap interval-subset? ]
        [ nip interval-singleton? ]
        [ [ from>> ] bi@ endpoint= ]
    } 2&& ;

: right-endpoint-< ( i1 i2 -- ? )
    {
        [ interval-subset? ]
        [ drop interval-singleton? ]
        [ [ to>> ] bi@ endpoint= ]
    } 2&& ;

: (interval<) ( i1 i2 -- i1 i2 ? )
    2dup [ from>> ] bi@ endpoint< ;

: interval< ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval? ] [ (interval<) ] }
        { [ 2dup left-endpoint-< ] [ f ] }
        { [ 2dup right-endpoint-< ] [ f ] }
        [ incomparable ]
    } cond 2nip ;

: left-endpoint-<= ( i1 i2 -- ? )
    [ from>> ] [ to>> ] bi* endpoint= ;

: right-endpoint-<= ( i1 i2 -- ? )
    [ to>> ] [ from>> ] bi* endpoint= ;

: interval<= ( i1 i2 -- ? )
    {
        { [ 2dup [ special-interval? ] either? ] [ incomparable ] }
        { [ 2dup interval-intersect empty-interval? ] [ (interval<) ] }
        { [ 2dup right-endpoint-<= ] [ t ] }
        [ incomparable ]
    } cond 2nip ;

: interval> ( i1 i2 -- ? )
    swap interval< ;

: interval>= ( i1 i2 -- ? )
    swap interval<= ;

: interval-mod ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ swap ] }
        { [ dup empty-interval? ] [ ] }
        { [ dup full-interval? ] [ ] }
        [ interval-abs to>> first [ bound-neg ] keep (a,b) ]
    } cond
    swap 0 [a,a] interval>= t eq? [ [0,inf] interval-intersect ] when ;

: (rem-range) ( interval -- interval' ) interval-abs to>> first [0,b) ;

: interval-rem ( i1 i2 -- i3 )
    {
        { [ over empty-interval? ] [ drop ] }
        { [ dup empty-interval? ] [ nip ] }
        { [ dup full-interval? ] [ 2drop [0,inf] ] }
        [ nip (rem-range) ]
    } cond ;

: interval-nonnegative? ( interval -- ? )
    dup special-interval?
    [ empty-interval? ] [ from>> first 0 bound>= ] if ;

: interval-nonpositive? ( interval -- ? )
    dup special-interval?
    [ empty-interval? ] [ to>> first 0 bound<= ] if ;

: interval-negative? ( interval -- ? )
    dup special-interval?
    [ empty-interval? ] [ to>> first 0 bound< ] if ;

<PRIVATE
! Return the weight of the MSB.  For signed numbers, this does
! not mean the sign bit.
: bit-weight ( n -- m )
    normalize-bound dup infinite-bound? [ drop positive-bound ] [
        dup integer? [ f ] [ dup [ -1/0. = ] [ 1/0. = ] bi or ] if
        [ drop positive-bound ]
        [ dup 0 > [ 1 + ] [ neg ] if next-power-of-2 ] if
    ] if ;

GENERIC: interval-bounds ( interval -- lower upper )
M: full-interval interval-bounds drop negative-bound positive-bound ;
M: interval interval-bounds interval>points [ first ] bi@ ;

: min-lower-bound ( i1 i2 -- n )
    [ from>> first ] bi@ bound-min ;

: max-lower-bound ( i1 i2 -- n )
    [ from>> first ] bi@ bound-max ;

: min-upper-bound ( i1 i2 -- n )
    [ to>> first ] bi@ bound-min ;

: max-upper-bound ( i1 i2 -- n )
    [ to>> first ] bi@ bound-max ;

: interval-bit-weight ( i1 -- n )
    interval-bounds [ bit-weight ] bi@ bound-max ;
PRIVATE>

: interval-bitand ( i1 i2 -- i3 )
    [
        {
            {
                [ 2dup [ interval-nonnegative? ] both? ]
                [ min-upper-bound [0,b] ]
            }
            {
                [ 2dup [ interval-nonnegative? ] either? ]
                [
                    dup interval-nonnegative? [ nip ] [ drop ] if
                    to>> first [0,b]
                ]
            }
            [
                [ min-lower-bound bit-weight bound-neg ]
                [
                    2dup [ interval-negative? ] both?
                    [ min-upper-bound ] [ max-upper-bound ] if
                ] 2bi [a,b]
            ]
        } cond
    ] do-empty-interval ;

! Basic Property of bitor: bits can never be taken away.  For both signed and
! unsigned integers this means that the number can only grow towards positive
! infinity.  Also, the significant bit range can never be larger than either of
! the operands.
! In case both intervals are positive:
! lower(i1 bitor i2) = max(lower(i1),lower(i2))
! upper(i1 bitor i2) = 2 ^ max(bit-length(upper(i1)), bit-length(upper(i2))) - 1
! In case both intervals are negative:
! lower(i1 bitor i2) = max(lower(i1),lower(i2))
! upper(i1 bitor i2) = -1
! In case one is negative and the other positive, simply assume the whole
! bit-range.  This case is not accurate though.
: interval-bitor ( i1 i2 -- i3 )
    [
        { { [ 2dup [ interval-nonnegative? ] both? ]
            [ [ max-lower-bound ] [ max-upper-bound ] 2bi bit-weight 1 bound- [a,b] ] }
          { [ 2dup [ interval-negative? ] both? ]
            [ max-lower-bound -1 [a,b] ] }
          [ interval-union interval-bit-weight [ bound-neg ] [ 1 bound- ] bi [a,b] ]
        } cond
    ] do-empty-interval ;

! Basic Property of bitxor: can always produce 0,  can never increase
! significant range
! If both operands are known to be negative, the sign bit(s) will be zero,
! always resulting in a positive number
: interval-bitxor ( i1 i2 -- i3 )
    [
        { { [ 2dup [ interval-nonnegative? ] both? ]
            [ max-upper-bound bit-weight 1 bound- [0,b] ] }
          { [ 2dup [ interval-negative? ] both? ]
            [ min-lower-bound bit-weight 1 bound- [0,b] ] }
          [ interval-union interval-bit-weight [ bound-neg ] [ 1 bound- ] bi [a,b] ]
        } cond
    ] do-empty-interval ;

GENERIC: interval-log2 ( i1 -- i2 )
M: empty-interval interval-log2 ;
M: full-interval interval-log2 drop [0,inf] ;
M: interval interval-log2
    to>> first 1 bound-max dup most-positive-fixnum bound>
    [ drop full-interval interval-log2 ]
    [ 1 + >integer log2 [0,b] ]
    if ;

: assume< ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,b) interval-intersect
    ] if ;

: assume<= ( i1 i2 -- i3 )
    dup special-interval? [ drop ] [
        to>> first [-inf,b] interval-intersect
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
        [ from>> first2 [ 1 bound+ ] unless ]
        [ to>> first2 [ 1 bound- ] unless ]
        bi [a,b]
    ] unless ;
