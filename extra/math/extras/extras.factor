! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs byte-arrays combinators
combinators.short-circuit compression.zlib grouping kernel
kernel.private math math.bitwise math.combinatorics
math.constants math.functions math.order math.primes
math.primes.factors math.statistics math.vectors namespaces
random random.private ranges ranges.private sequences
sequences.extras sequences.private sets sorting sorting.extras ;

IN: math.extras

DEFER: stirling

<PRIVATE

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

DEFER: bernoulli

<PRIVATE

: (bernoulli) ( p -- n )
    [ <iota> ] [ 1 + ] bi [
        0 [ [ nCk ] [ bernoulli * ] bi + ] with reduce
    ] keep recip neg * ;

PRIVATE>

MEMO: bernoulli ( p -- n )
    [ 1 ] [ (bernoulli) ] if-zero ;

! From page 4 https://arxiv.org/ftp/arxiv/papers/2201/2201.12601.pdf
: bernoulli-estimate-factorial ( n -- n! )
    [ 2pi swap ^ ] [ bernoulli ] bi * 2 / ;

: chi2 ( actual expected -- n )
    0 [ dup 0 > [ [ - sq ] keep / + ] [ 2drop ] if ] 2reduce ;

<PRIVATE

: check-df ( df -- df )
    dup even? [ "odd degrees of freedom" throw ] unless ;

: (chi2P) ( chi/2 df/2 -- p )
    [1..b) dupd n/v cum-product swap neg e^ [ v*n sum ] keep + ;

PRIVATE>

: chi2P ( chi df -- p )
    check-df [ 2.0 / ] [ 2 /i ] bi* (chi2P) 1.0 min ;

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
    [ 1 ] 2dip '[ dupd swap - _ * + dup ] map nip ;

: moving-median ( u n -- v )
    <clumps> [ median ] map ;

: moving-maximum ( u n -- v )
    <clumps> [ maximum ] map ;

: moving-minimum ( u n -- v )
    <clumps> [ minimum ] map ;

ALIAS: moving-supremum moving-maximum deprecated
ALIAS: moving-infimum moving-minimum deprecated

: moving-sum ( u n -- v )
    <clumps> [ sum ] map ;

: moving-count ( ... u n quot: ( ... elt -- ... ? ) -- ... v )
    [ <clumps> ] [ '[ _ count ] map ] bi* ; inline

: nonzero ( seq -- seq' )
    [ zero? ] reject ;

: bartlett ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [ <iota> ] [ 1 - 2 / ] bi [
            [ recip * ] [ >= ] 2bi [ 2 swap - ] when
        ] curry map
    ] if ;

: [0,2pi] ( n -- seq )
    [ <iota> ] [ 1 - 2pi swap / ] bi v*n ;

: hanning ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [0,2pi] [ cos -0.5 * 0.5 + ] map!
    ] if ;

: hamming ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [0,2pi] [ cos -0.46 * 0.54 + ] map!
    ] if ;

: blackman ( n -- seq )
    dup 1 <= [ 1 = [ 1 1array ] [ { } ] if ] [
        [0,2pi] [
            [ cos -0.5 * ] [ 2 * cos 0.08 * ] bi + 0.42 +
        ] map
    ] if ;

: nan-sum ( seq -- n )
    0 [ dup fp-nan? [ drop ] [ + ] if ] binary-reduce ;

: nan-min ( seq -- n )
    [ fp-nan? ] reject minimum ;

: nan-max ( seq -- n )
    [ fp-nan? ] reject maximum ;

: fill-nans ( seq -- newseq )
    [ first ] keep [
        dup fp-nan? [ drop dup ] [ nip dup ] if
    ] map nip ;

: sinc ( x -- y )
    [ 1 ] [ pi * [ sin ] [ / ] bi ] if-zero ;

: cum-reduce ( seq identity quot: ( prev elt -- next ) -- result cum-result )
    [ dup rot ] dip dup '[ _ curry dip dupd @ ] each ; inline

<PRIVATE

:: (gini) ( seq -- x )
    seq sort :> sorted
    seq length :> len
    sorted 0 [ + ] cum-reduce :> ( a b )
    b len a * / :> c
    1 len recip + 2 c * - ;

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

: weighted-random ( histogram -- obj )
    unzip cum-sum [ last >float random ] keep bisect-left swap nth ;

: weighted-randoms-as ( length histogram exemplar -- seq )
    [
        unzip cum-sum swap
        [ [ last >float random-generator get ] keep ] dip
        '[ _ _ random* _ bisect-left _ nth ]
    ] dip replicate-as ; inline

: weighted-randoms ( length histogram -- seq )
    { } weighted-randoms-as ;

: unique-indices ( seq -- unique indices )
    [ members ] keep over dup length <iota>
    H{ } zip-as '[ _ at ] map ;

: digitize] ( seq bins -- seq' )
    '[ _ bisect-left ] map ;

: digitize) ( seq bins -- seq' )
    '[ _ bisect-right ] map ;

<PRIVATE

: steps ( a b length -- a b step )
    [ 2dup swap - ] dip / ; inline

PRIVATE>

: linspace[a..b) ( a b length -- seq )
    steps ..b) <range> ;

: linspace[a..b] ( a b length -- seq )
    {
        { [ dup 1 < ] [ 3drop { } ] }
        { [ dup 1 = ] [ 2drop 1array ] }
        [ 1 - steps <range> ]
    } cond ;

