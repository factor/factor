! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs hashtables assocs io kernel math
math.vectors math.matrices math.matrices.elimination namespaces
parser prettyprint sequences words combinators math.parser
splitting sorting shuffle sets math.order ;
IN: koszul

! Utilities
: -1^ ( m -- n ) odd? -1 1 ? ;

: >alt ( obj -- vec )
    {
        { [ dup not ] [ drop 0 >alt ] }
        { [ dup number? ] [ { } associate ] }
        { [ dup array? ] [ 1 swap associate ] }
        { [ dup hashtable? ] [ ] }
        [ 1array >alt ]
    } cond ;

: canonicalize ( assoc -- assoc' )
    [ nip zero? not ] assoc-filter ;

SYMBOL: terms

: with-terms ( quot -- hash )
    [
        H{ } clone terms set call terms get canonicalize
    ] with-scope ; inline

! Printing elements
: num-alt. ( n -- str )
    {
        { 1 [ " + " ] }
        { -1 [ " - " ] }
        [ number>string " + " prepend ]
    } case ;

: (alt.) ( basis n -- str )
    over empty? [
        nip number>string
    ] [
        num-alt.
        swap [ name>> ] map "." join
        append
    ] if ;

: alt. ( assoc -- )
    dup assoc-empty? [
        drop 0 .
    ] [
        [ (alt.) ] { } assoc>map concat " + " ?head drop print
    ] if ;

! Addition
: (alt+) ( x -- )
    terms get [ [ swap +@ ] assoc-each ] bind ;

: alt+ ( x y -- x+y )
    [ >alt ] bi@ [ (alt+) (alt+) ] with-terms ;

! Multiplication
: alt*n ( vec n -- vec )
    dup zero? [
        2drop H{ }
    ] [
        [ * ] curry assoc-map
    ] if ;

: permutation ( seq -- perm )
    [ natural-sort ] keep [ index ] curry map ;

: (inversions) ( n seq -- n )
    [ > ] with filter length ;

: inversions ( seq -- n )
    0 swap [ length ] keep [
        [ nth ] 2keep swap 1+ tail-slice (inversions) +
    ] curry each ;

: duplicates? ( seq -- ? )
    dup prune [ length ] bi@ > ;

: (wedge) ( n basis1 basis2 -- n basis )
    append dup duplicates? [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap natural-sort
    ] if ;

: wedge ( x y -- x.y )
    [ >alt ] bi@ [
        swap [
            [
                2swap [
                    swapd * -rot (wedge) +@
                ] 2keep
            ] assoc-each 2drop
        ] curry assoc-each
    ] H{ } make-assoc canonicalize ;

! Differential
SYMBOL: boundaries

: d= ( value basis -- )
    boundaries [ ?set-at ] change ;

: ((d)) ( basis -- value ) boundaries get at ;

: dx.y ( x y -- vec ) [ ((d)) ] dip wedge ;

DEFER: (d)

: x.dy ( x y -- vec ) (d) wedge -1 alt*n ;

: (d) ( product -- value )
    [ H{ } ] [ unclip swap [ x.dy ] 2keep dx.y alt+ ] if-empty ;

: linear-op ( vec quot -- vec )
        [
        [
            -rot [ swap call ] dip alt*n (alt+)
        ] curry assoc-each
    ] with-terms ; inline

: d ( x -- dx )
    >alt [ (d) ] linear-op ;

! Interior product
: (interior) ( y basis-elt -- i_y[basis-elt] )
    2dup index dup [
        -rot remove associate
    ] [
        3drop 0
    ] if ;

: interior ( x y -- i_y[x] )
    #! y is a generator
    swap >alt [ dupd (interior) ] linear-op nip ;

! Computing a basis
: graded ( seq -- seq )
    dup 0 [ length max ] reduce 1+ [ V{ } clone ] replicate
    [ dup length pick nth push ] reduce ;

: nth-basis-elt ( generators n -- elt )
    over length [
        3dup bit? [ nth ] [ 2drop f ] if
    ] map sift 2nip ;

: basis ( generators -- seq )
    natural-sort dup length 2^ [ nth-basis-elt ] with map ;

: (tensor) ( seq1 seq2 -- seq )
    [
        [ prepend natural-sort ] curry map
    ] with map concat ;

: tensor ( graded-basis1 graded-basis2 -- bigraded-basis )
    [ [ swap (tensor) ] curry map ] with map ;

! Computing cohomology
: (op-matrix) ( range quot basis-elt -- row )
    swap call [ at 0 or ] curry map ; inline

: op-matrix ( domain range quot -- matrix )
    rot [ (op-matrix) ] with with map ; inline

: d-matrix ( domain range -- matrix )
    [ (d) ] op-matrix ;

: dim-im/ker-d ( domain range -- null/rank )
    d-matrix null/rank 2array ;

! Graded by degree
: (graded-ker/im-d) ( n seq -- null/rank )
    #! d: C(n) ---> C(n+1)
    [ ?nth ] [ [ 1+ ] dip ?nth ] 2bi
    dim-im/ker-d ;

: graded-ker/im-d ( graded-basis -- seq )
    [ length ] keep [ (graded-ker/im-d) ] curry map ;

: graded-betti ( generators -- seq )
    basis graded graded-ker/im-d unzip but-last 0 prefix v- ;

! Bi-graded for two-step complexes
: (bigraded-ker/im-d) ( u-deg z-deg bigraded-basis -- null/rank )
    #! d: C(u,z) ---> C(u+2,z-1)
    [ ?nth ?nth ] 3keep [ [ 2 + ] dip 1 - ] dip ?nth ?nth
    dim-im/ker-d ;

: bigraded-ker/im-d ( bigraded-basis -- seq )
    dup length [
        over first length [
            [ 2dup ] dip spin (bigraded-ker/im-d)
        ] map 2nip
    ] with map ;

: bigraded-betti ( u-generators z-generators -- seq )
    [ basis graded ] bi@ tensor bigraded-ker/im-d
    [ [ [ first ] map ] map ] keep
    [ [ second ] map 2 head* { 0 0 } prepend ] map
    rest dup first length 0 <array> suffix
    [ v- ] 2map ;

! Laplacian
: m.m' ( matrix -- matrix' ) dup flip m. ;
: m'.m ( matrix -- matrix' ) dup flip swap m. ;

