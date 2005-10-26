IN: math-contrib
USING: kernel math sequences ;

: mean ( seq -- n )
    #! arithmetic mean, sum divided by length
    [ sum ] keep length / ;

: geo-mean ( seq -- n )
    #! geometric mean, nth root of product
    [ product ] keep length swap nth-root ;

: median ( seq -- n )
    #! middle number if odd, avg of two middle numbers if even
    number-sort dup length dup even? [
        1+ 2 /i dup 1- rot [ nth ] keep swapd nth + 2 /
    ] [
        2 / swap nth
    ] if ;

: range ( seq -- n )
    #! max - min
    number-sort [ first ] keep pop swap - ;

: var ( seq -- )
    #! variance, normalize by N-1
    dup length 1- dup 0 = [
        0 2nip
    ] [
        swap [ mean ] keep [ over - sq ] map sum nip swap /
    ] if ;

: std
    #! standard deviation, sqrt of variance
    var sqrt ;

