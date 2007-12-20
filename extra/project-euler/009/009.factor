! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions namespaces sequences sorting ;
IN: project-euler.009

! http://projecteuler.net/index.php?section=problems&id=9

! DESCRIPTION
! -----------

! A Pythagorean triplet is a set of three natural numbers, a < b < c, for which,
!     a² + b² = c²

! For example, 3² + 4² = 9 + 16 = 25 = 5².

! There exists exactly one Pythagorean triplet for which a + b + c = 1000.
! Find the product abc.


! SOLUTION
! --------

! Algorithm adapted from http://www.friesian.com/pythag.com

<PRIVATE

: next-pq ( p1 q1 -- p2 q2 )
    ! p > q and both are odd integers
    dup 1 = [ swap 2 + nip dup 2 - ] [ 2 - ] if ;

: abc ( p q -- triplet )
    [
        2dup * ,                      ! a = p * q
        2dup sq swap sq swap - 2 / ,  ! b = (p² - q²) / 2
        sq swap sq swap + 2 / ,       ! c = (p² + q²) / 2
    ] { } make natural-sort ;

: (ptriplet) ( target p q triplet -- target p q )
    roll dup >r swap sum = r> -roll
    [
        next-pq 2dup abc (ptriplet)
    ] unless ;

: ptriplet ( target -- triplet )
   3 1 { 3 4 5 } (ptriplet) abc nip ;

PRIVATE>

: euler009 ( -- answer )
    1000 ptriplet product ;

! [ euler009 ] 100 ave-time
! 1 ms run / 0 ms GC ave time - 100 trials

MAIN: euler009
