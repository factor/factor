! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences ;
IN: rosetta-code.catalan-numbers

! https://rosettacode.org/wiki/Catalan_numbers

! Catalan numbers are a sequence of numbers which can be defined
! directly:
!     Cn = 1/(n+1)(2n n) = (2n)! / (n+1)! * n!      for n >= 0

! Or recursively:
!     C0 = 1
!     Cn+1 = sum(Ci * Cn-i)) {0..n}                 for n >= 0

! Or alternatively (also recursive):
!     C0 = 1
!     Cn = (2 * (2n - 1) / (n + 1)) * Cn-1

! Implement at least one of these algorithms and print out the
! first 15 Catalan numbers with each. Memoization is not required,
! but may be worth the effort when using the second method above.

: next ( seq -- newseq )
    [ ] [ last ] [ length ] tri
    [ 2 * 1 - 2 * ] [ 1 + ] bi /
    * suffix ;

: catalan ( n -- seq )
    V{ 1 } swap 1 - [ next ] times ;
