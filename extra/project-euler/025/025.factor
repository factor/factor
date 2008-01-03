! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser memoize sequences ;
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

MEMO: fib ( m -- n )
    dup 1 > [ 1 - dup fib swap 1 - fib + ] when ;

<PRIVATE

: (digit-fib) ( n term -- term )
    2dup fib number>string length > [ 1+ (digit-fib) ] [ nip ] if ;

: digit-fib ( n -- term )
    1 (digit-fib) ;

PRIVATE>

: euler025 ( -- answer )
    1000 digit-fib ;

! [ euler025 ] 10 ave-time
! 5237 ms run / 72 ms GC ave time - 10 trials

MAIN: euler025
