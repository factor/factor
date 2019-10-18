! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors assocs hashtables assocs io kernel math matrices
namespaces parser prettyprint sequences words ;
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

: ((alt.)) ( basis n -- str )
    over empty? [
        nip number>string
    ] [
        num-alt.
        swap [ word-name ] map "." join
        append
    ] if ;

: (alt.) ( assoc -- )
    dup empty? [
        drop 0 .
    ] [
        [ first2 ((alt.)) ] map concat " + " ?head drop print
    ] if ;

: alt. ( vec -- ) { } >alist (alt.) ;

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
        swap [ rot * ] assoc-map-with 
    ] if ;

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

: (wedge) ( n basis1 basis2 -- n basis )
    append dup duplicates? [
        2drop 0 { }
    ] [
        dup permutation inversions -1^ rot *
        swap natural-sort
    ] if ;

: wedge ( x y -- x.y )
    [ >alt ] 2apply [
        [
            rot [
                2swap [
                    swapd * -rot (wedge) +@
                ] 2keep
            ] assoc-each 2drop
        ] assoc-each-with
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
        swap [
            >r swap call r> alt*n (alt+)
        ] assoc-each-with
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

: nth-bit? ( m bit# -- ? )
    1 swap shift bitand 0 > ;

: nth-basis-elt ( generators n -- elt )
    over length [
        3dup nth-bit? [ nth ] [ 2drop f ] if
    ] map [ ] subset 2nip ;

: basis ( generators -- seq )
    natural-sort dup length 2^ [ nth-basis-elt ] map-with ;

: (tensor) ( seq1 seq2 -- seq )
    [ swap [ append natural-sort ] map-with ] map-with concat ;

: tensor ( graded-basis1 graded-basis2 -- bigraded-basis )
    [ swap [ (tensor) ] map-with ] map-with ;

! Computing cohomology
: (op-matrix) ( range quot basis-elt -- row )
    swap call swap [ swap at [ 0 ] unless* ] map-with ; inline

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
    dup length [ swap (graded-ker/im-d) ] map-with ;

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
    ] map-with ;

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
    laplacian-matrix nullspace
    [ [ [ wedge (alt+) ] 2each ] with-terms ] map-with ;

: graded-triple ( seq n -- triple )
    3 [ 1- + ] map-with [ swap ?nth ] map-with ;

: graded-triples ( seq -- triples )
    dup length [ graded-triple ] map-with ;

: graded-laplacian ( generators quot -- seq )
    swap
    basis graded graded-triples
    [ first3 roll call ] map-with ; inline

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
    ] map-with ;

: bigraded-laplacian ( u-generators z-generators quot -- seq )
    -rot
    [ basis graded ] 2apply tensor bigraded-triples
    [ [ first3 roll call ] map-with ] map-with ; inline

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
