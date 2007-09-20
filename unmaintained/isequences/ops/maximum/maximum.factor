! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: isequences.ops.maximum
USING: generic kernel math sequences isequences.interface isequences.base ;



TUPLE: imax left right ;

: imax-unpack ( imax -- left right )
    dup imax-left swap imax-right ; inline

: nmax ( s n -- s )
    i-length over i-length - dup 0 <= [ drop ] [ ++ ] if ; inline

: <i-max> ( s1 s2 -- imax )
    dup i-length pick swap nmax -rot swap nmax <imax> ; inline
    
: min## ( s1 s2 -- minimum )
    [ i-length ] 2apply min ; inline
    
: ||g++ ( s1 s2 -- imax )
    2dup [ i-length ] 2apply zero? [ 2drop ] [ zero? [ nip ] [ <i-max> ] if ] if ; inline

: ||g-+ ( s1 s2 -- imax )
    swap -- `` swap 2dup min## -rot || swap ihead ; inline

: ||g+- ( s1 s2 -- imax )
   -- `` 2dup min## -rot || swap ihead ; inline

: ||g-- ( s1 s2 -- imax )
    [ -- `` ] 2apply 2dup min## -rot || swap ihead `` -- ; inline

: mcut-point ( imax -- i )
    imax-unpack [ ileft i-length ] 2apply 2dup < [ drop ] [ nip ] if ; inline
    
: imax-ileft ( imax -- imax ) 
    dup i-length 1 =
    [ drop 0 ]
    [ dup mcut-point swap imax-unpack pick ihead -rot swap ihead swap || ]
    if ; inline

: imax-iright ( imax -- imax )
    dup i-length 1 =
    [ drop 0 ]
    [ dup mcut-point swap imax-unpack pick itail -rot swap itail swap || ]
    if ; inline


: ||g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ ||g-- ] [ ||g+- ] if ]
    [ [ ||g-+ ] [ ||g++ ] if ] if ; inline

M: object || ||g ;

! double dispatch integer/||
GENERIC: integer/|| ( s1 s2 -- v )
M: object integer/|| swap ||g ;
M: integer || swap integer/|| ;
! integer optimization
M: integer integer/|| max ;

M: imax i-at swap imax-unpack pick i-at -rot swap i-at swap ++ ;
M: imax i-length imax-left i-length ;
M: imax ileft imax-ileft ;
M: imax iright imax-iright ;
M: imax ihead (ihead) ;
M: imax itail (itail) ;
M: imax $$ imax-unpack [ $$ -2 shift ] 2apply quick-hash ;

