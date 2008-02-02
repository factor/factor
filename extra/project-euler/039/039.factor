! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.lib kernel math math.matrices math.ranges namespaces
    sequences ;
IN: project-euler.039

! http://projecteuler.net/index.php?section=problems&id=39

! DESCRIPTION
! -----------

! If p is the perimeter of a right angle triangle with integral length sides,
! {a,b,c}, there are exactly three solutions for p = 120.

!     {20,48,52}, {24,45,51}, {30,40,50}

! For which value of p < 1000, is the number of solutions maximised?


! SOLUTION
! --------

! Algorithm adapted from http://mathworld.wolfram.com/PythagoreanTriple.html

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
    max-p 1- over <range> p-count get
    [ [ 1+ ] change-nth ] curry each ;

: transform ( triple matrix -- new-triple )
    [ 1array ] dip m. first ;

: u-transform ( triple -- new-triple )
    { { 1 2 2 } { -2 -1 -2 } { 2 2 3 } } transform ;

: a-transform ( triple -- new-triple )
    { { 1 2 2 } { 2 1 2 } { 2 2 3 } } transform ;

: d-transform ( triple -- new-triple )
    { { -1 -2 -2 } { 2 1 2 } { 2 2 3 } } transform ;

: (count-perimeters) ( seq -- )
    dup sum max-p < [
        dup sum adjust-p-count
        [ u-transform ] keep [ a-transform ] keep d-transform
        [ (count-perimeters) ] 3apply
    ] [
        drop
    ] if ;

: count-perimeters ( n -- )
    0 <array> p-count set { 3 4 5 } (count-perimeters) ;

PRIVATE>

: euler039 ( -- answer )
    [
        1000 count-perimeters p-count get [ supremum ] keep index
    ] with-scope ;

! [ euler039 ] 100 ave-time
! 2 ms run / 0 ms GC ave time - 100 trials

MAIN: euler039
