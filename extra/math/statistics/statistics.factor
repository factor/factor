USING: combinators.lib kernel math math.analysis
math.functions math.vectors sequences sequences.lib sorting ;
IN: math.statistics

: mean ( seq -- n )
    #! arithmetic mean, sum divided by length
    [ sum ] keep length / ;

: geometric-mean ( seq -- n )
    #! geometric mean, nth root of product
    [ product ] keep length swap nth-root ;

: harmonic-mean ( seq -- n )
    #! harmonic mean, reciprocal of sum of reciprocals.
    #! positive reals only
    0 [ recip + ] reduce recip ;

: median ( seq -- n )
    #! middle number if odd, avg of two middle numbers if even
    natural-sort dup length dup even? [
        1- 2 / swap [ nth ] 2keep >r 1+ r> nth + 2 /
    ] [
        2 / swap nth
    ] if ;

: range ( seq -- n )
    #! max - min
    minmax swap - ;

: var ( seq -- x )
    #! variance, normalize by N-1
    dup length 1 <= [
        drop 0
    ] [
        [ [ mean ] keep [ - sq ] curry* sigma ] keep
        length 1- /
    ] if ;

: std ( seq -- x )
    #! standard deviation, sqrt of variance
    var sqrt ;

: ((r)) ( mean(x) mean(y) {x} {y} -- (r) )
    ! finds sigma((xi-mean(x))(yi-mean(y)) 
    0 [ [ >r pick r> swap - ] 2apply * + ] 2reduce 2nip ;

: (r) ( mean(x) mean(y) {x} {y} sx sy -- r )
    * recip >r [ ((r)) ] keep length 1- / r> * ;

: [r] ( {{x,y}...} -- mean(x) mean(y) {x} {y} sx sy )
    first2 [ [ [ mean ] 2apply ] 2keep ] 2keep [ std ] 2apply ;

: r ( {{x,y}...} -- r )
    [r] (r) ;

: r^2 ( {{x,y}...} -- r )
    r sq ;

: least-squares ( {{x,y}...} -- alpha beta )
    [r] >r >r >r >r 2dup r> r> r> r>
    ! stack is mean(x) mean(y) mean(x) mean(y) {x} {y} sx sy
    [ (r) ] 2keep ! stack is mean(x) mean(y) r sx sy
    swap / * ! stack is mean(x) mean(y) beta
    [ swapd * - ] keep ;

