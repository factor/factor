! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs hashtables assocs io kernel math
math.vectors math.matrices math.matrices.elimination namespaces
parser prettyprint sequences words combinators math.parser
splitting sorting shuffle ;
IN: koszul

! Utilities
: SYMBOLS:
    ";" parse-tokens [ create-in define-symbol ] each ;
    parsing

: -1^ odd? -1 1 ? ;

: >alt ( obj -- vec )
    {
        { [ dup not ] [ drop 0 >alt ] }
        { [ dup number? ] [ { } associate ] }
        { [ dup array? ] [ 1 swap associate ] }
        { [ dup hashtable? ] [ ] }
        { [ t ] [ 1array >alt ] }
    } cond ;

: canonicalize
    [ nip zero? not ] assoc-subset ;

SYMBOL: terms

: with-terms ( quot -- hash )
    [
        H{ } clone terms set call terms get canonicalize
    ] with-scope ; inline

! Printing elements
: num-alt. ( n -- str )
    {
        { [ dup 1 = ] [ drop " + " ] }
        { [ dup -1 = ] [ drop " - " ] }
        { [ t ] [ number>string " + " swap append ] }
    } cond ;

: (alt.) ( basis n -- str )
    over empty? [
        nip number>string
    ] [
        num-alt.
        swap [ word-name ] map "." join
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
    [ >alt ] 2apply [ (alt+) (alt+) ] with-terms ;

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
    [ > ] curry* subset length ;

: inversions ( seq -- n )
    0 swap [ length ] keep [
        [ nth ] 2keep swap 1+ tail-slice (inversions) +
    ] curry each ;

: duplicates? ( seq -- ? )
    dup prune [ length ] 2apply > ;

: (wedge) ( n basis1 basis2 -- n basis )
    append dup duplicates? [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap natural-sort
    ] if ;

: wedge ( x y -- x.y )
    [ >alt ] 2apply [
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

: dx.y ( x y -- vec ) >r ((d)) r> wedge ;

DEFER: (d)

: x.dy ( x y -- vec ) (d) wedge -1 alt*n ;

: (d) ( product -- value )
    dup empty?
    [ drop H{ } ] [ unclip swap [ x.dy ] 2keep dx.y alt+ ] if ;

: linear-op ( vec quot -- vec )
	[
        [
            -rot >r swap call r> alt*n (alt+)
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
    dup 0 [ length max ] reduce 1+ [ drop V{ } clone ] map
    [ dup length pick nth push ] reduce ;

: nth-basis-elt ( generators n -- elt )
    over length [
        3dup bit? [ nth ] [ 2drop f ] if
    ] map [ ] subset 2nip ;

: basis ( generators -- seq )
    natural-sort dup length 2^ [ nth-basis-elt ] curry* map ;

: (tensor) ( seq1 seq2 -- seq )
    [
        [ swap append natural-sort ] curry map
    ] curry* map concat ;

: tensor ( graded-basis1 graded-basis2 -- bigraded-basis )
    [ [ swap (tensor) ] curry map ] curry* map ;

! Computing cohomology
: (op-matrix) ( range quot basis-elt -- row )
    swap call [ at 0 or ] curry map ; inline

: op-matrix ( domain range quot -- matrix )
    rot [ >r 2dup r> (op-matrix) ] map 2nip ; inline

: d-matrix ( domain range -- matrix )
    [ (d) ] op-matrix ;

: dim-im/ker-d ( domain range -- null/rank )
    d-matrix null/rank 2array ;

! Graded by degree
: (graded-ker/im-d) ( n seq -- null/rank )
    #! d: C(n) ---> C(n+1)
    [ ?nth ] 2keep >r 1+ r> ?nth
    dim-im/ker-d ;

: graded-ker/im-d ( graded-basis -- seq )
    [ length ] keep [ (graded-ker/im-d) ] curry map ;

: graded-betti ( generators -- seq )
    basis graded graded-ker/im-d flip first2 1 head* 0 add* v- ;

! Bi-graded for two-step complexes
: (bigraded-ker/im-d) ( u-deg z-deg bigraded-basis -- null/rank )
    #! d: C(u,z) ---> C(u+2,z-1)
    [ ?nth ?nth ] 3keep >r >r 2 + r> 1 - r> ?nth ?nth
    dim-im/ker-d ;

: bigraded-ker/im-d ( bigraded-basis -- seq )
    dup length [
        over first length [
            >r 2dup r> swap rot (bigraded-ker/im-d)
        ] map 2nip
    ] curry* map ;

: bigraded-betti ( u-generators z-generators -- seq )
    [ basis graded ] 2apply tensor bigraded-ker/im-d
    [ [ [ first ] map ] map ] keep
    [ [ second ] map 2 head* { 0 0 } swap append ] map
    1 tail dup first length 0 <array> add
    [ v- ] 2map ;

! Laplacian
: m.m' dup flip m. ;
: m'.m dup flip swap m. ;

: empty-matrix? ( matrix -- ? )
    dup empty? [ drop t ] [ first empty? ] if ;

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
    dupd d-matrix m.m' >r d-matrix m'.m r> ?m+ ;

: laplacian-betti ( basis1 basis2 basis3 -- n )
    laplacian-matrix null/rank drop ;

: laplacian-kernel ( basis1 basis2 basis3 -- basis )
    >r tuck r>
    laplacian-matrix dup empty-matrix? [
        2drop f
    ] [
        nullspace [
            [ [ wedge (alt+) ] 2each ] with-terms
        ] curry* map
    ] if ;

: graded-triple ( seq n -- triple )
    3 [ 1- + ] curry* map swap [ ?nth ] curry map ;

: graded-triples ( seq -- triples )
    dup length [ graded-triple ] curry* map ;

: graded-laplacian ( generators quot -- seq )
    >r basis graded graded-triples [ first3 ] r> compose map ;
    inline

: graded-laplacian-betti ( generators -- seq )
    [ laplacian-betti ] graded-laplacian ;

: graded-laplacian-kernel ( generators -- seq )
    [ laplacian-kernel ] graded-laplacian ;

: graded-basis. ( seq -- )
    dup length [
        "=== Degree " write pprint
        ": dimension " write dup length .
        [ alt. ] each
    ] 2each ;

: bigraded-triple ( u-deg z-deg bigraded-basis -- triple )
    #! d: C(u,z) ---> C(u+2,z-1)
    [ >r >r 2 - r> 1 + r> ?nth ?nth ] 3keep
    [ ?nth ?nth ] 3keep
    >r >r 2 + r> 1 - r> ?nth ?nth
    3array ;

: bigraded-triples ( grid -- triples )
    dup length [
        over first length [
            >r 2dup r> swap rot bigraded-triple
        ] map 2nip
    ] curry* map ;

: bigraded-laplacian ( u-generators z-generators quot -- seq )
    >r [ basis graded ] 2apply tensor bigraded-triples r>
    [ [ first3 ] swap compose map ] curry map ; inline

: bigraded-laplacian-betti ( u-generators z-generators -- seq )
    [ laplacian-betti ] bigraded-laplacian ;

: bigraded-laplacian-kernel ( u-generators z-generators -- seq )
    [ laplacian-kernel ] bigraded-laplacian ;

: bigraded-basis. ( seq -- )
    dup length [
        "=== U-degree " write .
        dup length [
            "  === Z-degree " write pprint
            ": dimension " write dup length .
            [ "  " write alt. ] each
        ] 2each
    ] 2each ;
