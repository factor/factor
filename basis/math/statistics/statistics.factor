! Copyright (C) 2008 Doug Coleman, Michael Judge, Loryn Jenkins.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit fry generalizations grouping kernel
locals math math.functions math.order ranges math.vectors
sequences sequences.private sorting ;
IN: math.statistics

: power-mean ( seq p -- x )
    [ '[ _ ^ ] map-sum ] [ [ length / ] [ recip ^ ] bi* ] 2bi ; inline

! Delta in degrees-of-freedom
: mean-ddof ( seq ddof -- x )
    [ [ sum ] [ length ] bi ] dip -
    [ drop 0 ] [ / ] if-zero ; inline

: mean ( seq -- x )
    0 mean-ddof ; inline

: meanest ( seq -- x )
    [ mean ] keep [ - abs ] with infimum-by ;

GENERIC: sum-of-squares ( seq -- x )
M: object sum-of-squares [ sq ] map-sum ;
M: iota sum-of-squares
    n>> 1 - [ ] [ 1 + ] [ 1/2 + ] tri * * 3 / ;
M: ranges:range sum-of-squares
    dup { [ step>> 1 = ] [ from>> integer? ] } 1&& [
        [ from>> ] [ length>> ] bi dupd +
        [ <iota> sum-of-squares ] bi@ swap -
    ] [ call-next-method ] if ;

GENERIC: sum-of-cubes ( seq -- x )
M: object sum-of-cubes [ 3 ^ ] map-sum ;
M: iota sum-of-cubes sum sq ;
M: ranges:range sum-of-cubes
    dup { [ step>> 1 = ] [ from>> integer? ] } 1&& [
        [ from>> ] [ length>> ] bi dupd +
        [ <iota> sum-of-cubes ] bi@ swap -
    ] [ call-next-method ] if ;

GENERIC: sum-of-quads ( seq -- x )
M: object sum-of-quads [ 4 ^ ] map-sum ;
M: iota sum-of-quads
    [let n>> 1 - :> n
        n 0 > [
            n
            n 1 +
            n 2 * 1 +
            n sq 3 * n 3 * + 1 -
            * * * 30 /
        ] [ 0 ] if
    ] ;
M: ranges:range sum-of-quads
    dup { [ step>> 1 = ] [ from>> integer? ] } 1&& [
        [ from>> ] [ length>> ] bi dupd +
        [ <iota> sum-of-quads ] bi@ swap -
    ] [ call-next-method ] if ;

: sum-of-squared-errors ( seq -- x )
    [ mean ] keep [ - sq ] with map-sum ; inline

: sum-of-absolute-errors ( seq -- x )
    [ mean ] keep [ - ] with map-sum ; inline

: quadratic-mean ( seq -- x ) ! root-mean-square
    [ sum-of-squares ] [ length ] bi / sqrt ; inline

: geometric-mean ( seq -- x )
    [ [ log ] map-sum ] [ length ] bi /f e^ ; inline

: harmonic-mean ( seq -- x )
    [ [ recip ] map-sum ] [ length swap / ] bi ; inline

: contraharmonic-mean ( seq -- x )
    [ sum-of-squares ] [ sum ] bi / ; inline

<PRIVATE

: trim-points ( p seq -- from to seq )
    [ length [ * >integer ] keep over - ] keep ;

PRIVATE>

: trimmed-mean ( seq p -- x )
    swap sort trim-points <slice> mean ;

: winsorized-mean ( seq p -- x )
    swap sort trim-points
    [ <slice> ]
    [ nip dupd nth <array> ]
    [ [ 1 - ] dip nth <array> ] 3tri
    surround mean ;

<PRIVATE

:: kth-object-impl ( seq k nth-quot exchange-quot quot: ( x y -- ? ) -- elt )
    ! Wirth's method, Algorithm's + Data structues = Programs p. 84
    k seq bounds-check 2drop
    0 :> i!
    0 :> j!
    0 :> l!
    0 :> x!
    seq length 1 - :> m!
    [ l m < ]
    [
        k seq nth-unsafe x!
        l i!
        m j!
        [ i j <= ]
        [
            [ i seq nth-quot call x quot call ] [ i 1 + i! ] while
            [ x j seq nth-quot call quot call ] [ j 1 - j! ] while
            i j <= [
                i j seq exchange-quot call
                i 1 + i!
                j 1 - j!
            ] when
        ] do while

        j k < [ i l! ] when
        k i < [ j m! ] when
    ] while
    k seq nth-unsafe ; inline

: (kth-object) ( seq k nth-quot exchange-quot quot: ( x y -- ? ) -- elt )
    ! The algorithm modifies seq, so we clone it
    [ >array ] 4dip kth-object-impl ; inline

: kth-object-unsafe ( seq k quot: ( x y -- ? ) -- elt )
    [ [ nth-unsafe ] [ exchange-unsafe ] ] dip (kth-object) ; inline

: kth-objects-unsafe ( seq kths quot: ( x y -- ? ) -- elts )
    '[ _ kth-object-unsafe ] with map ; inline

PRIVATE>

: kth-object ( seq k quot: ( x y -- ? ) -- elt )
    [ [ nth ] [ exchange ] ] dip (kth-object) ; inline

: kth-objects ( seq kths quot: ( x y -- ? ) -- elts )
    '[ _ kth-object ] with map ; inline

: kth-smallests ( seq kths -- elts ) [ < ] kth-objects-unsafe ;

: kth-smallest ( seq k -- elt ) [ < ] kth-object-unsafe ;

: kth-largests ( seq kths -- elts ) [ > ] kth-objects-unsafe ;

: kth-largest ( seq k -- elt ) [ > ] kth-object-unsafe ;

: count-relative ( seq k -- lt eq gt )
    [ 0 0 0 ] 2dip '[
        _ <=> {
            { +lt+ [ [ 1 + ] 2dip ] }
            { +gt+ [ 1 + ] }
            { +eq+ [ [ 1 + ] dip ] }
        } case
    ] each ;

