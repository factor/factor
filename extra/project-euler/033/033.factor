! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges project-euler.common sequences ;
IN: project-euler.033

! https://projecteuler.net/index.php?section=problems&id=33

! DESCRIPTION
! -----------

! The fraction 49/98 is a curious fraction, as an inexperienced mathematician
! in attempting to simplify it may incorrectly believe that 49/98 = 4/8, which
! is correct, is obtained by cancelling the 9s.

! We shall consider fractions like, 30/50 = 3/5, to be trivial examples.

! There are exactly four non-trivial examples of this type of fraction, less
! than one in value, and containing two digits in the numerator and
! denominator.

! If the product of these four fractions is given in its lowest common terms,
! find the value of the denominator.


! SOLUTION
! --------

! Through analysis, you only need to check fractions fitting the pattern ax/xb

<PRIVATE

: source-033 ( -- seq )
    10 99 [a..b] dup cartesian-product concat [ first2 < ] filter ;

: safe? ( ax xb -- ? )
    [ 10 /mod ] bi@ [ = ] dip zero? not and nip ;

: ax/xb ( ax xb -- z/f )
    2dup safe? [ [ 10 /mod ] bi@ 2nip / ] [ 2drop f ] if ;

: curious? ( m n -- ? )
    2dup / [ ax/xb ] dip = ;

: curious-fractions ( seq -- seq )
    [ first2 curious? ] filter [ first2 / ] map ;

PRIVATE>

: euler033 ( -- answer )
    source-033 curious-fractions product denominator ;

! [ euler033 ] 100 ave-time
! 7 ms ave run time - 1.31 SD (100 trials)

SOLUTION: euler033
