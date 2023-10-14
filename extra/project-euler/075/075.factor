! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math ranges namespaces project-euler.common
sequences ;
IN: project-euler.075

! https://projecteuler.net/problem=75

! DESCRIPTION
! -----------

! It turns out that 12 cm is the smallest length of wire can be
! bent to form a right angle triangle in exactly one way, but
! there are many more examples.

!     12 cm: (3,4,5)
!     24 cm: (6,8,10)
!     30 cm: (5,12,13)
!     36 cm: (9,12,15)
!     40 cm: (8,15,17)
!     48 cm: (12,16,20)

! In contrast, some lengths of wire, like 20 cm, cannot be bent
! to form a right angle triangle, and other lengths allow more
! than one solution to be found; for example, using 120 cm it is
! possible to form exactly three different right angle
! triangles.

!     120 cm: (30,40,50), (20,48,52), (24,45,51)

! Given that L is the length of the wire, for how many values of
! L ≤ 2,000,000 can exactly one right angle triangle be formed?


! SOLUTION
! --------

! Algorithm adapted from
! https://mathworld.wolfram.com/PythagoreanTriple.html
! Identical implementation as problem #39

! Basically, this makes an array of 2000000 zeros, recursively
! creates primitive triples using the three transforms and then
! increments the array at index [a+b+c] by one for each triple's
! sum AND its multiples under 2000000 (to account for
! non-primitive triples). The answer is just the total number of
! indexes that are equal to one.

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

: euler075 ( -- answer )
    [
        2000000 count-perimeters p-count get [ 1 = ] count
    ] with-scope ;

! [ euler075 ] 10 ave-time
! 3341 ms ave run timen - 157.77 SD (10 trials)

SOLUTION: euler075
