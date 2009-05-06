! Copyright (C) 2008 Doug Coleman, Michael Judge.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel math math.analysis
math.functions math.order sequences sorting ;
IN: math.statistics

: mean ( seq -- n )
    [ sum ] [ length ] bi / ;

: geometric-mean ( seq -- n )
    [ length ] [ product ] bi nth-root ;

: harmonic-mean ( seq -- n )
    [ recip ] sigma recip ;

: median ( seq -- n )
    natural-sort dup length even? [
        [ midpoint@ dup 1 - 2array ] keep nths mean
    ] [
        [ midpoint@ ] keep nth
    ] if ;

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    [ 1/0. -1/0. ] dip [ [ min ] [ max ] bi-curry bi* ] each ;

: range ( seq -- n )
    minmax swap - ;

: var ( seq -- x )
    #! normalize by N-1
    dup length 1 <= [
        drop 0
    ] [
        [ [ mean ] keep [ - sq ] with sigma ] keep
        length 1 - /
    ] if ;

: std ( seq -- x )
    var sqrt ;

: ste ( seq -- x )
    [ std ] [ length ] bi sqrt / ;

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

