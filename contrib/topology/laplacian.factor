! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables hopf kernel math matrices namespaces
sequences topology ;
IN: laplacian

: ((i)) ( x y -- i_y[x] )
    1 swap associate boundaries set d ;

: (i) ( x y -- i_y[x] )
    [ [ ((i)) ] each ] with-scope ;

: i ( x y -- i_y[x] )
    #! Adjoint of left multiplication by y
    [ >h ] 2apply [ dupd concat (i) ] linear-op nip ;

SYMBOL: top-class

SYMBOL: dimension

: set-generators ( seq -- )
    dup generators set
    1 [ h* ] reduce top-class set ;

: star ( x -- *x )
    #! Hodge star involution
    top-class get swap i ;

: <,>* ( a b -- n )
    #! Hodge inner product
    star h* star co1 ;

: (d*) ( x -- d*[x] )
    [ length 1+ generators get length * 1+ -1^ ] keep
    star d star h* ;

: d* ( x -- d*[x] )
    #! Adjoint of the differential
    >h [ concat (d*) ] linear-op ;

: [,] ( x y -- z )
    #! Lie bracket
    h* d* ;

: L ( z -- Lz )
    #! Laplacian.
    [ d d* ] keep d* d l+ ;

: L-matrix ( basis -- matrix )
    dup [ concat L ] op-matrix ;

: harmonics ( basis -- seq )
    dup L-matrix row-reduce
    [ 0 >h [ >r concat r> h* l+ ] 2reduce ] map-with
    [ hash-empty? not ] subset ;
