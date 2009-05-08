! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.constants math.functions math.parser memoize
    project-euler.common sequences ;
IN: project-euler.025

! http://projecteuler.net/index.php?section=problems&id=25

! DESCRIPTION
! -----------

! The Fibonacci sequence is defined by the recurrence relation:

!     Fn = Fn-1 + Fn-2, where F1 = 1 and F2 = 1.

! Hence the first 12 terms will be:

!     F1 = 1
!     F2 = 1
!     F3 = 2
!     F4 = 3
!     F5 = 5
!     F6 = 8
!     F7 = 13
!     F8 = 21
!     F9 = 34
!     F10 = 55
!     F11 = 89
!     F12 = 144

! The 12th term, F12, is the first term to contain three digits.

! What is the first term in the Fibonacci sequence to contain 1000 digits?


! SOLUTION
! --------

! Memoized brute force

MEMO: fib ( m -- n )
    dup 1 > [ [ 1 - fib ] [ 2 - fib ] bi + ] when ;

<PRIVATE

: (digit-fib) ( n term -- term )
    2dup fib number>string length > [ 1+ (digit-fib) ] [ nip ] if ;

: digit-fib ( n -- term )
    1 (digit-fib) ;

PRIVATE>

: euler025 ( -- answer )
    1000 digit-fib ;

! [ euler025 ] 10 ave-time
! 5345 ms ave run time - 105.91 SD (10 trials)


! ALTERNATE SOLUTIONS
! -------------------

! A number containing 1000 digits is the same as saying it's greater than 10**999
! The nth Fibonacci number is Phi**n / sqrt(5) rounded to the nearest integer
! Thus we need we need "Phi**n / sqrt(5) > 10**999", and we just solve for n

<PRIVATE

: digit-fib* ( n -- term )
    1- 5 log10 2 / + phi log10 / ceiling >integer ;

PRIVATE>

: euler025a ( -- answer )
    1000 digit-fib* ;

! [ euler025a ] 100 ave-time
! 0 ms ave run time - 0.17 SD (100 trials)

SOLUTION: euler025a
