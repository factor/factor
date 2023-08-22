! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math ranges namespaces project-euler.common
sequences sequences.extras ;
IN: project-euler.039

! https://projecteuler.net/index.php?section=problems&id=39

! DESCRIPTION
! -----------

! If p is the perimeter of a right angle triangle with integral length sides,
! {a,b,c}, there are exactly three solutions for p = 120.

!     {20,48,52}, {24,45,51}, {30,40,50}

! For which value of p < 1000, is the number of solutions maximized?


! SOLUTION
! --------

! Algorithm adapted from https://mathworld.wolfram.com/PythagoreanTriple.html
! Identical implementation as problem #75

! Basically, this makes an array of 1000 zeros, recursively creates primitive
! triples using the three transforms and then increments the array at index
! [a+b+c] by one for each triple's sum AND its multiples under 1000 (to account
! for non-primitive triples). The answer is just the index that has the highest
! number.

SYMBOL: p-count

<PRIVATE

: max-p ( -- n )
    p-count get length ;

: adjust-p-count ( n -- )
    max-p 1 - over <range> p-count get
    [ [ 1 + ] change-nth ] curry each ;

: (count-perimeters) ( seq -- )
    dup sum max-p < [
        dup sum adjust-p-count
        [ u-transform ] [ a-transform ] [ d-transform ] tri
        [ (count-perimeters) ] tri@
    ] [
        drop
    ] if ;

: count-perimeters ( n -- )
    0 <array> p-count set { 3 4 5 } (count-perimeters) ;

PRIVATE>

: euler039 ( -- answer )
    [
        1000 count-perimeters p-count get arg-max
    ] with-scope ;

! [ euler039 ] 100 ave-time
! 1 ms ave run time - 0.37 SD (100 trials)

SOLUTION: euler039
