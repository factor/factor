! Copyright (C) 2008 Doug Coleman, Michael Judge.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators generalizations kernel locals math
math.functions math.order math.vectors sequences
sequences.private sorting fry arrays grouping sets ;
IN: math.statistics

: mean ( seq -- x )
    [ sum ] [ length ] bi / ;

: geometric-mean ( seq -- x )
    [ length ] [ product ] bi nth-root ;

: harmonic-mean ( seq -- x )
    [ recip ] map-sum recip ;

: contraharmonic-mean ( seq -- x )
    [ [ sq ] map-sum ] [ sum ] bi / ;

<PRIVATE

:: ((kth-object)) ( seq k nth-quot exchange-quot quot: ( x y -- ? ) -- elt )
    #! Wirth's method, Algorithm's + Data structues = Programs p. 84
    #! The algorithm modifiers seq, so we clone it
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
    dup length odd?
    [ lower-median ] [ medians + 2 / ] if ;

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

: collect-pairs ( seq quot: ( x -- v k ) -- hashtable )
    [ push-at ] sequence>hashtable ; inline

: collect-by ( seq quot: ( x -- x' ) -- hashtable )
    [ dup ] prepose collect-pairs ; inline

: mode ( seq -- x )
    histogram >alist
    [ ] [ [ [ second ] bi@ > ] most ] map-reduce first ;

ERROR: empty-sequence ;

: minmax ( seq -- min max )
    [
        empty-sequence
    ] [
        [ first dup ] keep [ [ min ] [ max ] bi-curry bi* ] each
    ] if-empty ;

: range ( seq -- x )
    minmax swap - ;

: sample-var ( seq -- x )
    #! normalize by N-1
    dup length 1 <= [
        drop 0
    ] [
        [ [ mean ] keep [ - sq ] with map-sum ]
        [ length 1 - ] bi /
    ] if ;

: full-var ( seq -- x )
    dup length 1 <= [
        drop 0
    ] [
        [ [ mean ] keep [ - sq ] with map-sum ]
        [ length ] bi /
    ] if ;

ALIAS: var sample-var

: sample-std ( seq -- x ) sample-var sqrt ;

: full-std ( seq -- x ) full-var sqrt ;

ALIAS: std sample-std

: mean-dev ( seq -- x ) dup mean v-n vabs mean ;

: median-dev ( seq -- x ) dup median v-n vabs mean ;

: sample-ste ( seq -- x ) [ sample-std ] [ length ] bi sqrt / ;

: full-ste ( seq -- x ) [ full-std ] [ length ] bi sqrt / ;

ALIAS: ste sample-ste

: ((r)) ( mean(x) mean(y) {x} {y} -- (r) )
    ! finds sigma((xi-mean(x))(yi-mean(y))
    0 [ [ [ pick ] dip swap - ] bi@ * + ] 2reduce 2nip ;

: (r) ( mean(x) mean(y) {x} {y} sx sy -- r )
    * recip [ [ ((r)) ] keep length 1 - / ] dip * ;

: [r] ( {{x,y}...} -- mean(x) mean(y) {x} {y} sx sy )
    first2 [ [ [ mean ] bi@ ] 2keep ] 2keep [ std ] bi@ ;

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

: cov ( {x} {y} -- cov )
    [ dup mean v-n ] bi@ v* mean ;

: sample-corr ( {x} {y} -- corr )
     [ cov ] [ [ sample-var ] bi@ * sqrt ] 2bi / ;

: full-corr ( {x} {y} -- corr )
     [ cov ] [ [ full-var ] bi@ * sqrt ] 2bi / ;

ALIAS: corr sample-corr

: cum-sum ( seq -- seq' )
    0 swap [ + dup ] map nip ;

: cum-product ( seq -- seq' )
    1 swap [ * dup ] map nip ;

: cum-min ( seq -- seq' )
    [ ?first ] keep [ min dup ] map nip ;

: cum-max ( seq -- seq' )
    [ ?first ] keep [ max dup ] map nip ;

: entropy ( seq -- n )
    dup members [ [ = ] curry count ] with map
    dup sum v/n dup [ log ] map v* sum neg ;

: binary-entropy ( p -- h )
    [ dup log * ] [ 1 swap - dup log * ] bi + neg 2 log / ;

: standardize ( u -- v )
    [ dup mean v-n ] [ std ] bi v/n ;

: differences ( u -- v )
    [ 1 tail-slice ] keep [ - ] 2map ;

: rescale ( u -- v )
    [ ] [ infimum ] [ supremum over - ] tri
    [ v-n ] [ v/n ] bi* ;
