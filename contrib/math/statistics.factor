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

! : number-sort [ - ] sort ;
: median ( seq -- n )
    #! middle number if odd, avg of two middle numbers if even
    [ - ] sort dup length dup even? [
        1+ 2 /i dup 1- rot [ nth ] keep swapd nth + 2 /
    ] [
        2 /i swap nth
    ] if ;

: range ( seq -- n )
    #! max - min
    minmax swap - ;

: var ( seq -- )
    #! variance, normalize by N-1
    dup length 1- dup 0 = [
        0 2nip
    ] [
        swap [ mean ] keep 0 [ pick - sq + ] reduce nip swap /
    ] if ;

: std
    #! standard deviation, sqrt of variance
    var sqrt ;
