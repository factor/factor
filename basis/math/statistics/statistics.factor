! Copyright (C) 2008 Doug Coleman, Michael Judge.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel math math.functions
math.order sequences sorting locals sequences.private
assocs fry ;
IN: math.statistics

: mean ( seq -- x )
    [ sum ] [ length ] bi / ;

: geometric-mean ( seq -- x )
    [ length ] [ product ] bi nth-root ;

: harmonic-mean ( seq -- x )
    [ recip ] map-sum recip ;

:: kth-smallest ( seq k -- elt )
    #! Wirth's method, Algorithm's + Data structues = Programs p. 84
    #! The algorithm modifiers seq, so we clone it
    seq clone :> seq
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
            [ i seq nth-unsafe x < ] [ i 1 + i! ] while
            [ x j seq nth-unsafe < ] [ j 1 - j! ] while
            i j <= [
                i j seq exchange-unsafe
                i 1 + i!
                j 1 - j!
            ] when
        ] do while

        j k < [ i l! ] when
        k i < [ j m! ] when
    ] while
    k seq nth ; inline

: lower-median ( seq -- elt )
    dup dup length odd? [ midpoint@ ] [ midpoint@ 1 - ] if kth-smallest ;

: upper-median ( seq -- elt )
    dup midpoint@ kth-smallest ;

: medians ( seq -- lower upper )
    [ lower-median ] [ upper-median ] bi ;

: median ( seq -- x )
    dup length odd? [ lower-median ] [ medians + 2 / ] if ;

: frequency ( seq -- hashtable )
    H{ } clone [ '[ _ inc-at ] each ] keep ;

: mode ( seq -- x )
    frequency >alist
    [ ] [ [ [ second ] bi@ > ] 2keep ? ] map-reduce first ;

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    [ 1/0. -1/0. ] dip [ [ min ] [ max ] bi-curry bi* ] each ;

: range ( seq -- x )
    minmax swap - ;

: var ( seq -- x )
    #! normalize by N-1
    dup length 1 <= [
        drop 0
    ] [
        [ [ mean ] keep [ - sq ] with map-sum ]
        [ length 1 - ] bi /
    ] if ;

: std ( seq -- x ) var sqrt ;

: ste ( seq -- x ) [ std ] [ length ] bi sqrt / ;

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
