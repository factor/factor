! Copyright (C) 2006, 2007 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators hashtables io kernel
make math math.matrices math.matrices.elimination math.order
math.parser math.vectors namespaces prettyprint sequences sets
shuffle sorting splitting ;
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

: canonicalize ( assoc -- assoc' ) [ zero? ] reject-values ;

SYMBOL: terms

: with-terms ( quot -- hash )
    [
        H{ } clone terms namespaces:set call terms get canonicalize
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
    terms get [ [ swap +@ ] assoc-each ] with-variables ;

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
    [ sort ] keep [ index ] curry map ;

: (inversions) ( n seq -- n )
    [ > ] with count ;

: inversions ( seq -- n )
    0 swap [ length <iota> ] keep [
        [ nth ] 2keep swap 1 + tail-slice (inversions) +
    ] curry each ;

: (wedge) ( n basis1 basis2 -- n basis )
    append dup all-unique? not [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap sort
    ] if ;

: wedge ( x y -- x.y )
    [ >alt ] bi@ [
        swap building get '[
            [
                2swap [
                    swapd * -rot (wedge) _ at+
                ] 2keep
            ] assoc-each 2drop
        ] curry assoc-each
    ] H{ } make canonicalize ;

! Differential
SYMBOL: boundaries

: d= ( value basis -- )
    boundaries [ ?set-at ] change ;

: get-boundary ( basis -- value ) boundaries get at ;

: dx.y ( x y -- vec ) [ get-boundary ] dip wedge ;

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
    ! y is a generator
    swap >alt [ dupd (interior) ] linear-op nip ;

! Computing a basis
: graded ( seq -- seq )
    dup 0 [ length max ] reduce 1 + [ V{ } clone ] replicate
    [ dup length pick nth push ] reduce ;

: nth-basis-elt ( generators n -- elt )
    over length <iota> [
        3dup bit? [ nth ] [ 2drop f ] if
    ] map sift 2nip ;

: basis ( generators -- seq )
    sort dup length 2^ <iota> [ nth-basis-elt ] with map ;

: (tensor) ( seq1 seq2 -- seq )
    [
        [ prepend sort ] curry map
    ] with map concat ;

: tensor ( graded-basis1 graded-basis2 -- bigraded-basis )
    [ [ swap (tensor) ] curry map ] with map ;

! Computing cohomology
: (op-matrix) ( range quot basis-elt -- row )
    swap call [ at 0 or ] curry map ; inline

: op-matrix ( domain range quot -- matrix )
    rot [ (op-matrix) ] 2with map ; inline

: d-matrix ( domain range -- matrix )
    [ (d) ] op-matrix ;

: dim-im/ker-d ( domain range -- null/rank )
    d-matrix null/rank 2array ;

! Graded by degree
: (graded-ker/im-d) ( n seq -- null/rank )
    ! d: C(n) ---> C(n+1)
    [ ?nth ] [ [ 1 + ] dip ?nth ] 2bi
    dim-im/ker-d ;

: graded-ker/im-d ( graded-basis -- seq )
    [ length <iota> ] keep [ (graded-ker/im-d) ] curry map ;

: graded-betti ( generators -- seq )
    basis graded graded-ker/im-d unzip but-last 0 prefix v- ;

! Bi-graded for two-step complexes
: (bigraded-ker/im-d) ( u-deg z-deg bigraded-basis -- null/rank )
    ! d: C(u,z) ---> C(u+2,z-1)
    [ ?nth ?nth ] 3keep [ [ 2 + ] dip 1 - ] dip ?nth ?nth
    dim-im/ker-d ;

:: bigraded-ker/im-d ( basis -- seq )
    basis length <iota> [| z |
         basis first length <iota> [| u |
            u z basis (bigraded-ker/im-d)
        ] map
    ] map ;

: bigraded-betti ( u-generators z-generators -- seq )
    [ basis graded ] bi@ tensor bigraded-ker/im-d
    [ [ keys ] map ] keep
    [ values 2 head* { 0 0 } prepend ] map
    rest dup first length 0 <array> suffix
    [ v- ] 2map ;

! Laplacian
: mdotm' ( matrix -- matrix' ) dup flip mdot ;
: m'dotm ( matrix -- matrix' ) dup flip swap mdot ;

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
    dupd d-matrix mdotm' [ d-matrix m'dotm ] dip ?m+ ;

: laplacian-betti ( basis1 basis2 basis3 -- n )
    laplacian-matrix null/rank drop ;

:: laplacian-kernel ( basis1 basis2 basis3 -- basis )
    basis1 basis2 basis3 laplacian-matrix :> lap
    lap empty-matrix? [ f ] [
        lap nullspace [| x |
            basis2 x [ [ wedge (alt+) ] 2each ] with-terms
        ] map
    ] if ;

: graded-triple ( seq n -- triple )
    3 [ 1 - + ] with map swap [ ?nth ] curry map ;

: graded-triples ( seq -- triples )
    dup length [ graded-triple ] with map ;

: graded-laplacian ( generators quot -- seq )
    [ basis graded graded-triples [ first3 ] ] dip compose map ; inline

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
    ! d: C(u,z) ---> C(u+2,z-1)
    [ [ 2 - ] [ 1 + ] [ ] tri* ?nth ?nth ]
    [ ?nth ?nth ]
    [ [ 2 + ] [ 1 - ] [ ] tri* ?nth ?nth ]
    3tri
    3array ;

:: bigraded-triples ( grid -- triples )
    grid length <iota> [| z |
        grid first length <iota> [| u |
            u z grid bigraded-triple
        ] map
    ] map ;

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
