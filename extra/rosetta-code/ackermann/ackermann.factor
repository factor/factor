! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel math ;
IN: rosetta-code.ackermann

! https://rosettacode.org/wiki/Ackermann_function

! The Ackermann function is a classic recursive example in
! computer science. It is a function that grows very quickly (in
! its value and in the size of its call tree). It is defined as
! follows:

! A(m,n) = {
!     n + 1             if m = 0
!     A(m-1, 1)         if m > 0 and n = 0
!     A(m-1, A(m, n-1)) if m > 0 and n > 0
! }

! Its arguments are never negative and it always terminates.
! Write a function which returns the value of A(m,n). Arbitrary
! precision is preferred (since the function grows so quickly),
! but not required.

:: ackermann ( m n -- u )
    {
        { [ m 0 = ] [ n 1 + ] }
        { [ n 0 = ] [ m 1 - 1 ackermann ] }
        [ m 1 - m n 1 - ackermann ackermann ]
    } cond ;
