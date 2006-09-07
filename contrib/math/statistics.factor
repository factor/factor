IN: math-contrib
USING: kernel math sequences ;

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
    dup length 1- dup zero? [
        0 2nip
    ] [
        swap [ mean ] keep 0 [ pick - sq + ] reduce nip swap /
    ] if ;

: std ( seq -- x )
    #! standard deviation, sqrt of variance
    var sqrt ;
