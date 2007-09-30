USING: arrays kernel jamshred.oint math math.functions math.vectors
math.constants random sequences vectors ;
IN: jamshred.tunnel

: n-segments ( -- n ) 100 ; inline

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

: tunnel-segment-distance ( -- n ) 0.5 ;
: random-rotation-angle ( -- theta ) pi 6 / ;

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
    { 0 0 0 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <segment> ;

: random-segments ( n -- segments )
    initial-segment 1vector swap (random-segments) ;

: simple-segment ( n -- segment )
    random-color default-segment-radius pick { 0 0 -1 } n*v
    { 0 0 -1 } { 0 1 0 } { -1 0 0 } <segment> ;

: simple-segments ( n -- segments )
    [ simple-segment ] map ;

TUPLE: tunnel segments ;

C: <tunnel> tunnel

: <random-tunnel> ( -- tunnel )
    n-segments random-segments <tunnel> ;

: <straight-tunnel> ( -- tunnel )
    n-segments simple-segments <tunnel> ;

: nearer-segment ( segment segment oint -- segment )
    #! return whichever of the two segments is nearer to the oint
    >r 2dup r> tuck distance >r distance r> < -rot ? ;

: find-nearest-segment ( oint segments -- segment )
    tuck first swap [ -rot nearer-segment ] curry reduce ;
    
: nearest-segment-forward ( segments oint start -- segment )
    rot dup length swap <slice> find-nearest-segment ;

: nearest-segment-backward ( segments oint start -- segment )
    1+ 0 swap rot <slice> <reversed> find-nearest-segment ;

: nearest-segment ( tunnel oint start-segment -- segment )
    #! find the segment nearest to 'oint', and return it.
    #! start looking at segment 'start-segment'
    segment-number over >r
    >r >r tunnel-segments r> r>
    [ nearest-segment-forward ] 3keep
    nearest-segment-backward r> nearer-segment ;
