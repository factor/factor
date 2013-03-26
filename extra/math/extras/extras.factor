! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs assocs.extras byte-arrays
combinators combinators.short-circuit compression.zlib fry
grouping kernel locals math math.combinatorics math.constants
math.functions math.order math.primes math.ranges
math.ranges.private math.statistics math.vectors memoize random
sequences sequences.extras sets sorting ;

IN: math.extras

<PRIVATE

DEFER: stirling

: (stirling) ( n k -- x )
    [ [ 1 - ] bi@ stirling ]
    [ [ 1 - ] dip stirling ]
    [ nip * + ] 2tri ;

PRIVATE>

MEMO: stirling ( n k -- x )
    2dup { [ = ] [ nip 1 = ] } 2||
    [ 2drop 1 ] [ (stirling) ] if ;

:: ramanujan ( x -- y )
    pi sqrt x e / x ^ * x 8 * 4 + x * 1 + x * 1/30 + 1/6 ^ * ;

<PRIVATE

DEFER: bernoulli

: (bernoulli) ( p -- n )
    [ iota ] [ 1 + ] bi [
        0 [ [ nCk ] [ bernoulli * ] bi + ] with reduce
    ] keep recip neg * ;

PRIVATE>

MEMO: bernoulli ( p -- n )
    [ 1 ] [ (bernoulli) ] if-zero ;

: chi2 ( actual expected -- n )
    0 [ dup 0 > [ [ - sq ] keep / + ] [ 2drop ] if ] 2reduce ;

<PRIVATE

: df-check ( df -- )
    even? [ "odd degrees of freedom" throw ] unless ;

: (chi2P) ( chi/2 df/2 -- p )
    [1,b) dupd n/v cum-product swap neg e^ [ v*n sum ] keep + ;

PRIVATE>

: chi2P ( chi df -- p )
    dup df-check [ 2.0 / ] [ 2 /i ] bi* (chi2P) 1.0 min ;

<PRIVATE

: check-jacobi ( m -- m )
    dup { [ integer? ] [ 0 > ] [ odd? ] } 1&&
    [ "modulus must be odd positive integer" throw ] unless ;

: mod' ( x y -- n )
    [ mod ] keep over zero? [ drop ] [
        2dup [ sgn ] same? [ drop ] [ + ] if
    ] if ;

PRIVATE>

