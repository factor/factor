! Copyright (C) 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays float-arrays kernel jamshred.oint locals math math.functions math.constants math.matrices math.order math.ranges math.vectors random sequences vectors ;
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
    dup segment-number 1+ swap set-segment-number ;

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

: distance-from-centre ( oint segment -- distance )
    perpendicular-distance ;

: distance-from-wall ( oint segment -- distance )
    tuck distance-from-centre swap segment-radius swap - ;

: fraction-from-centre ( oint segment -- fraction )
    tuck distance-from-centre swap segment-radius / ;

: fraction-from-wall ( oint segment -- fraction )
    fraction-from-centre 1 swap - ;

: sideways-heading ( oint segment -- v )
    [ forward>> ] bi@ proj-perp ;

! : facing-nearest-wall? ( oint segment -- ? )
!     [ [ location>> ] bi@ distance ]
!     [ sideways-heading ]
!     [ [ location>> ] bi@ [ v+ ] dip distance ] tri < ;

! : distance-to-collision ( oint segment -- distance )
! ! TODO: this isn't right. If oint is facing away from the wall then it should return a much bigger distance...
!     #! distance on the oint's heading to the segment wall
!     facing-nearest-wall? [
!         [ sideways-heading norm ]
!         [ distance-from-wall ] 2bi swap /
!     ] [
!     ] if ;

:: (collision-coefficient) ( -2b sqrt(b^2-2ac) 2a -- c )
    -2b sqrt(b^2-2ac) + 2a /
    -2b sqrt(b^2-2ac) - 2a / max ; ! the -ve answer is behind us (I think..)

:: collision-coefficient ( v w -- c )
    [let* | a [ v dup v. ]
            b [ v w v. 2 * ]
            c [ w dup v. v dup v. - ] |
        b -2 * b sq a c * 2 * - sqrt a 2 * (collision-coefficient) ] ;

: distance-to-collision ( oint segment -- distance )
    [ sideways-heading ] [ [ location>> ] bi@ v- collision-coefficient ]
    [ drop forward>> n*v norm ] 2tri ;

:: (wall-normal) ( seg loc -- n )
    [let* | back [ loc seg location>> v- ]
           back-proj [ back seg forward>> proj ]
           perp-point [ loc back-proj v- ] |
        perp-point seg location>> v- normalize ] ;

: wall-normal ( segment oint -- n )
    location>> (wall-normal) ;

: bounce-forward ( segment oint -- )
    [ wall-normal ] [ swap reflect ] [ (>>forward) ] tri ;

: bounce-up ( oint segment -- )
    2drop ; ! TODO

: bounce-left ( oint segment -- )
    2drop ; ! TODO

! : bounce ( oint segment -- )
!     [ swap bounce-forward ]
!     [ bounce-up ]
!     [ bounce-left ] 2tri ;

: bounce ( oint segment -- )
    drop 0.01 left-pivot ; ! just temporary
