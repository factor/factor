! Copyright (C) 2008 Doug Coleman, Michael Judge.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators generalizations kernel locals math
math.functions math.order math.vectors sequences
sequences.private sorting fry arrays grouping sets
splitting.monotonic ;
IN: math.statistics

: power-mean ( seq p -- x )
    [ '[ _ ^ ] map-sum ] [ [ length / ] [ recip ^ ] bi* ] 2bi ; inline

! Delta in degrees-of-freedom
: mean-ddof ( seq ddof -- x )
    [ [ sum ] [ length ] bi ] dip -
    dup zero? [ 2drop 0 ] [ / ] if ; inline

: mean ( seq -- x )
    0 mean-ddof ; inline

: unbiased-mean ( seq -- x )
    1 mean-ddof ; inline

: sum-of-squares ( seq -- x )
    [ sq ] map-sum ; inline

: sum-of-squared-errors ( seq -- x )
    [ mean ] keep [ - sq ] with map-sum ; inline

: sum-of-absolute-errors ( seq -- x )
    [ mean ] keep [ - ] with map-sum ; inline

: quadratic-mean ( seq -- x ) ! root-mean-square
    [ sum-of-squares ] [ length ] bi / sqrt ; inline

: geometric-mean ( seq -- x )
    [ length ] [ product ] bi nth-root ; inline

: harmonic-mean ( seq -- x )
    [ recip ] map-sum recip ; inline

: contraharmonic-mean ( seq -- x )
    [ sum-of-squares ] [ sum ] bi / ; inline

<PRIVATE

: trim-points ( p seq -- from to seq  )
    [ length [ * >integer ] keep over - ] keep ;

PRIVATE>

: trimmed-mean ( seq p -- x )
    swap natural-sort trim-points <slice> mean ;

: winsorized-mean ( seq p -- x )
    swap natural-sort trim-points
    [ <slice> ]
    [ nip dupd nth <array> ]
    [ [ 1 - ] dip nth <array> ] 3tri
    surround mean ;

<PRIVATE

:: ((kth-object)) ( seq k nth-quot exchange-quot quot: ( x y -- ? ) -- elt )
    #! Wirth's method, Algorithm's + Data structues = Programs p. 84
    k seq bounds-check 2drop
    0 :> i!
    0 :> j!
    0 :> l!
    0 :> x!
    seq length 1 - :> m!
    [ l m < ]
    [
        k seq nth x!
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
    k seq nth ; inline

: (kth-object) ( seq k nth-quot exchange-quot quot: ( x y -- ? ) -- elt )
    #! The algorithm modifiers seq, so we clone it
    [ clone ] 4dip ((kth-object)) ; inline

: kth-object-unsafe ( seq k quot: ( x y -- ? ) -- elt )
    [ [ nth-unsafe ] [ exchange-unsafe ] ] dip (kth-object) ; inline

: kth-objects-unsafe ( seq kths quot: ( x y -- ? ) -- elts )
    [ clone ] 2dip
    '[ [ nth-unsafe ] [ exchange-unsafe ]  _ ((kth-object)) ] with map ; inline

PRIVATE>

: kth-object ( seq k quot: ( x y -- ? ) -- elt )
    [ [ nth ] [ exchange ] ] dip (kth-object) ; inline

: kth-objects ( seq kths quot: ( x y -- ? ) -- elts )
    [ clone ] 2dip
    '[ [ nth ] [ exchange ]  _ ((kth-object)) ] with map ; inline

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
! http://mathworld.wolfram.com/Quantile.html
! a + (N + b) q - 1
! could subtract 1 from a

: quantile-x ( a b N q -- x )
    [ + ] dip * + 1 - ; inline

! 2+1/4 frac is 1/4
: frac ( x -- x' )
    >fraction [ /mod nip ] keep / ; inline

:: quantile-indices ( seq qs a b c d -- seq )
    qs [ [ a b seq length ] dip quantile-x ] map ;

:: qabcd ( y-floor y-ceiling x c d -- qabcd )
    y-floor y-ceiling y-floor - c d x frac * + * + ;

:: quantile-abcd ( seq qs a b c d -- quantile )
    seq qs a b c d quantile-indices :> indices
    indices [ [ floor ] [ ceiling ] bi 2array ] map
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

<PRIVATE

: (sequence>assoc) ( seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) assoc -- assoc )
    [ swap curry compose each ] keep ; inline

PRIVATE>

: sequence>assoc! ( assoc seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) -- assoc )
    4 nrot (sequence>assoc) ; inline

: sequence>assoc ( seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) exemplar -- assoc )
    clone (sequence>assoc) ; inline

: sequence>hashtable ( seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) -- hashtable )
    H{ } sequence>assoc ; inline

: histogram! ( hashtable seq -- hashtable )
    [ ] [ inc-at ] sequence>assoc! ;

: histogram-by ( seq quot: ( x -- bin ) -- hashtable )
    [ inc-at ] sequence>hashtable ; inline

: histogram ( seq -- hashtable )
    [ ] histogram-by ;

: sorted-histogram ( seq -- alist )
    histogram sort-values ;

: normalized-histogram ( seq -- alist )
    [ histogram ] [ length ] bi '[ _ / ] assoc-map ;

: collect-pairs ( seq quot: ( x -- v k ) -- hashtable )
    [ push-at ] sequence>hashtable ; inline

