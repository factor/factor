! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: homology
USING: arrays hashtables io kernel math matrices namespaces
prettyprint sequences topology words ;

! Utilities
: (lengthen) ( seq n -- seq )
    over length - f <array> append ;

: lengthen ( sim sim -- sim sim )
    2dup max-length tuck (lengthen) >r (lengthen) r> ;

: <point> ( -- sim ) gensym 1array ;

: (C) ( point sim -- sim )
    [ [ append natural-sort ] map-with ] map-with ;

: (\/) ( sim sim -- sim )
    lengthen [ append natural-sort ] 2map ;

! Simplicial complexes
SYMBOL: basepoint

: {*} ( -- sim )
    #! Initial object in category
    { { { basepoint } } } ;

: \/ ( sim sim -- sim )
    #! Glue two complexes at base point
    (\/) [ prune ] map ;

: +point ( sim -- sim )
    #! Adjoint an isolated point
    unclip <point> add add* ;

: C ( sim -- sim )
    #! Cone on a space
    [
        <point> dup 1array >r swap (C) r> add*
    ] keep (\/) ;

: S ( sim -- sim )
    #! Suspension
    [
        <point> <point> 2dup 2array >r
        pick (C) >r swap (C) r> (\/) r> add*
    ] keep (\/) ;

: S^0 ( -- sim )
    #! Degenerate sphere -- two points
    {*} +point ;

: S^ ( n -- sim )
    #! Sphere
    S^0 swap [ S ] times ;

: D^ ( n -- sim )
    #! Disc
    1- S^ C ;

! Boundary operator
: (d) ( seq -- chain )
    dup length 1 <= [
        H{ }
    ] [
        dup length [ 2dup >r remove-nth r> -1^ ] map>hash
    ] if nip ;

: d ( chain -- chain )
    [ (d) ] linear-op ;

: d-matrix ( n sim -- matrix )
    [ ?nth ] 2keep >r 1- r> ?nth [ (d) ] op-matrix ;

: ker/im-d ( sim -- seq )
    #! Dimension of kernel of C_{n-1} --> C_n, subsp. of C_{n-1}
    #! Dimension of image  C_{n-1} --> C_n, subsp. of C_n
    dup length [ swap d-matrix null/rank 2array ] map-with ;

: H ( sim -- seq ) ker/im-d (H) ;
