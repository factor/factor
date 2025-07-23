! Copyright (c) 2007-2010 Slava Pestov, Doug Coleman, Aaron Schaefer, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes.tuple combinators hints
kernel kernel.private make math math.functions math.order ranges
sequences sequences.private sets sorting strings vectors ;
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
    dup 1 > [ [1..b] product ] [ drop 1 ] if ;

: nPk ( n k -- nPk )
    2dup possible? [ dupd - [a..b) product ] [ 2drop 0 ] if ;

: nCk ( n k -- nCk )
    twiddle [ nPk ] keep factorial /i ;


! Factoradic-based permutation methodology

<PRIVATE

: factoradic ( n -- factoradic )
    0 [ over 0 > ] [ 1 + [ /mod ] 1check ] produce reverse! 2nip ;

: bump-indices ( seq n -- )
    '[ dup _ >= [ 1 + ] when ] map! drop ; inline

: (>permutation) ( seq n index -- seq )
    swap [ dupd head-to-index <slice-unsafe> ] dip bump-indices ;

: >permutation ( factoradic -- permutation )
    reverse! dup [ (>permutation) ] each-index reverse! ;

: permutation-indices ( n seq -- permutation )
    length [ factoradic ] dip 0 pad-head >permutation ;

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
        { [ len zero? ] [ { } ] }
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

: <permutation-iota> ( seq -- iota )
    length factorial <iota> ; inline

