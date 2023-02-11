! Copyright (c) 2007 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
IN: project-euler.169
USING: combinators kernel math math.functions project-euler.common ;

! https://projecteuler.net/index.php?section=problems&id=169

! DESCRIPTION
! -----------

! Define f(0) = 1 and f(n) to be the number of different ways n can be
! expressed as a sum of integer powers of 2 using each power no more than
! twice.

! For example, f(10) = 5 since there are five different ways to express 10:

! 1 + 1 + 8
! 1 + 1 + 4 + 4
! 1 + 1 + 2 + 2 + 4
! 2 + 4 + 4
! 2 + 8

! What is f(10^25)?


! SOLUTION
! --------

MEMO: fn ( n -- x )
    {
        { [ dup 2 < ]  [ drop 1 ] }
        { [ dup odd? ] [ 2/ fn ] }
        [ 2/ [ fn ] [ 1 - fn ] bi + ]
    } cond ;

: euler169 ( -- result )
    10 25 ^ fn ;

! [ euler169 ] 100 ave-time
! 0 ms ave run time - 0.2 SD (100 trials)

SOLUTION: euler169
