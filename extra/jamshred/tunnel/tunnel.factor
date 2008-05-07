! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators float-arrays kernel jamshred.oint locals math math.functions math.constants math.matrices math.order math.ranges math.vectors math.quadratic random sequences vectors ;
IN: jamshred.tunnel

: n-segments ( -- n ) 5000 ; inline

TUPLE: segment < oint number color radius ;
C: <segment> segment

: segment-vertex ( theta segment -- vertex )
     tuck 2dup up>> swap sin v*n
     >r left>> swap cos v*n r> v+
     swap location>> v+ ;

: segment-vertex-normal ( vertex segment -- normal )
    location>> swap v- normalize ;

: segment-vertex-and-normal ( segment theta -- vertex normal )
    swap [ segment-vertex ] keep dupd segment-vertex-normal ;

: equally-spaced-radians ( n -- seq )
    #! return a sequence of n numbers between 0 and 2pi
    dup [ / pi 2 * * ] curry map ;

: segment-number++ ( segment -- )
    [ number>> 1+ ] keep (>>number) ;

: random-color ( -- color )
    { 100 100 100 } [ random 100 / >float ] map { 1.0 } append ;

: tunnel-segment-distance ( -- n ) 0.4 ;
: random-rotation-angle ( -- theta ) pi 20 / ;

: random-segment ( previous-segment -- segment )
    clone dup random-rotation-angle random-turn
    tunnel-segment-distance over go-forward
    random-color over set-segment-color dup segment-number++ ;

: (random-segments) ( segments n -- segments )
    dup 0 > [
        >r dup peek random-segment over push r> 1- (random-segments)
    ] [
        drop
    ] if ;

: default-segment-radius ( -- r ) 1 ;

: initial-segment ( -- segment )
    F{ 0 0 0 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 }
    0 random-color default-segment-radius <segment> ;

: random-segments ( n -- segments )
    initial-segment 1vector swap (random-segments) ;

: simple-segment ( n -- segment )
    [ F{ 0 0 -1 } n*v F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } ] keep
    random-color default-segment-radius <segment> ;

: simple-segments ( n -- segments )
    [ simple-segment ] map ;

: <random-tunnel> ( -- segments )
    n-segments random-segments ;

: <straight-tunnel> ( -- segments )
    n-segments simple-segments ;

: sub-tunnel ( from to sements -- segments )
    #! return segments between from and to, after clamping from and to to
    #! valid values
    [ sequence-index-range [ clamp-to-range ] curry bi@ ] keep <slice> ;

: nearer-segment ( segment segment oint -- segment )
    #! return whichever of the two segments is nearer to the oint
    >r 2dup r> tuck distance >r distance r> < -rot ? ;

: (find-nearest-segment) ( nearest next oint -- nearest ? )
    #! find the nearest of 'next' and 'nearest' to 'oint', and return
    #! t if the nearest hasn't changed
    pick >r nearer-segment dup r> = ;

: find-nearest-segment ( oint segments -- segment )
    dup first swap rest-slice rot [ (find-nearest-segment) ] curry
    find 2drop ;
    
: nearest-segment-forward ( segments oint start -- segment )
    rot dup length swap <slice> find-nearest-segment ;

: nearest-segment-backward ( segments oint start -- segment )
    swapd 1+ 0 spin <slice> <reversed> find-nearest-segment ;

: nearest-segment ( segments oint start-segment -- segment )
    #! find the segment nearest to 'oint', and return it.
    #! start looking at segment 'start-segment'
    segment-number over >r
    [ nearest-segment-forward ] 3keep
    nearest-segment-backward r> nearer-segment ;

: vector-to-centre ( seg loc -- v )
    over location>> swap v- swap forward>> proj-perp ;

: distance-from-centre ( seg loc -- distance )
    vector-to-centre norm ;

: wall-normal ( seg oint -- n )
    location>> vector-to-centre normalize ;

: from ( seg loc -- radius d-f-c )
    dupd location>> distance-from-centre [ radius>> ] dip ;

: distance-from-wall ( seg loc -- distance ) from - ;
: fraction-from-centre ( seg loc -- fraction ) from / ;
: fraction-from-wall ( seg loc -- fraction )
    fraction-from-centre 1 swap - ;

: distant 10 ; inline

:: (collision-coefficient) ( -b sqrt(b^2-4ac) 2a -- c )
    sqrt(b^2-4ac) complex? [
        distant
    ] [
        -b sqrt(b^2-4ac) + 2a /
        -b sqrt(b^2-4ac) - 2a / max ! the -ve answer is behind us
    ] if ;

:: collision-coefficient ( v w -- c )
    [let* | a [ v dup v. ]
            b [ v w v. 2 * ]
            c [ w dup v. v dup v. - ] |
        c b a quadratic [ real-part ] bi@ max ] ;

: sideways-heading ( oint segment -- v )
    [ forward>> ] bi@ proj-perp ;

: sideways-relative-location ( oint segment -- loc )
    [ [ location>> ] bi@ v- ] keep forward>> proj-perp ;

: collision-vector ( oint segment -- v )
        dupd [ sideways-heading ] [ sideways-relative-location ] 2bi
        collision-coefficient swap forward>> n*v ;

USING: prettyprint jamshred.log io.streams.string ;
: distance-to-collision ( oint segment -- distance )
    collision-vector norm [ dup . ] with-string-writer jamshred-log ;

: bounce-forward ( segment oint -- )
    [ wall-normal ] [ forward>> swap reflect ] [ (>>forward) ] tri ;

: bounce-left ( segment oint -- )
    [ forward>> vneg ] dip [ left>> swap reflect ] [ (>>left) ] bi ;

: bounce-up ( segment oint -- )
    #! must be done after forward and left!
    nip [ forward>> ] [ left>> cross ] [ (>>up) ] tri ;

: bounce ( oint segment -- )
    swap [ bounce-forward ] [ bounce-left ] [ bounce-up ] 2tri ;