: permutations-quot ( seq quot -- seq quot' )
    [ [ <permutation-iota> ] [ length <iota> >array ] [ ] tri ] dip
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
    '[ _ keep and ] permutations-quot map-find drop ; inline

: reduce-permutations ( ... seq identity quot: ( ... prev elt -- ... next ) -- ... result )
    swapd each-permutation ; inline

: count-permutations ( ... seq quot: ( ... elt -- ... ? ) -- ... n )
    0 swap [ [ 1 + ] when ] compose reduce-permutations ; inline

: inverse-permutation ( seq -- permutation )
    <enumerated> sort-values keys ;

<PRIVATE

: cut-point ( seq -- n )
    [ last-unsafe ] keep [ [ > ] 1check ] find-last drop nip ; inline

: greater-from-last ( n seq -- i )
    [ nip ] [ nth-unsafe ] 2bi [ > ] curry find-last drop ; inline

: reverse-tail! ( n seq -- seq )
    [ swap 1 + index-to-tail <slice-unsafe> reverse! drop ] keep ; inline

: (next-permutation) ( seq -- seq )
    dup cut-point [
        swap [ greater-from-last ] 2keep
        [ exchange-unsafe ] [ reverse-tail! nip ] 3bi
    ] [ reverse! ] if* ;

HINTS: (next-permutation) array ;

PRIVATE>

: next-permutation ( seq -- seq )
    dup empty? [ (next-permutation) ] unless ;

<PRIVATE

: should-swap? ( start curr seq -- ? )
    [ nipd nth-unsafe ] [ <slice-unsafe> member? not ] 3bi ; inline

:: unique-permutations ( ... seq i n quot: ( ... elt -- ... ) -- ... )
    i n >= [
        seq clone quot call
    ] [
        i n [a..b) [| j |
            i j seq should-swap? [
                i j seq exchange-unsafe
                seq i 1 + n quot unique-permutations
                i j seq exchange-unsafe
            ] when
        ] each
    ] if ; inline recursive

PRIVATE>

: each-unique-permutation ( ... seq quot: ( ... elt -- ... ) -- ... )
    [ 0 over length ] dip unique-permutations ; inline

: all-unique-permutations ( seq -- seq' )
    [ [ , ] each-unique-permutation ] { } make ;

! Combinadic-based combination methodology

<PRIVATE

:: nCk-with-replacement ( n k -- nCk )
    k 1 - n + factorial k factorial / n 1 - factorial / ; inline

:: next-combination-with-replacement ( seq n -- )
    seq n 1 - '[ _ = not ] find-last drop [| i |
        seq i tail-slice i seq nth 1 + '[ drop _ ] map! drop
    ] when* ; inline

:: combinations-with-replacement-quot ( seq k quot -- seq quot' )
    seq length :> n
    n k nCk-with-replacement <iota> k 0 <array> seq quot n
    '[ drop _ [ _ nths-unsafe @ ] keep _ next-combination-with-replacement ] ; inline

PRIVATE>

: each-combination-with-replacement ( ... seq k quot: ( ... elt -- ... ) -- ... )
    combinations-with-replacement-quot each ; inline

: map-combinations-with-replacement ( ... seq k quot: ( ... elt -- ... newelt ) -- ... newseq )
    combinations-with-replacement-quot map ; inline

: filter-combinations-with-replacement ( ... seq k quot: ( ... elt -- ... ? ) -- ... newseq )
    selector [ each-combination-with-replacement ] dip ; inline

: map>assoc-combinations-with-replacement ( ... seq k quot: ( ... elt -- ... key value ) exemplar -- ... assoc )
    [ combinations-with-replacement-quot ] dip map>assoc ; inline

: all-combinations-with-replacement ( seq k -- seq' )
    [ ] map-combinations-with-replacement ;

: all-combinations-with-replacement? ( ... seq k quot: ( ... elt -- ... ? ) -- ... ? )
    combinations-with-replacement-quot all? ; inline

: find-combination-with-replacement ( ... seq k quot: ( ... elt -- ... ? ) -- ... elt/f )
    '[ _ keep and ] combinations-with-replacement-quot map-find drop ; inline

: reduce-combinations-with-replacement ( ... seq k identity quot: ( ... prev elt -- ... next ) -- ... result )
    -rotd each-combination-with-replacement ; inline

: count-combinations-with-replacement ( ... seq k quot: ( ... elt -- ... ? ) -- ... n )
    0 swap [ [ 1 + ] when ] compose reduce-combinations-with-replacement ; inline

<PRIVATE

! "Algorithm 515: Generation of a Vector from the Lexicographical Index"
! Buckles, B. P., and Lybanon, M. ACM
! Transactions on Mathematical Software, Vol. 3, No. 2, June 1977.

:: combination-indices ( x! p n -- seq )
    x 1 + x!
    p 0 <array> :> c 0 :> k! 0 :> r!
    p 1 - [| i |
        i [ 0 ] [ 1 - c nth-unsafe ] if-zero i c set-nth-unsafe
        [ k x < ] [
            i c [ 1 + ] change-nth-unsafe
            n i c nth-unsafe - p i 1 + - nCk r!
            k r + k!
        ] do while k r - k!
    ] each-integer
    p 2 < [ 0 ] [ p 2 - c nth-unsafe ] if
    p 1 < [ drop ] [ x + k - p 1 - c set-nth-unsafe ] if
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
    [ nth-unsafe ] [ swap index-to-tail <slice-unsafe> ] 2bi
    [ drop 1 + dup ] map! 2drop ; inline

: increment-last ( seq -- )
    [ index-of-last [ 1 + ] change-nth-unsafe ] unless-empty ; inline

:: next-combination ( seq n -- )
    seq n find-max-index [
        1 [-] seq increment-rest
    ] [
        seq increment-last
    ] if* ; inline

:: combinations-quot ( seq k quot -- seq quot' )
    seq length :> n
    n k nCk <iota> k <iota> >array seq quot n
    '[ drop _ [ _ nths-unsafe @ ] keep _ next-combination ] ; inline

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

: all-unique-combinations ( seq n -- seq' )
    HS{ } clone [ '[ _ adjoin ] each-combination ] keep members ;

: all-combinations? ( ... seq k quot: ( ... elt -- ... ? ) -- ... ? )
    combinations-quot all? ; inline

: find-combination ( ... seq k quot: ( ... elt -- ... ? ) -- ... elt/f )
    '[ _ keep and ] combinations-quot map-find drop ; inline

: reduce-combinations ( ... seq k identity quot: ( ... prev elt -- ... next ) -- ... result )
    -rotd each-combination ; inline

: count-combinations ( ... seq k quot: ( ... elt -- ... ? ) -- ... n )
    0 swap [ [ 1 + ] when ] compose reduce-combinations ; inline

: all-subsets ( seq -- subsets )
    dup length [0..b] [ all-combinations ] with map concat ;

<PRIVATE

:: next-selection ( seq n -- )
    1 seq length 1 - [
        dup 0 >= [ over 0 = ] [ t ] if
    ] [
        [ seq [ + n /mod ] change-nth-unsafe ] keep 1 -
    ] do until 2drop ; inline

:: selections-quot ( seq n quot -- seq quot' )
    seq length :> len
    n 0 <array> :> idx
    n [ 0 ] [ len swap ^ ] if-zero <iota> [
        drop
        idx seq nths-unsafe quot call
        idx len next-selection
    ] ; inline

PRIVATE>

: each-selection ( ... seq n quot: ( ... elt -- ... ) -- ... )
    selections-quot each ; inline

: map-selections ( ... seq n quot: ( ... elt -- ... newelt ) -- ... newseq )
    selections-quot map ; inline

: filter-selections ( ... seq n quot: ( ... elt -- ... newelt ) -- ... newseq )
    selector [ each-selection ] dip ; inline

: all-selections ( seq n -- seq' )
    [ ] map-selections ;

: all-selections? ( seq n -- ? )
    selections-quot all? ; inline

: find-selection ( ... seq n quot: ( ... elt -- ... ? ) -- ... elt/f )
    '[ _ keep and ] selections-quot map-find drop ; inline

: reduce-selections ( ... seq n identity quot: ( ... prev elt -- ... next ) -- ... result )
    -rotd each-selection ; inline

: count-selections ( ... seq n quot: ( ... elt -- ... ? ) -- ... n )
    0 swap [ [ 1 + ] when ] compose reduce-selections ; inline
