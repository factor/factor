! Copyright (c) 2007, 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel make math sequences sorting project-euler.common ;
IN: project-euler.009

! https://projecteuler.net/problem=9

! DESCRIPTION
! -----------

! A Pythagorean triplet is a set of three natural numbers, a < b
! < c, for which,
!     a² + b² = c²

! For example, 3² + 4² = 9 + 16 = 25 = 5².

! There exists exactly one Pythagorean triplet for which a + b +
! c = 1000. Find the product abc.


! SOLUTION
! --------

! Algorithm adapted from https://www.friesian.com/pythag.com

<PRIVATE

: next-pq ( p1 q1 -- p2 q2 )
    ! p > q and both are odd integers
    dup 1 = [ drop 2 + dup ] when 2 - ;

: abc ( p q -- triplet )
    [
        2dup * ,         ! a = p * q
        [ sq ] bi@
        [ - 2 / , ]      ! b = (p² - q²) / 2
        [ + 2 / , ] 2bi  ! c = (p² + q²) / 2
    ] { } make sort ;

: (ptriplet) ( target p q triplet -- target p q )
    sum pickd = [ next-pq 2dup abc (ptriplet) ] unless ;

: ptriplet ( target -- triplet )
    3 1 { 3 4 5 } (ptriplet) abc nip ;

PRIVATE>

: euler009 ( -- answer )
    1000 ptriplet product ;

! [ euler009 ] 100 ave-time
! 1 ms ave run time - 0.73 SD (100 trials)

SOLUTION: euler009
