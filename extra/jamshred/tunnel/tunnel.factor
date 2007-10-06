USING: arrays float-arrays kernel jamshred.oint math math.functions
math.ranges math.vectors math.constants random sequences vectors ;
IN: jamshred.tunnel

: n-segments ( -- n ) 5000 ; inline

TUPLE: segment number color radius ;

: <segment> ( number color radius location forward up left -- segment )
    <oint> >r segment construct-boa r> over set-delegate ;

: segment-vertex ( theta segment -- vertex )
     tuck 2dup oint-up swap sin v*n
     >r oint-left swap cos v*n r> v+
     swap oint-location v+ ;

: segment-vertex-normal ( vertex segment -- normal )
    oint-location swap v- normalize ;

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
    0 random-color default-segment-radius
    F{ 0 0 0 } F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } <segment> ;

: random-segments ( n -- segments )
    initial-segment 1vector swap (random-segments) ;

: simple-segment ( n -- segment )
    random-color default-segment-radius pick F{ 0 0 -1 } n*v
    F{ 0 0 -1 } F{ 0 1 0 } F{ -1 0 0 } <segment> ;

: simple-segments ( n -- segments )
    [ simple-segment ] map ;

: <random-tunnel> ( -- segments )
    n-segments random-segments ;

: <straight-tunnel> ( -- segments )
    n-segments simple-segments ;

: sub-tunnel ( from to sements -- segments )
    #! return segments between from and to, after clamping from and to to
    #! valid values
    [ sequence-index-range [ clamp-to-range ] curry 2apply ] keep <slice> ;

: nearer-segment ( segment segment oint -- segment )
    #! return whichever of the two segments is nearer to the oint
    >r 2dup r> tuck distance >r distance r> < -rot ? ;

: (find-nearest-segment) ( nearest next oint -- nearest ? )
    #! find the nearest of 'next' and 'nearest' to 'oint', and return
    #! t if the nearest hasn't changed
    pick >r nearer-segment dup r> = ;

: find-nearest-segment ( oint segments -- segment )
    dup first swap 1 tail-slice rot [ (find-nearest-segment) ] curry
    find 2drop ;
    
: nearest-segment-forward ( segments oint start -- segment )
    rot dup length swap <slice> find-nearest-segment ;

: nearest-segment-backward ( segments oint start -- segment )
    swapd 1+ 0 swap rot <slice> <reversed> find-nearest-segment ;

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
