! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.ranges project-euler.common sequences ;
IN: project-euler.092

! http://projecteuler.net/index.php?section=problems&id=92

! DESCRIPTION
! -----------

! A number chain is created by continuously adding the square of the digits in
! a number to form a new number until it has been seen before.

! For example,

!     44 -> 32 -> 13 -> 10 -> 1 -> 1
!     85 -> 89 -> 145 -> 42 -> 20 -> 4 -> 16 -> 37 -> 58 -> 89

! Therefore any chain that arrives at 1 or 89 will become stuck in an endless
! loop. What is most amazing is that EVERY starting number will eventually
! arrive at 1 or 89.

! How many starting numbers below ten million will arrive at 89?


! SOLUTION
! --------

<PRIVATE

: next-link ( n -- m )
    0 swap [ dup zero? not ] [ 10 /mod sq -rot [ + ] dip ] [ ] while drop ;

: chain-ending ( n -- m )
    dup 1 = over 89 = or [ next-link chain-ending ] unless ;

: lower-endings ( -- seq )
    567 [1,b] [ chain-ending ] map ;

: fast-chain-ending ( seq n -- m )
    dup 567 > [ next-link ] when 1- swap nth ;

: count ( seq quot -- n )
    0 -rot [ rot >r call [ r> 1+ ] [ r> ] if ] curry each ; inline

PRIVATE>

: euler092 ( -- answer )
    lower-endings 9999999 [1,b] [ fast-chain-ending 89 = ] with count ;

! [ euler092 ] 10 ave-time
! 11169 ms run / 0 ms GC ave time - 10 trials

MAIN: euler092
