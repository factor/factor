! Copyright (c) 2007-2010 Slava Pestov, Doug Coleman, Aaron Schaefer, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs binary-search classes.tuple
combinators fry hints kernel kernel.private locals math
math.functions math.order math.ranges namespaces sequences
sequences.private sorting strings vectors ;
IN: math.combinatorics

<PRIVATE

! Specialized version of nths-unsafe for performance
: (nths-unsafe) ( indices seq -- seq' )
    [ { array } declare ] dip
    [ [ nth-unsafe ] curry ] keep map-as ; inline
GENERIC: nths-unsafe ( indices seq -- seq' )
M: string nths-unsafe (nths-unsafe) ;
M: array nths-unsafe (nths-unsafe) ;
M: vector nths-unsafe (nths-unsafe) ;
M: iota nths-unsafe (nths-unsafe) ;
M: object nths-unsafe (nths-unsafe) ;

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
    twiddle [ nPk ] keep factorial /i ;


! Factoradic-based permutation methodology

<PRIVATE

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1 + [ /mod ] keep swap ] produce reverse! 2nip ;

: bump-indices ( seq n -- )
    '[ dup _ >= [ 1 + ] when ] map! drop ; inline

: (>permutation) ( seq n index -- seq )
    swap [ dupd head-slice ] dip bump-indices ;

: >permutation ( factoradic -- permutation )
    reverse! dup [ (>permutation) ] each-index reverse! ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-head >permutation ;

: permutation-iota ( seq -- <iota> )
    length factorial <iota> ; inline

PRIVATE>

: permutation ( n seq -- seq' )
    [ permutation-indices ] keep nths-unsafe ;

TUPLE: permutations length seq ;

: <permutations> ( seq -- permutations )
    [ length factorial ] keep permutations boa ;

M: permutations length length>> ; inline
M: permutations nth-unsafe seq>> permutation ;
M: permutations hashcode* tuple-hashcode ;

INSTANCE: permutations immutable-sequence

TUPLE: k-permutations length skip k seq ;

:: <k-permutations> ( seq k -- permutations )
    seq length :> n
    n k nPk :> len
    {
        { [ len k [ zero? ] either? ] [ { } ] }
        { [ n k = ] [ seq <permutations> ] }
        [ len n factorial over /i k seq k-permutations boa ]
    } cond ;

M: k-permutations length length>> ; inline
M: k-permutations nth-unsafe
    [ skip>> * ]
    [ seq>> [ permutation-indices ] keep ]
    [ k>> swap [ head ] dip nths-unsafe ] tri ;
M: k-permutations hashcode* tuple-hashcode ;

INSTANCE: k-permutations immutable-sequence

DEFER: next-permutation

<PRIVATE

: permutations-quot ( seq quot -- seq quot' )
    [ [ permutation-iota ] [ length <iota> >array ] [ ] tri ] dip
    '[ drop _ [ _ nths-unsafe @ ] keep next-permutation drop ] ; inline

PRIVATE>

: each-permutation ( ... seq quot: ( ... elt -- ... ) -- ... )
    permutations-quot each ; inline

: map-permutations ( ... seq quot: ( ... elt -- ... newelt ) -- ... newseq )
    permutations-quot map ; inline

: filter-permutations ( ... seq quot: ( ... elt -- ... ? ) -- ... newseq )
    selector [ each-permutation ] dip ; inline

: all-permutations ( seq -- seq' )
    [ ] map-permutations ;

: all-permutations? ( ... seq quot: ( ... elt -- ... ? ) -- ... ? )
    permutations-quot all? ; inline

: find-permutation ( ... seq quot: ( ... elt -- ... ? ) -- ... elt/f )
    [ permutations-quot find drop ]
    [ drop over [ permutation ] [ 2drop f ] if ] 2bi ; inline

: reduce-permutations ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd each-permutation ; inline

: inverse-permutation ( seq -- permutation )
    <enumerated> sort-values keys ;

<PRIVATE

: cut-point ( seq -- n )
    [ last ] keep [ [ > ] keep swap ] find-last drop nip ; inline

: greater-from-last ( n seq -- i )
    [ nip ] [ nth ] 2bi [ > ] curry find-last drop ; inline

: reverse-tail! ( n seq -- seq )
    [ swap 1 + tail-slice reverse! drop ] keep ; inline

: (next-permutation) ( seq -- seq )
    dup cut-point [
        swap [ greater-from-last ] 2keep
        [ exchange ] [ reverse-tail! nip ] 3bi
    ] [ reverse! ] if* ;

HINTS: (next-permutation) array ;

PRIVATE>

: next-permutation ( seq -- seq )
    dup empty? [ (next-permutation) ] unless ;


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

PRIVATE>

: combination ( m seq k -- seq' )
    swap [ length combination-indices ] [ nths-unsafe ] bi ;

TUPLE: combinations seq k length ;

: <combinations> ( seq k -- combinations )
    2dup [ length ] [ nCk ] bi* combinations boa ;

M: combinations length length>> ; inline
M: combinations nth-unsafe [ seq>> ] [ k>> ] bi combination ;
M: combinations hashcode* tuple-hashcode ;

INSTANCE: combinations immutable-sequence

<PRIVATE

: find-max-index ( seq n -- i )
    over length - '[ _ + >= ] find-index drop ; inline

: increment-rest ( i seq -- )
    [ nth ] [ swap tail-slice ] 2bi
    [ drop 1 + dup ] map! 2drop ; inline

: increment-last ( seq -- )
    [ [ length 1 - ] keep [ 1 + ] change-nth ] unless-empty ; inline

:: next-combination ( seq n -- seq )
    seq n find-max-index [
        1 [-] seq increment-rest
    ] [
        seq increment-last
    ] if* seq ; inline

:: combinations-quot ( seq k quot -- seq quot' )
    seq length :> n
    n k nCk <iota> k <iota> >array seq quot n
    '[ drop _ [ _ nths-unsafe @ ] keep _ next-combination drop ] ; inline

PRIVATE>

: each-combination ( ... seq k quot: ( ... elt -- ... ) -- ... )
    combinations-quot each ; inline

: map-combinations ( ... seq k quot: ( ... elt -- ... newelt ) -- ... newseq )
    combinations-quot map ; inline

: filter-combinations ( ... seq k quot: ( ... elt -- ... ? ) -- ... newseq )
    selector [ each-combination ] dip ; inline

: map>assoc-combinations ( ... seq k quot: ( ... elt -- ... key value ) exemplar -- ... assoc )
    [ combinations-quot ] dip map>assoc ; inline

: all-combinations ( seq k -- seq' )
    [ ] map-combinations ;

: all-combinations? ( ... seq k quot: ( ... elt -- ... ? ) -- ... ? )
    combinations-quot all? ; inline

: find-combination ( ... seq k quot: ( ... elt -- ... ? ) -- ... elt/f )
    [ combinations-quot find drop ]
    [ drop pick [ combination ] [ 3drop f ] if ] 3bi ; inline

: reduce-combinations ( ... seq k identity quot: ( ... prev elt -- ... next ) -- ... result )
    -rotd each-combination ; inline

: all-subsets ( seq -- subsets )
    dup length [0,b] [ all-combinations ] with map concat ;

<PRIVATE

:: next-selection ( seq n -- )
    1 seq length 1 - [
        dup 0 >= [ over 0 = ] [ t ] if
    ] [
        [ seq [ + n /mod ] change-nth-unsafe ] keep 1 -
    ] do until 2drop ; inline

:: (selections) ( seq n -- selections )
    seq length :> len
    n 0 <array> :> idx
    len n ^ [
        idx seq nths-unsafe
        idx len next-selection
    ] replicate ;

PRIVATE>

: selections ( seq n -- selections )
    dup 0 > [ (selections) ] [ 2drop { } ] if ;
