! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math math.functions
    project-euler.common sequences sorting grouping ;
IN: project-euler.052

! https://projecteuler.net/index.php?section=problems&id=52

! DESCRIPTION
! -----------

! It can be seen that the number, 125874, and its double, 251748, contain
! exactly the same digits, but in a different order.

! Find the smallest positive integer, x, such that 2x, 3x, 4x, 5x, and 6x,
! contain the same digits.


! SOLUTION
! --------

! Analysis shows the number must be odd, divisible by 3, and larger than 123456

<PRIVATE

: map-nx ( n x -- seq )
    <iota> [ 1 + * ] with map ; inline

: all-same-digits? ( seq -- ? )
    [ number>digits sort ] map all-equal? ;

: candidate? ( n -- ? )
    { [ odd? ] [ 3 divisor? ] } 1&& ;

: next-all-same ( x n -- n )
    dup candidate? [
        2dup swap map-nx all-same-digits?
        [ nip ] [ 1 + next-all-same ] if
    ] [
        1 + next-all-same
    ] if ;

PRIVATE>

: euler052 ( -- answer )
    6 123456 next-all-same ;

! [ euler052 ] 100 ave-time
! 92 ms ave run time - 6.29 SD (100 trials)

SOLUTION: euler052
