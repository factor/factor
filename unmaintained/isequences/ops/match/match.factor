! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.match
USING: generic kernel math sequences isequences.interface isequences.base ;


TUPLE: imatch sorted-s1 s2 ;

DEFER: ifind-c

: <i-match> ( s1 s2 -- imatch )
    dup i-length dup zero? [ 3drop 0 ]
    [ 1 = [ swap i-sort swap 0 i-at ifind-c <i> ] [ swap i-sort swap <imatch> ] if ] if ; inline 

: imatch-unpack ( imatch -- sorted-s1 s2 )
    dup imatch-sorted-s1 swap imatch-s2 ; inline 

DEFER: (ifind2-left-m)

: (ifind3-left-m) ( s1 v s e -- i )
    2dup >r >r + 2/ pick swap i-at left-side over i-cmp 0 <=
    [ r> r> swap over + 1+ 2/ swap (ifind2-left-m) ]
    [ r> r> over + 2/ (ifind2-left-m) ]
    if ; inline

: (ifind2-left-m) ( s1 v s e -- i )
    2dup = [ -roll 3drop ] [ (ifind3-left-m) ] if ; inline

: ifind-left-m ( s1 v -- i )
    over i-length 0 swap (ifind2-left-m) ; inline

DEFER: (ifind2-left)

: (ifind3-left) ( s1 v s e -- i )
    2dup >r >r + 2/ pick swap i-at left-side over i-cmp 0 <
    [ r> r> swap over + 1+ 2/ swap (ifind2-left) ]
    [ r> r> over + 2/ (ifind2-left) ]
    if ; inline

: (ifind2-left) ( s1 v s e -- i )
    2dup = [ -roll 3drop ] [ (ifind3-left) ] if ; inline

: ifind-left ( s1 v -- i )
    over i-length 0 swap (ifind2-left) ; inline

: icontains-left? ( s1 v -- ? )
    2dup ifind-left pick i-length dupd <
    [ rot swap i-at left-side i-cmp zero? ] [ 3drop f ] if ; inline

: (ifind-s2) ( s1 v -- sv )
    2dup ifind-left rot swap itail dup rot ifind-left-m ihead ## :: ; inline
    
: ifind-s ( s1 v -- sv )
    2dup icontains-left?
    [ (ifind-s2) ] [ 2drop 0 ] if ; inline

: iflatten ( s -- s )
    dup i-length dup zero?
    [ 2drop 0 ]
    [ 1 = [ 0 i-at left-side ] [ left-right [ iflatten ] 2apply ++ ] if ] if ; inline
    
: ifind-c ( s1 v -- s )
    ifind-s iflatten ; inline

: >>g++ ( s1 s2 -- imatch )
    <i-match> ; inline
    
: >>g-+ ( s1 s2 -- imatch )
    swap -- swap >>g++ ; inline

: >>g+- ( s1 s2 -- imatch )
    -- >>g++ -- ;

: >>g-- ( s1 s2 -- imatch )
    [ -- ] 2apply >>g++ -- ; inline

: >>g ( s1 s2 -- imatch )
    2dup [ neg? ] 2apply [ [ >>g-- ] [ >>g+- ] if ]
    [ [ >>g-+ ] [ >>g++ ] if ] if ; inline

M: object >> >>g ;
    
M: imatch i-length imatch-s2 i-length ;
M: imatch i-at swap imatch-unpack rot i-at tuck left-side ifind-c swap right-side <i-dual-sided> ;
M: imatch ileft imatch-unpack ileft <i-match> ;
M: imatch iright imatch-unpack iright <i-match> ;
M: imatch ihead (ihead) ;
M: imatch itail (itail) ;
M: imatch $$ imatch-unpack [ $$ ] 2apply quick-hash ;
