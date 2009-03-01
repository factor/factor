! Copyright (c) 2008 Eric Mertens.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions sequences ;
IN: project-euler.148

! http://projecteuler.net/index.php?section=problems&id=148

! DESCRIPTION
! -----------

! We can easily verify that none of the entries in the first seven rows of
! Pascal's triangle are divisible by 7:

!                             1
!                         1       1
!                     1       2       1
!                 1       3       3       1
!             1       4       6       4       1
!         1       5      10      10       5       1
!    1        6      15      20      15       6       1

! However, if we check the first one hundred rows, we will find that only 2361
! of the 5050 entries are not divisible by 7.

! Find the number of entries which are not divisible by 7 in the first one
! billion (10^9) rows of Pascal's triangle.


! SOLUTION
! --------

<PRIVATE

: sum-1toN ( n -- sum )
    dup 1+ * 2/ ; inline

: >base7 ( x -- y )
    [ dup 0 > ] [ 7 /mod ] produce nip ;

: (use-digit) ( prev x index -- next )
    [ [ 1+ * ] [ sum-1toN 7 sum-1toN ] bi ] dip ^ * + ;

: (euler148) ( x -- y )
    >base7 0 [ (use-digit) ] reduce-index ;

PRIVATE>

: euler148 ( -- answer )
    10 9 ^ (euler148) ;

! [ euler148 ] 100 ave-time
! 0 ms ave run time - 0.17 SD (100 trials)

MAIN: euler148
