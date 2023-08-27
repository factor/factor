! Copyright (C) 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types colors combinators jamshred.oint
kernel literals math math.constants math.order math.quadratic
math.vectors random sequences specialized-arrays vectors ;
FROM: jamshred.oint => distance ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: jamshred.tunnel

CONSTANT: n-segments 5000

TUPLE: segment < oint number color radius ;
C: <segment> segment

: segment-number++ ( segment -- )
    [ number>> 1 + ] keep number<< ;

: clamp-length ( n seq -- n' )
    0 swap length clamp ;

: random-color ( -- color )
    { 100 100 100 } [ random 100 / >float ] map first3 1.0 <rgba> ;

CONSTANT: tunnel-segment-distance 0.4
CONSTANT: random-rotation-angle $[ pi 20 / ]

: random-segment ( previous-segment -- segment )
    clone dup random-rotation-angle random-turn
    tunnel-segment-distance over go-forward
    random-color >>color dup segment-number++ ;

: (random-segments) ( segments n -- segments )
    [ dup last random-segment suffix! ] times ;

CONSTANT: default-segment-radius 1

: initial-segment ( -- segment )
    float-array{ 0 0 0 } float-array{ 0 0 -1 } float-array{ 0 1 0 } float-array{ -1 0 0 }
    0 random-color default-segment-radius <segment> ;

: random-segments ( n -- segments )
    initial-segment 1vector swap (random-segments) ;

: simple-segment ( n -- segment )
    [ float-array{ 0 0 -1 } n*v float-array{ 0 0 -1 } float-array{ 0 1 0 } float-array{ -1 0 0 } ] keep
    random-color default-segment-radius <segment> ;

: simple-segments ( n -- segments )
    [ simple-segment ] map ;

: <random-tunnel> ( -- segments )
    n-segments random-segments ;

: <straight-tunnel> ( -- segments )
    n-segments simple-segments ;

: sub-tunnel ( from to segments -- segments )
    ! return segments between from and to, after clamping from and to to
    ! valid values
    [ '[ _ clamp-length ] bi@ ] keep <slice> ;

: get-segment ( segments n -- segment )
    over clamp-length swap nth ;

: next-segment ( segments current-segment -- segment )
    number>> 1 + get-segment ;

: previous-segment ( segments current-segment -- segment )
    number>> 1 - get-segment ;

: heading-segment ( segments current-segment heading -- segment )
    ! the next segment on the given heading
    over forward>> vdot 0 <=> {
        { +gt+ [ next-segment ] }
        { +lt+ [ previous-segment ] }
        { +eq+ [ nip ] } ! current segment
    } case ;

:: distance-to-next-segment ( current next location heading -- distance )
    current forward>> :> cf
    cf next location>> vdot cf location vdot - cf heading vdot / ;

:: distance-to-next-segment-area ( current next location heading -- distance )
    current forward>> :> cf
    next current half-way-between-oints :> h
    cf h vdot cf location vdot - cf heading vdot / ;

: vector-to-center ( seg loc -- v )
    over location>> swap v- swap forward>> proj-perp ;

: distance-from-center ( seg loc -- distance )
    vector-to-center norm ;

: wall-normal ( seg oint -- n )
    location>> vector-to-center normalize ;

CONSTANT: distant 1000

: max-real ( a b -- c )
    ! sometimes collision-coefficient yields complex roots, so we ignore these (hack)
    dup real? [
        over real? [ max ] [ nip ] if
    ] [
        drop dup real? [ drop distant ] unless
    ] if ;

:: collision-coefficient ( v w r -- c )
    v norm 0 = [
        distant
    ] [
        v dup vdot :> a
        v w vdot 2 * :> b
        w dup vdot r sq - :> c
        c b a quadratic max-real
    ] if ;

: sideways-heading ( oint segment -- v )
    [ forward>> ] bi@ proj-perp ;

: sideways-relative-location ( oint segment -- loc )
    [ [ location>> ] bi@ v- ] keep forward>> proj-perp ;

: (distance-to-collision) ( oint segment -- distance )
    [ sideways-heading ] [ sideways-relative-location ]
    [ nip radius>> ] 2tri collision-coefficient ;

: collision-vector ( oint segment -- v )
    dupd (distance-to-collision) swap forward>> n*v ;

: bounce-forward ( segment oint -- )
    [ wall-normal ] [ forward>> swap reflect ] [ forward<< ] tri ;

: bounce-left ( segment oint -- )
    ! must be done after forward
    [ forward>> vneg ] dip [ left>> swap reflect ]
    [ forward>> proj-perp normalize ] [ left<< ] tri ;

: bounce-up ( segment oint -- )
    ! must be done after forward and left!
    nip [ forward>> ] [ left>> cross ] [ up<< ] tri ;

: bounce-off-wall ( oint segment -- )
    swap [ bounce-forward ] [ bounce-left ] [ bounce-up ] 2tri ;
