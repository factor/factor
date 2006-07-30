! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors hashtables io kernel math matrices
namespaces parser prettyprint sequences topology words ;
IN: hopf

! Finitely generated Hopf algebras.

! An element is represented as a hashtable mapping basis
! elements to scalars.

! A basis element is a pair of arrays, odd/even generators.

! Define degrees using deg=

! Add elements using l+

! Multiply elements using h*

! The co-unit is co1

! Print elements using h.

! Define the differential using d=

! Differentiate using d

: ?set-hash ( value key hash/f -- hash )
    [ [ set-hash ] keep ] [ associate ] if* ;

SYMBOL: degrees

: deg= degrees [ ?set-hash ] change ;

: deg degrees get ?hash ;

: h. ( vec -- )
    hash>alist [ first2 >r concat r> 2array ] map (l.) ;

: <basis-elt> ( generators -- { odd even } )
    V{ } clone V{ } clone
    rot [
        3dup deg odd? [ drop ] [ nip ] if push
    ] each [ >array ] 2apply 2array ;

: >h ( obj -- vec )
    {
        { [ dup not ] [ drop 0 >h ] }
        { [ dup number? ] [ { { } { } } associate ] }
        { [ dup array? ] [ <basis-elt> 1 swap associate ] }
        { [ dup hashtable? ] [ ] }
        { [ t ] [ 1array >h ] }
    } cond ;

: co1 ( vec -- n ) { { } { } } swap hash [ 0 ] unless* ;

: permutation ( seq -- perm )
    dup natural-sort [ swap index ] map-with ;

: (inversions) ( n seq -- n )
    [ > ] subset-with length ;

: inversions ( seq -- n )
    0 swap dup length [
        swap [ nth ] 2keep swap 1+ tail-slice (inversions) +
    ] each-with ;

: duplicates? ( seq -- ? )
    dup prune [ length ] 2apply > ;

: (odd*) ( n terms -- n terms )
    dup duplicates? [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap natural-sort
    ] if ;

: odd* ( n terms1 terms2 -- n terms )
    append (odd*) ;

: even* ( terms1 terms2 -- terms )
    append natural-sort ;

: (h*) ( n basis1 basis2 -- n basis )
    [
        [ first ] 2apply odd*
    ] 2keep [ second ] 2apply even* 2array ;

: h* ( x y -- x.y )
    [ >h ] 2apply [
        [
            rot [
                2swap [
                    swapd * -rot (h*) +@
                ] 2keep
            ] hash-each 2drop
        ] hash-each-with
    ] make-hash canonicalize ;

SYMBOL: boundaries

: d= ( value basis -- )
    boundaries [ ?set-hash ] change ;

: ((d)) ( basis -- value ) boundaries get ?hash ;

: dx.y ( x y -- vec ) >r ((d)) r> h* ;

DEFER: (d)

: x.dy ( x y -- vec ) [ (d) h* ] keep [ deg ] map sum -1^ h* ;

: (d) ( product -- value )
    #! d(x.y)=dx.y + (-1)^deg y x.dy
    dup empty?
    [ drop H{ } ] [ unclip swap [ x.dy ] 2keep dx.y l+ ] if ;

: d ( x -- dx )
    >h [ concat (d) ] linear-op ;

: d-matrix ( n sim -- matrix )
    [ ?nth ] 2keep >r 1+ r> ?nth [ concat (d) ] op-matrix ;

: ker/im-d ( sim -- seq )
    #! Dimension of kernel of C_{n+1} --> C_n, subsp. of C_{n+1}
    #! Dimension of image  C_{n+1} --> C_n, subsp. of C_n
    dup length [ swap d-matrix null/rank 2array ] map-with ;

: nth-bit? ( m bit# -- ? )
    1 swap shift bitand 0 > ;

: nth-basis-elt ( generators n -- elt )
    over length [
        ( generators n bit# -- )
        3dup nth-bit? [ nth ] [ 2drop f ] if
    ] map [ ] subset 2nip ;

SYMBOL: generators

: basis ( generators -- seq )
    [
        dup length 1+ [ drop V{ } clone ] map \ basis set
        1 over length shift [
            nth-basis-elt dup length \ basis get nth push
        ] each-with
        \ basis get [ [ { } 2array ] map ] map
    ] with-scope ;

: H* ( -- seq ) generators get basis ker/im-d (H*) ;