: collect-by ( seq quot: ( x -- x' ) -- hashtable )
    [ dup ] prepose collect-pairs ; inline

: mode ( seq -- x )
    histogram >alist
    [ ] [ [ [ second ] bi@ > ] most ] map-reduce first ;

: minmax ( seq -- min max )
    [ first dup ] keep [ [ min ] [ max ] bi-curry bi* ] each ;

: range ( seq -- x )
    minmax swap - ;

: var-ddof ( seq n -- x )
    2dup [ length ] dip - 0 <= [
        2drop 0
    ] [
        [ [ sum-of-squared-errors ] [ length ] bi ] dip - /
    ] if ; inline

: population-var ( seq -- x ) 0 var-ddof ; inline

: sample-var ( seq -- x ) 1 var-ddof ; inline

: std-ddof ( seq n -- x )
    var-ddof sqrt ; inline

: population-std ( seq -- x ) 0 std-ddof ; inline

: sample-std ( seq -- x ) 1 std-ddof ; inline

ALIAS: std sample-std

: signal-to-noise ( seq -- x ) [ mean ] [ population-std ] bi / ;

: mean-dev ( seq -- x ) dup mean v-n vabs mean ;

: median-dev ( seq -- x ) dup median v-n vabs mean ;

: ste-ddof ( seq n -- x ) '[ _ std-ddof ] [ length ] bi sqrt / ;

: population-ste ( seq -- x ) 0 ste-ddof ;

: sample-ste ( seq -- x ) 1 ste-ddof ;

: ((r)) ( mean(x) mean(y) {x} {y} -- (r) )
    ! finds sigma((xi-mean(x))(yi-mean(y))
    0 [ [ [ pick ] dip swap - ] bi@ * + ] 2reduce 2nip ;

: (r) ( mean(x) mean(y) {x} {y} sx sy -- r )
    * recip [ [ ((r)) ] keep length 1 - / ] dip * ;

: [r] ( {{x,y}...} -- mean(x) mean(y) {x} {y} sx sy )
    first2 [ [ [ mean ] bi@ ] 2keep ] 2keep [ population-std ] bi@ ;

: r ( {{x,y}...} -- r )
    [r] (r) ;

: r^2 ( {{x,y}...} -- r )
    r sq ;

: least-squares ( {{x,y}...} -- alpha beta )
    [r] { [ 2dup ] [ ] [ ] [ ] [ ] } spread
    ! stack is mean(x) mean(y) mean(x) mean(y) {x} {y} sx sy
    [ (r) ] 2keep ! stack is mean(x) mean(y) r sx sy
    swap / * ! stack is mean(x) mean(y) beta
    [ swapd * - ] keep ;

: cov-ddof ( {x} {y} ddof -- cov )
    [ [ dup mean v-n ] bi@ v* ] dip mean-ddof ;

: population-cov ( {x} {y} -- cov ) 0 cov-ddof ; inline

: sample-cov ( {x} {y} -- cov ) 1 cov-ddof ; inline

: corr-ddof ( {x} {y} n -- corr )
    [ [ population-cov ] ] dip
    '[ [ _ var-ddof ] bi@ * sqrt ] 2bi / ;

: population-corr ( {x} {y} -- corr ) 0 corr-ddof ; inline

: sample-corr ( {x} {y} -- corr ) 1 corr-ddof ; inline

: cum-map ( seq identity quot -- seq' )
    swapd [ dup ] compose map nip ; inline

: cum-map0 ( seq identity quot -- seq' )
    accumulate nip ; inline

: cum-sum ( seq -- seq' )
    0 [ + ] cum-map ;

: cum-sum0 ( seq -- seq' )
    0 [ + ] cum-map0 ;

: cum-product ( seq -- seq' )
    1 [ * ] cum-map ;

: cum-count ( seq quot -- seq' )
    [ 0 ] dip
    '[ _ call [ 1 + ] when ] cum-map ; inline

: cum-min ( seq -- seq' )
    dup ?first [ min ] cum-map ;

: cum-max ( seq -- seq' )
    dup ?first [ max ] cum-map ;

: entropy ( probabilities -- n )
    dup sum '[ _ / dup log * ] map-sum neg ;

: maximum-entropy ( probabilities -- n )
    length log ;

: normalized-entropy ( probabilities -- n )
    [ entropy ] [ maximum-entropy ] bi / ;

: binary-entropy ( p -- h )
    [ dup log * ] [ 1 swap - dup log * ] bi + neg 2 log / ;

: standardize ( u -- v )
    [ dup mean v-n ] [ sample-std ] bi
    dup zero? [ drop ] [ v/n ] if ;

: standardize-2d ( u -- v )
    flip dup [ [ mean ] [ sample-std ] bi 2array ] map
    [ [ first v-n ] 2map ] keep [ second v/n ] 2map flip ;

: differences ( u -- v )
    [ 1 tail-slice ] keep [ - ] 2map ;

: rescale ( u -- v )
    dup minmax over - [ v-n ] [ v/n ] bi* ;

: rank-values ( seq -- seq' )
    [
        [ ] [ length iota ] bi zip sort-keys
        [ [ first ] bi@ = ] monotonic-split
        [ values ] map [ 0 [ length + ] accumulate nip ] [ ] bi zip
    ] [ length f <array> ] bi
    [ '[ first2 [ _ set-nth ] with each ] each ] keep ;