: jacobi ( a m -- n )
    check-jacobi [ mod' ] keep 1
    [ pick zero? ] [
        [ pick even? ] [
            [ 2 / ] 2dip
            over 8 mod' { 3 5 } member? [ neg ] when
        ] while swapd
        2over [ 4 mod' 3 = ] both? [ neg ] when
        [ [ mod' ] keep ] dip
    ] until [ nip 1 = ] dip 0 ? ;

<PRIVATE

: check-legendere ( m -- m )
    dup prime? [ "modulus must be prime positive integer" throw ] unless ;

PRIVATE>

: legendere ( a m -- n )
    check-legendere jacobi ;

: moving-average ( seq n -- newseq )
    <clumps> [ mean ] map ;

: exponential-moving-average ( seq a -- newseq )
    [ 1 ] 2dip [ [ dupd swap - ] dip * + dup ] curry map nip ;

: moving-median ( u n -- v )
    clump [ median ] map ;

: moving-supremum ( u n -- v )
    <clumps> [ supremum ] map ;

: moving-infimum ( u n -- v )
    <clumps> [ infimum ] map ;

: moving-sum ( u n -- v )
    <clumps> [ sum ] map ;

: moving-count ( ... u n quot: ( ... elt -- ... ? ) -- ... v )
    [ <clumps> ] [ [ count ] curry map ] bi* ; inline

: nonzero ( seq -- seq' )
    [ zero? not ] filter ;

: bartlett ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [ iota ] [ 1 - 2 / ] bi [
            [ recip * ] [ >= ] 2bi [ 2 swap - ] when
        ] curry map
    ] if ;

: hanning ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [ iota ] [ 1 - 2pi swap / ] bi v*n
        [ cos -0.5 * 0.5 + ] map!
    ] if ;

: hamming ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [ iota ] [ 1 - 2pi swap / ] bi v*n
        [ cos -0.46 * 0.54 + ] map!
    ] if ;

: blackman ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [ iota ] [ 1 - 2pi swap / ] bi v*n
        [ [ cos -0.5 * ] map ] [ [ 2 * cos 0.08 * ] map ] bi
        v+ 0.42 v+n
    ] if ;

: nan-sum ( seq -- n )
    0 [ dup fp-nan? [ drop ] [ + ] if ] binary-reduce ;

: nan-min ( seq -- n )
    [ fp-nan? not ] filter infimum ;

: nan-max ( seq -- n )
    [ fp-nan? not ] filter supremum ;

: sinc ( x -- y )
    [ 1 ] [ pi * [ sin ] [ / ] bi ] if-zero ;

: until-zero ( n quot -- )
    [ dup zero? ] swap until drop ; inline

: cum-reduce ( seq identity quot: ( prev elt -- next ) -- result cum-result )
    [ dup rot ] dip dup '[ _ curry dip dupd @ ] each ; inline

<PRIVATE

:: (gini) ( seq -- x )
    seq natural-sort :> sorted
    seq length :> len
    sorted 0 [ + ] cum-reduce :> ( a b )
    b len a * / :> B
    1 len recip + 2 B * - ;

PRIVATE>

: gini ( seq -- x )
    dup length 1 <= [ drop 0 ] [ (gini) ] if ;

: concentration-coefficient ( seq -- x )
    dup length 1 <= [
        drop 0
    ] [
        [ (gini) ] [ length [ ] [ 1 - ] bi / ] bi *
    ] if ;

: herfindahl ( seq -- x )
    [ sum-of-squares ] [ sum sq ] bi / ;

: normalized-herfindahl ( seq -- x )
    [ herfindahl ] [ length recip ] bi
    [ - ] [ 1 swap - / ] bi ;

: exponential-index ( seq -- x )
    dup sum '[ _ / dup ^ ] map-product ;

: search-sorted ( obj seq -- i )
    swap '[ [ _ >= ] find drop dup ] [ length ] bi ? ;

: weighted-random ( histogram -- obj )
    unzip cum-sum [ last random ] [ search-sorted ] bi swap nth ;

: unique-indices ( seq -- unique indices )
    [ members ] keep over dup length iota H{ } zip-as '[ _ at ] map ;

<PRIVATE

: steps ( a b length -- a b step )
    [ 2dup swap - ] dip / ; inline

PRIVATE>

: linspace[a,b) ( a b length -- seq )
    steps ,b) <range> ;

: linspace[a,b] ( a b length -- seq )
    {
        { [ dup 1 < ] [ 3drop { } ] }
        { [ dup 1 = ] [ 2drop 1array ] }
        [ 1 - steps <range> ]
    } cond ;

: logspace[a,b) ( a b length base -- seq )
    [ linspace[a,b) ] dip swap n^v ;

: logspace[a,b] ( a b length base -- seq )
    [ linspace[a,b] ] dip swap n^v ;

: majority ( seq -- elt/f )
    [ f 0 ] dip [
        over zero? [ 2nip 1 ] [
            pick = [ 1 + ] [ 1 - ] if
        ] if
    ] each zero? [ drop f ] when ;

: compression-lengths ( a b -- len(a+b) len(a) len(b) )
    [ append ] 2keep [ >byte-array compress data>> length ] tri@ ;

: compression-distance ( a b -- n )
    compression-lengths sort-pair [ - ] [ / ] bi* ;

: compression-dissimilarity ( a b -- n )
    compression-lengths + / ;

GENERIC: round-to-even ( x -- y )

M: integer round-to-even ; inline

M: ratio round-to-even
    >fraction [ /mod abs 2 * ] keep > [ dup 0 < -1 1 ? + ] when ;

M: float round-to-even
    dup 0 > [
        dup 0x1p52 <= [ 0x1p52 + 0x1p52 - ] when
    ] [
        dup -0x1p52 >= [ 0x1p52 - 0x1p52 + ] when
    ] if ;
