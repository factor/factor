! Copyright (c) 2007-2010 Slava Pestov, Doug Coleman, Aaron Schaefer, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs binary-search classes.tuple fry
kernel locals math math.order math.ranges namespaces sequences
sequences.private sorting ;
FROM: sequences => change-nth ;
IN: math.combinatorics

<PRIVATE

: possible? ( n m -- ? )
    0 rot between? ; inline

: twiddle ( n k -- n k )
    2dup - dupd > [ dupd - ] when ; inline

PRIVATE>

: factorial ( n -- n! )
    dup 1 > [ [1,b] product ] [ drop 1 ] if ;

: nPk ( n k -- nPk )
    2dup possible? [ dupd - [a,b) product ] [ 2drop 0 ] if ;

: nCk ( n k -- nCk )
    twiddle [ nPk ] keep factorial / ;


! Factoradic-based permutation methodology

<PRIVATE

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1 + [ /mod ] keep swap ] produce reverse! 2nip ;

: (>permutation) ( seq n -- seq )
    [ '[ _ dupd >= [ 1 + ] when ] map! ] keep prefix ;

: >permutation ( factoradic -- permutation )
    reverse! 1 cut [ (>permutation) ] each ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-head >permutation ;

: permutation-iota ( seq -- iota )
    length factorial iota ; inline

PRIVATE>

: permutation ( n seq -- seq' )
    [ permutation-indices ] keep nths ;

TUPLE: permutations length seq ;

: <permutations> ( seq -- permutations )
    [ length factorial ] keep permutations boa ;

M: permutations length length>> ; inline
M: permutations nth-unsafe seq>> permutation ;
M: permutations hashcode* tuple-hashcode ;

INSTANCE: permutations immutable-sequence

: each-permutation ( seq quot -- )
    [ [ permutation-iota ] keep ] dip
    '[ _ permutation @ ] each ; inline

: map-permutations ( seq quot -- seq' )
    [ [ permutation-iota ] keep ] dip
    '[ _ permutation @ ] map ; inline

: filter-permutations ( seq quot -- seq' )
    selector [ each-permutation ] dip ; inline

: all-permutations ( seq -- seq' )
    [ ] map-permutations ;

: find-permutation ( seq quot -- elt )
    [ dup [ permutation-iota ] keep ] dip
    '[ _ permutation @ ] find drop
    [ swap permutation ] [ drop f ] if* ; inline

: reduce-permutations ( seq identity quot -- result )
    swapd each-permutation ; inline

: inverse-permutation ( seq -- permutation )
    <enum> sort-values keys ;

<PRIVATE

: cut-point ( seq -- n )
    [ last ] keep [ [ > ] keep swap ] find-last drop nip ;

: greater-from-last ( n seq -- i )
    [ nip ] [ nth ] 2bi [ > ] curry find-last drop ;

: reverse-tail! ( n seq -- seq )
    [ swap 1 + tail-slice reverse! drop ] keep ;

: (next-permutation) ( seq -- seq )
    dup cut-point [
        swap [ greater-from-last ] 2keep
        [ exchange ] [ reverse-tail! nip ] 3bi
    ] [ reverse! ] if* ;

PRIVATE>

: next-permutation ( seq -- seq )
    dup [ ] [ drop (next-permutation) ] if-empty ;

! Combinadic-based combination methodology

<PRIVATE

! "Algorithm 515: Generation of a Vector from the Lexicographical Index"
! Buckles, B. P., and Lybanon, M. ACM
! Transactions on Mathematical Software, Vol. 3, No. 2, June 1977.

:: combination-indices ( x! p n -- seq )
    x 1 + x!
    p 0 <array> :> c 0 :> k! 0 :> r!
    p 1 - [| i |
        i [ 0 ] [ 1 - c nth ] if-zero i c set-nth
        [ k x < ] [
            i c [ 1 + ] change-nth
            n i c nth - p i 1 + - nCk r!
            k r + k!
        ] do while k r - k!
    ] each-integer
    p 2 < [ 0 ] [ p 2 - c nth ] if
    p 1 < [ drop ] [ x + k - p 1 - c set-nth ] if
    c [ 1 - ] map! ;

:: combinations-quot ( seq k quot -- seq quot )
    seq length :> n
    n k nCk iota [
        k n combination-indices seq nths quot call
    ] ; inline

PRIVATE>

: combination ( m seq k -- seq' )
    swap [ length combination-indices ] [ nths ] bi ;

TUPLE: combinations seq k length ;

: <combinations> ( seq k -- combinations )
    2dup [ length ] [ nCk ] bi* combinations boa ;

M: combinations length length>> ; inline
M: combinations nth-unsafe [ seq>> ] [ k>> ] bi combination ;
M: combinations hashcode* tuple-hashcode ;

INSTANCE: combinations immutable-sequence

: each-combination ( seq k quot -- )
    combinations-quot each ; inline

: map-combinations ( seq k quot -- seq' )
    combinations-quot map ; inline

: filter-combinations ( seq k quot -- seq' )
    selector [ each-combination ] dip ; inline

: map>assoc-combinations ( seq k quot exemplar -- )
    [ combinations-quot ] dip map>assoc ; inline

: all-combinations ( seq k -- seq' )
    [ ] map-combinations ;

: find-combination ( seq k quot -- i elt )
    [ combinations-quot find drop ]
    [ drop pick [ combination ] [ 3drop f ] if ] 3bi ; inline

: reduce-combinations ( seq k identity quot -- result )
    [ -rot ] dip each-combination ; inline

: all-subsets ( seq -- subsets )
    dup length [0,b] [ all-combinations ] with map concat ;

<PRIVATE

: (selections) ( seq n -- selections )
    [ [ 1array ] map dup ] [ 1 - ] bi* [
        cartesian-product concat [ { } concat-as ] map
    ] with times ;

PRIVATE>

: selections ( seq n -- selections )
    dup 0 > [ (selections) ] [ 2drop { } ] if ;