: logspace[a..b) ( a b length base -- seq )
    [ linspace[a..b) ] dip swap n^v ;

: logspace[a..b] ( a b length base -- seq )
    [ linspace[a..b] ] dip swap n^v ;

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

GENERIC: round-away-from-zero ( x -- y )

M: integer round-away-from-zero ; inline

M: real round-away-from-zero
    dup 0 < [ floor ] [ ceiling ] if ;

: monotonic-count ( seq quot: ( elt1 elt2 -- ? ) -- newseq )
    over empty? [ 2drop { } ] [
        [ 0 swap unclip-slice swap ] dip '[
            [ @ [ 1 + ] [ drop 0 ] if ] keep over
        ] { } map-as 2nip 0 prefix
    ] if ; inline

: max-monotonic-count ( seq quot: ( elt1 elt2 -- ? ) -- n )
    over empty? [ 2drop 0 ] [
        [ 0 swap unclip-slice swap 0 ] dip '[
            [ swapd @ [ 1 + ] [ max 0 ] if ] 1check
        ] reduce nip max
    ] if ; inline

<PRIVATE

: kahan+ ( c sum elt -- c' sum' )
    rot - 2dup + [ -rot [ - ] bi@ ] keep ; inline

PRIVATE>

: kahan-sum ( seq -- n )
    [ 0.0 0.0 ] dip [ kahan+ ] each nip ;

: map-kahan-sum ( ... seq quot: ( ... elt -- ... n ) -- ... n )
    [ 0.0 0.0 ] 2dip [ 2dip rot kahan+ ] curry
    [ -rot ] prepose each nip ; inline

<PRIVATE

! Adaptive Precision Floating-Point Arithmetic and Fast Robust Geometric Predicates
! www-2.cs.cmu.edu/afs/cs/project/quake/public/papers/robust-arithmetic.ps

: sort-partial ( x y -- x' y' )
    2dup [ abs ] bi@ < [ swap ] when ; inline

:: partial+ ( x y -- hi lo )
    x y + dup x - :> yr y yr - ; inline

:: partial-sums ( seq -- seq' )
    V{ } clone :> partials
    seq [
        0 partials [
            swapd sort-partial partial+ swapd
            [ over partials set-nth 1 + ] unless-zero
        ] each :> i
        i partials shorten
        [ i partials set-nth ] unless-zero
    ] each partials ;

:: sum-exact ( partials -- n )
    partials [ 0.0 ] [
        ! sum from the top, stop when sum becomes inexact
        [ 0.0 0.0 ] dip [
            nip partial+ dup 0.0 = not
        ] find-last drop :> ( lo n )

        ! make half-even rounding work across multiple partials
        n [ 0 > ] [ f ] if* [
            n 1 - partials nth
            [ 0.0 < lo 0.0 < and ]
            [ 0.0 > lo 0.0 > and ] bi or [
                lo 2.0 * :> y
                dup y + :> x
                x over - :> yr
                y yr = [ drop x ] when
            ] when
        ] when
    ] if-empty ;

PRIVATE>

: sum-floats ( seq -- n )
    partial-sums sum-exact ;

: mobius ( n -- x )
    group-factors values [ 1 ] [
        dup [ 1 > ] any?
        [ drop 0 ] [ length even? 1 -1 ? ] if
    ] if-empty ;

: kelly ( winning-probability odds -- fraction )
    [ 1 + * 1 - ] [ / ] bi ;

<PRIVATE

: reduce-evens ( value u v -- value' u' v' )
    [ 2dup [ even? ] both? ] [ [ 2 * ] [ 2/ ] [ 2/ ] tri* ] while ;

: reduce-odds ( value u v -- value' u' v' )
    [
        [ [ dup even? ] [ 2/ ] while ] bi@
        2dup <=> {
            { +eq+ [ over '[ _ * ] 2dip f ] }
            { +lt+ [ swap [ - ] keep t ] }
            { +gt+ [ [ - ] keep t ] }
        } case
    ] loop ;

PRIVATE>

: stein ( u v -- w )
    2dup [ zero? ] both? [ "gcd for zeros is undefined" throw ] when
    [ dup 0 < [ neg ] when ] bi@
    [ 1 ] 2dip reduce-evens reduce-odds 2drop ;

TUPLE: vose
    { n fixnum }
    { items array }
    { probs array }
    { alias array } ;

:: <vose> ( dist -- vose )
    V{ } clone :> small
    V{ } clone :> large
    dist assoc-size :> n
    n f <array> :> alias

    dist unzip dup [ length ] [ sum ] bi /f v*n :> ( items probs )
    probs [ swap 1.0 < small large ? push ] each-index

    [ small empty? large empty? or ] [
        small pop :> s
        large pop :> l
        l s alias set-nth
        l dup probs [ s probs nth + 1 - dup ] change-nth
        1.0 < small large ? push
    ] until

    1.0 large [ probs set-nth ] with each
    1.0 small [ probs set-nth ] with each

    n items probs alias vose boa ;

M:: vose random* ( obj rnd -- elt )
    obj n>> rnd random* { fixnum } declare
    dup obj probs>> nth-unsafe { float } declare rnd random-unit* >=
    [ obj alias>> nth-unsafe { fixnum } declare ] unless
    obj items>> nth-unsafe ;
