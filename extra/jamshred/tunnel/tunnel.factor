! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators kernel locals math math.constants math.matrices math.order math.ranges math.vectors math.quadratic random sequences specialized-arrays.float vectors jamshred.oint ;
IN: jamshred.tunnel

: n-segments ( -- n ) 5000 ; inline

TUPLE: segment < oint number color radius ;
C: <segment> segment

: segment-number++ ( segment -- )
    [ number>> 1+ ] keep (>>number) ;

: random-color ( -- color )
    { 100 100 100 } [ random 100 / >float ] map first3 1.0 <rgba> ;

: tunnel-segment-distance ( -- n ) 0.4 ;
: random-rotation-angle ( -- theta ) pi 20 / ;

: random-segment ( previous-segment -- segment )
    clone dup random-rotation-angle random-turn
    tunnel-segment-distance over go-forward
    random-color >>color dup segment-number++ ;

: (random-segments) ( segments n -- segments )
    dup 0 > [
        [ dup peek random-segment over push ] dip 1- (random-segments)
    ] [ drop ] if ;

: default-segment-radius ( -- r ) 1 ;

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
    #! return segments between from and to, after clamping from and to to
    #! valid values
    [ sequence-index-range [ clamp-to-range ] curry bi@ ] keep <slice> ;

: nearer-segment ( segment segment oint -- segment )
    #! return whichever of the two segments is nearer to the oint
    [ 2dup ] dip tuck distance [ distance ] dip < -rot ? ;

: (find-nearest-segment) ( nearest next oint -- nearest ? )
    #! find the nearest of 'next' and 'nearest' to 'oint', and return
    #! t if the nearest hasn't changed
    pick [ nearer-segment dup ] dip = ;

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
    number>> over [
        [ nearest-segment-forward ] 3keep nearest-segment-backward
    ] dip nearer-segment ;

: get-segment ( segments n -- segment )
    over sequence-index-range clamp-to-range swap nth ;

: next-segment ( segments current-segment -- segment )
    number>> 1+ get-segment ;

: previous-segment ( segments current-segment -- segment )
    number>> 1- get-segment ;

: heading-segment ( segments current-segment heading -- segment )
    #! the next segment on the given heading
    over forward>> v. 0 <=> {
        { +gt+ [ next-segment ] }
        { +lt+ [ previous-segment ] }
        { +eq+ [ nip ] } ! current segment
    } case ;

:: distance-to-next-segment ( current next location heading -- distance )
    [let | cf [ current forward>> ] |
        cf next location>> v. cf location v. - cf heading v. / ] ;

:: distance-to-next-segment-area ( current next location heading -- distance )
    [let | cf [ current forward>> ]
           h [ next current half-way-between-oints ] |
        cf h v. cf location v. - cf heading v. / ] ;

: vector-to-centre ( seg loc -- v )
    over location>> swap v- swap forward>> proj-perp ;

: distance-from-centre ( seg loc -- distance )
    vector-to-centre norm ;

: wall-normal ( seg oint -- n )
    location>> vector-to-centre normalize ;

: distant ( -- n ) 1000 ;

: max-real ( a b -- c )
    #! sometimes collision-coefficient yields complex roots, so we ignore these (hack)
    dup real? [
        over real? [ max ] [ nip ] if
    ] [
        drop dup real? [ drop distant ] unless
    ] if ;

:: collision-coefficient ( v w r -- c )
    v norm 0 = [
        distant
    ] [
        [let* | a [ v dup v. ]
                b [ v w v. 2 * ]
                c [ w dup v. r sq - ] |
            c b a quadratic max-real ]
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
    [ wall-normal ] [ forward>> swap reflect ] [ (>>forward) ] tri ;

: bounce-left ( segment oint -- )
    #! must be done after forward
    [ forward>> vneg ] dip [ left>> swap reflect ]
    [ forward>> proj-perp normalize ] [ (>>left) ] tri ;

: bounce-up ( segment oint -- )
    #! must be done after forward and left!
    nip [ forward>> ] [ left>> cross ] [ (>>up) ] tri ;

: bounce-off-wall ( oint segment -- )
    swap [ bounce-forward ] [ bounce-left ] [ bounce-up ] 2tri ;

