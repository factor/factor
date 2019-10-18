! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.minimum
USING: generic kernel math sequences isequences.interface isequences.base ;


TUPLE: imin left right ;

: <i-min> ( left right -- imin )
    2dup [ i-length ] 2apply min dup rot
    swap ihead -rot ihead swap <imin> ; inline
    
: imin-unpack ( imin -- left right )
    dup imin-left swap imin-right ; inline
    
: imin-v ( v1 v2 -- v )
    2dup [ left-side ] 2apply i-cmp dup zero?
    [ drop [ right-side ] 2apply 2dup i-cmp 0 < [ 2drop 0 ] [ nip :v: ] if ]
    [ 0 < [ 2drop 0 ] [ drop ] if ]
    if ; inline

: imin-ileft ( imin -- imin )
    imin-unpack ileft dup i-length rot swap ihead swap <i-min> ; inline

: imin-iright ( imin -- imin )
    imin-unpack dup ileft i-length rot swap itail swap iright <i-min> ; inline
    
: &&g++ ( s1 s2 -- imax )
    <i-min> ; inline

: &&g-+ ( s1 s2 -- imax )
    swap -- `` swap 2dup [ i-length ] 2apply neg + ++ && `` -- ; inline

: &&g+- ( s1 s2 -- imax )
    -- `` 2dup -roll [ i-length ] 2apply neg + ++ swap && `` -- ; inline

: &&g-- ( s1 s2 -- imax )
    [ -- `` ] 2apply 2dup [ i-length ] 2apply roll || -rot || && `` -- ; inline
    
: &&g ( s1 s2 -- imin )
    2dup [ neg? ] 2apply [ [ &&g-- ] [ &&g+- ] if ]
    [ [ &&g-+ ] [ &&g++ ] if ] if ; inline

M: object && &&g ;

M: imin i-length imin-left i-length ;
M: imin i-at swap imin-unpack swap pick i-at -rot swap i-at imin-v ;
M: imin ileft imin-ileft ;
M: imin iright imin-iright ;
M: imin ihead (ihead) ;
M: imin itail (itail) ;
M: imin $$ imin-unpack [ -- $$ neg ] 2apply quick-hash neg ;

! double dispatch integer/&&
GENERIC: integer/&& ( s1 s2 -- v )
M: object integer/&& swap &&g ;
M: integer && swap integer/&& ;
! integer optimization
M: integer integer/&& min ;