: empty-matrix? ( matrix -- ? )
    [ t ] [ first empty? ] if-empty ;

: ?m+ ( m1 m2 -- m3 )
    over empty-matrix? [
        nip
    ] [
        dup empty-matrix? [
            drop
        ] [
            m+
        ] if
    ] if ;

: laplacian-matrix ( basis1 basis2 basis3 -- matrix )
    dupd d-matrix m.m' [ d-matrix m'.m ] dip ?m+ ;

: laplacian-betti ( basis1 basis2 basis3 -- n )
    laplacian-matrix null/rank drop ;

: laplacian-kernel ( basis1 basis2 basis3 -- basis )
    [ tuck ] dip
    laplacian-matrix dup empty-matrix? [
        2drop f
    ] [
        nullspace [
            [ [ wedge (alt+) ] 2each ] with-terms
        ] with map
    ] if ;

: graded-triple ( seq n -- triple )
    3 [ 1- + ] with map swap [ ?nth ] curry map ;

: graded-triples ( seq -- triples )
    dup length [ graded-triple ] with map ;

: graded-laplacian ( generators quot -- seq )
    [ basis graded graded-triples [ first3 ] ] dip compose map ;
    inline

: graded-laplacian-betti ( generators -- seq )
    [ laplacian-betti ] graded-laplacian ;

: graded-laplacian-kernel ( generators -- seq )
    [ laplacian-kernel ] graded-laplacian ;

: graded-basis. ( seq -- )
    [
        "=== Degree " write pprint
        ": dimension " write dup length .
        [ alt. ] each
    ] each-index ;

: bigraded-triple ( u-deg z-deg bigraded-basis -- triple )
    #! d: C(u,z) ---> C(u+2,z-1)
    [ [ 2 - ] [ 1 + ] [ ] tri* ?nth ?nth ] 
    [ ?nth ?nth ] 
    [ [ 2 + ] [ 1 - ] [ ] tri* ?nth ?nth ]
    3tri
    3array ;

: bigraded-triples ( grid -- triples )
    dup length [
        over first length [
            [ 2dup ] dip spin bigraded-triple
        ] map 2nip
    ] with map ;

: bigraded-laplacian ( u-generators z-generators quot -- seq )
    [ [ basis graded ] bi@ tensor bigraded-triples ] dip
    [ [ first3 ] prepose map ] curry map ; inline

: bigraded-laplacian-betti ( u-generators z-generators -- seq )
    [ laplacian-betti ] bigraded-laplacian ;

: bigraded-laplacian-kernel ( u-generators z-generators -- seq )
    [ laplacian-kernel ] bigraded-laplacian ;

: bigraded-basis. ( seq -- )
    [
        "=== U-degree " write .
        [
            "  === Z-degree " write pprint
            ": dimension " write dup length .
            [ "  " write alt. ] each
        ] each-index
    ] each-index ;
