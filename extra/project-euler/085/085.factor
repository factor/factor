! Copyright (c) 2009 Guillaume Nargeot.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.ranges project-euler.common sequences ;
IN: project-euler.085

! http://projecteuler.net/index.php?section=problems&id=85

! DESCRIPTION
! -----------

! By counting carefully it can be seen that a rectangular grid measuring
! 3 by 2 contains eighteen rectangles.

! Although there exists no rectangular grid that contains exactly two million
! rectangles, find the area of the grid with the nearest solution.


! SOLUTION
! --------

! A grid measuring x by y contains x * (x + 1) * y * (x + 1) rectangles.

<PRIVATE

: distance ( m -- n )
    2000000 - abs ;

: rectangles-count ( a b -- n )
    2dup [ 1 + ] bi@ * * * 4 / ;

: unique-products ( a b -- seq )
    tuck [a,b] [
        over dupd [a,b] [ 2array ] with map
    ] map concat nip ;

: max-by-last ( seq seq -- seq )
    [ [ last ] bi@ < ] most ;

: array2 ( seq -- a b )
    [ first ] [ last ] bi ;

: convert ( seq -- seq )
    array2 [ * ] [ rectangles-count distance ] 2bi 2array ;

: area-of-nearest ( -- n )
    1 2000 unique-products
    [ convert ] [ max-by-last ] map-reduce first ;

PRIVATE>

: euler085 ( -- answer )
    area-of-nearest ;

! [ euler085 ] 100 ave-time
! 2285 ms ave run time - 4.8 SD (100 trials)

SOLUTION: euler085
