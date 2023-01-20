! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ranges project-euler.common
sequences ;
IN: project-euler.085

! https://projecteuler.net/index.php?section=problems&id=85

! DESCRIPTION
! -----------

! By counting carefully it can be seen that a rectangular grid measuring
! 3 by 2 contains eighteen rectangles.

! Although there exists no rectangular grid that contains exactly two million
! rectangles, find the area of the grid with the nearest solution.


! SOLUTION
! --------

! A grid measuring x by y contains x * (x + 1) * y * (x + 1) / 4 rectangles.

<PRIVATE

: distance ( m -- n )
    2000000 - abs ; inline

: rectangles-count ( a b -- n )
    2dup [ 1 + ] bi@ * * * 4 /i ; inline

:: each-unique-product ( ... a b quot: ( ... i j -- ... ) -- ... )
    a b [a..b] [| i |
        i b [a..b] [| j |
            i j quot call
        ] each
    ] each ; inline

TUPLE: result { area read-only } { distance read-only } ;

C: <result> result

: min-by-distance ( seq seq -- seq )
    [ [ distance>> ] bi@ < ] most ; inline

: compute-result ( i j -- pair )
    [ * ] [ rectangles-count distance ] 2bi <result> ; inline

: area-of-nearest ( -- n )
    T{ result f 0 2000000 } 1 2000
    [ compute-result min-by-distance ] each-unique-product area>> ;

PRIVATE>

: euler085 ( -- answer )
    area-of-nearest ;

! [ euler085 ] 100 ave-time
! 791 ms ave run time - 17.15 SD (100 trials)

SOLUTION: euler085