: minmax-relative ( seq k -- lt eq gt lt-max gt-min )
    [ 0 0 0 -1/0. 1/0. ] 2dip '[
        dup _ <=> {
            { +lt+ [ [ 1 + ] 5 ndip '[ _ max ] dip ] }
            { +gt+ [ [ 1 + ] 3dip min ] }
            { +eq+ [ [ 1 + ] 4dip drop ] }
        } case
    ] each ;

: lower-median-index ( seq -- n )
    [ midpoint@ ]
    [ length odd? [ 1 - ] unless ] bi ;

: lower-median ( seq -- elt )
    [ ] [ lower-median-index ] bi kth-smallest ;

: upper-median ( seq -- elt )
    dup midpoint@ kth-smallest ;

: medians ( seq -- lower upper )
    [ ]
    [ [ lower-median-index ] [ midpoint@ ] bi 2array ]
    bi kth-smallests first2 ;

: median ( seq -- x )
    dup length odd? [ lower-median ] [ medians + 2 / ] if ;

! quantile can be any n-tile. quartile is n = 4, percentile is n = 100
! a,b,c,d parameters, N - number of samples, q is quantile (1/2 for median, 1/4 for 1st quartile)
! https://mathworld.wolfram.com/Quantile.html
! a + (N + b) q - 1
! could subtract 1 from a

: quantile-x ( a b N q -- x )
    [ + ] dip * + 1 - ; inline

! 2+1/4 frac is 1/4
: frac ( x -- x' )
    >fraction [ /mod nip ] keep / ; inline

:: quantile-indices ( seq qs a b -- seq )
    qs [ [ a b seq length ] dip quantile-x ] map ;

:: qabcd ( y-floor y-ceiling x c d -- qabcd )
    y-floor y-ceiling y-floor - c d x frac * + * + ;

:: quantile-abcd ( seq qs a b c d -- quantile )
    seq qs a b quantile-indices :> indices
    indices [ [ floor 0 max ] [ ceiling seq length 1 - min ] bi 2array ] map
    concat :> index-pairs

    seq index-pairs kth-smallests
    2 group indices [ [ first2 ] dip c d qabcd ] 2map ;

: quantile1 ( seq qs -- seq' )
    0 0 1 0 quantile-abcd ;

: quantile3 ( seq qs -- seq' )
    1/2 0 0 0 quantile-abcd ;

: quantile4 ( seq qs -- seq' )
    0 0 0 1 quantile-abcd ;

: quantile5 ( seq qs -- seq' )
    1/2 0 0 1 quantile-abcd ;

: quantile6 ( seq qs -- seq' )
    0 1 0 1 quantile-abcd ;

: quantile7 ( seq qs -- seq' )
    1 -1 0 1 quantile-abcd ;

: quantile8 ( seq qs -- seq' )
    1/3 1/3 0 1 quantile-abcd ;

: quantile9 ( seq qs -- seq' )
    3/8 1/4 0 1 quantile-abcd ;

: quartile ( seq -- seq' )
    { 1/4 1/2 3/4 } quantile5 ;

: interquartile ( seq -- q1 q3 )
    quartile [ first ] [ last ] bi ;

: interquartile-range ( seq -- n )
    interquartile - ;

: midhinge ( seq -- n )
    interquartile + 2 / ;

: trimean ( seq -- x )
    quartile first3 [ 2 * ] dip + + 4 / ;

: histogram-by! ( assoc seq quot: ( x -- bin ) -- hashtable )
    rot [ '[ @ _ inc-at ] each ] keep ; inline

: histogram! ( hashtable seq -- hashtable )
    [ ] histogram-by! ; inline

: histogram-by ( seq quot: ( x -- bin ) -- hashtable )
    [ H{ } clone ] 2dip histogram-by! ; inline

: histogram ( seq -- hashtable )
    [ ] histogram-by ;

: sorted-histogram ( seq -- alist )
    histogram sort-values ;

: normalized-histogram ( seq -- alist )
    [ histogram ] [ length ] bi '[ _ / ] assoc-map ;

: equal-probabilities ( n -- array )
    dup recip <array> ; inline

: mode ( seq -- x )
    histogram >alist [ second ] supremum-by first ;

: minmax ( seq -- min max )
    [ first dup ] keep [ [ min ] [ max ] bi-curry bi* ] 1 each-from ;

: range ( seq -- x )
    minmax swap - ;

: fivenum ( seq -- seq' )
    [ quartile ] [ minmax ] bi [ prefix ] [ suffix ] bi* ;

: var-ddof ( seq n -- x )
    2dup [ length ] dip - 0 <= [
        2drop 0
    ] [
        [ [ sum-of-squared-errors ] [ length ] bi ] dip - /
    ] if ; inline

: population-var ( seq -- x ) 0 var-ddof ; inline

: sample-var ( seq -- x ) 1 var-ddof ; inline

: std-ddof ( seq n -- x ) var-ddof sqrt ; inline

: population-std ( seq -- x ) 0 std-ddof ; inline

: sample-std ( seq -- x ) 1 std-ddof ; inline

ALIAS: std sample-std

: signal-to-noise ( seq -- x ) [ mean ] [ population-std ] bi / ;

: demean ( seq -- seq' ) dup mean v-n ;

: mean-dev ( seq -- x ) demean vabs mean ;

: demedian ( seq -- seq' ) dup median v-n ;

: median-dev ( seq -- x ) demedian vabs mean ;

: ste-ddof ( seq n -- x ) '[ _ std-ddof ] [ length ] bi sqrt / ;

: population-ste ( seq -- x ) 0 ste-ddof ;

: sample-ste ( seq -- x ) 1 ste-ddof ;

<PRIVATE
: r-sum-diffs ( x-mean y-mean x-seq y-seq -- (r) )
    ! finds sigma((xi-mean(x))(yi-mean(y))
    0 [ [ reach - ] bi@ * + ] 2reduce 2nip ;

: (r) ( x-mean y-mean x-seq y-seq x-std y-std -- r )
    * recip [ [ r-sum-diffs ] keep length 1 - / ] dip * ;

: r-stats ( xy-pairs -- x-mean y-mean x-seq y-seq x-std y-std )
    first2 [ [ [ mean ] bi@ ] 2keep ] 2keep [ population-std ] bi@ ;
PRIVATE>

: pearson-r ( xy-pairs -- r ) r-stats (r) ;

: least-squares ( xy-pairs -- alpha beta )
    r-stats [ 2dup ] 4dip
    ! stack is x-mean y-mean x-mean y-mean x-seq y-seq x-std y-std
    [ (r) ] 2keep ! stack is mean(x) mean(y) r sx sy
    swap / * ! stack is mean(x) mean(y) beta
    [ swapd * - ] keep ;

: cov-ddof ( x-seq y-seq ddof -- cov )
    [ [ demean ] bi@ v* ] dip mean-ddof ;

: population-cov ( x-seq y-seq -- cov ) 0 cov-ddof ; inline

: sample-cov ( x-seq y-seq -- cov ) 1 cov-ddof ; inline

: corr-ddof ( x-seq y-seq n -- corr )
    [ [ population-cov ] ] dip
    '[ [ _ var-ddof ] bi@ * sqrt ] 2bi / ;

: population-corr ( x-seq y-seq -- corr ) 0 corr-ddof ; inline

: sample-corr ( x-seq y-seq -- corr ) 1 corr-ddof ; inline

: cum-sum ( seq -- seq' )
    0 [ + ] accumulate* ;

: cum-sum0 ( seq -- seq' )
    0 [ + ] accumulate nip ;

: cum-product ( seq -- seq' )
    1 [ * ] accumulate* ;

: cum-product1 ( seq -- seq' )
    1 [ * ] accumulate nip ;

: cum-mean ( seq -- seq' )
    0 swap [ [ + dup ] dip 1 + / ] map-index nip ;

: cum-count ( seq quot: ( elt -- ? ) -- seq' )
    [ 0 ] dip '[ @ [ 1 + ] when ] accumulate* ; inline

: cum-min ( seq -- seq' )
    dup ?first [ min ] accumulate* ;

: cum-max ( seq -- seq' )
    dup ?first [ max ] accumulate* ;

: entropy ( probabilities -- n )
    dup sum '[ _ / dup log * ] map-sum neg ;

: maximum-entropy ( probabilities -- n )
    length log ;

: normalized-entropy ( probabilities -- n )
    [ entropy ] [ maximum-entropy ] bi / ;

: binary-entropy ( p -- h )
    [ dup log * ] [ 1 swap - dup log * ] bi + neg 2 log / ;

: standardize ( u -- v )
    [ demean ] [ sample-std ] bi [ v/n ] unless-zero ;

: standardize-2d ( u -- v )
    flip [ standardize ] map flip ;

: differences ( u -- v )
    [ rest-slice ] keep v- ;

: rescale ( u -- v )
    dup minmax over - [ v-n ] [ v/n ] bi* ;

<PRIVATE

: rankings ( histogram method: ( min max -- rank ) -- assoc )
    [ sort-keys 0 swap ] dip
    '[ swapd dupd + _ keep -rot ] H{ } assoc-map-as nip ; inline

: rank-by ( seq method: ( min max -- rank ) -- seq' )
    [ dup histogram ] [ rankings ] bi* '[ _ at ] map ; inline

PRIVATE>

: rank-by-avg ( seq -- seq' ) [ + 1 + 2 / ] rank-by ;

: rank-by-min ( seq -- seq' ) [ drop 1 + ] rank-by ;

: rank-by-max ( seq -- seq' ) [ nip ] rank-by ;

ALIAS: rank rank-by-avg

: spearman-corr ( x-seq y-seq -- corr )
    [ rank ] bi@ population-corr ;

: z-score ( seq -- n )
    [ demean ] [ sample-std ] bi v/n ;

: dcg ( scores -- dcg )
    dup length 1 + 2 swap [a..b] [ log 2 log /f ] map v/ sum ;

: ndcg ( scores -- ndcg )
    [ 0.0 ] [
        dup dcg [
            drop 0.0
        ] [
            swap sort <reversed> dcg /f
        ] if-zero
    ] if-empty ;
