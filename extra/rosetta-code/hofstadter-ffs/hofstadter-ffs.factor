! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math namespaces sequences ;
IN: rosetta-code.hofstadter-ffs

! These two sequences of positive integers are defined as:
!   R(1) = 1 ; S(1) = 1
!   R(n) = R(n-1) + S(n-1)      , n > 1
! The sequence S(n) is further defined as the sequence of
! positive integers not present in R(n).

! Sequence R starts: 1, 3, 7, 12, 18, ...
! Sequence S starts: 2, 4, 5, 6, 8, ...

! Task:

! 1. Create two functions named ffr and ffs that when given n
!    return R(n) or S(n) respectively.
!    (Note that R(1) = 1 and S(1) = 2 to avoid off-by-one errors).
! 2. No maximum value for n should be assumed.
! 3. Calculate and show that the first ten values of R are: 1,
!    3, 7, 12, 18, 26, 35, 45, 56, and 69
! 4. Calculate and show that the first 40 values of ffr plus the
!    first 960 values of ffs include all the integers from 1 to 1000
!    exactly once.

SYMBOL: S  V{ 2 } S set
SYMBOL: R  V{ 1 } R set

: next ( s r -- news newr )
    2dup [ last ] bi@ + suffix
    dup [
        [ dup last 1 + dup ] dip member? [ 1 + ] when suffix
    ] dip ;

: inc-SR ( n -- )
    dup 0 <=
    [ drop ]
    [ [ S get R get ] dip  [ next ] times  R set S set ]
    if ;

: ffs ( n -- S(n) )
    dup S get length - inc-SR
    1 - S get nth ;

: ffr ( n -- R(n) )
    dup R get length - inc-SR
    1 - R get nth ;
