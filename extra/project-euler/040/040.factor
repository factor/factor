! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser sequences project-euler.common ;
IN: project-euler.040

! https://projecteuler.net/index.php?section=problems&id=40

! DESCRIPTION
! -----------

! An irrational decimal fraction is created by concatenating the positive
! integers:

!     0.123456789101112131415161718192021...

! It can be seen that the 12th digit of the fractional part is 1.

! If dn represents the nth digit of the fractional part, find the value of the
! following expression.

!     d1 × d10 × d100 × d1000 × d10000 × d100000 × d1000000


! SOLUTION
! --------

<PRIVATE

: (concat-upto) ( n limit str -- str )
    2dup length > [
        pick number>string append! [ 1 + ] 2dip (concat-upto)
    ] [
        2nip
    ] if ;

: concat-upto ( n -- str )
    SBUF" " clone 1 -rot (concat-upto) ;

: nth-integer ( n str -- m )
    [ 1 - ] dip nth digit> ;

PRIVATE>

: euler040 ( -- answer )
    1000000 concat-upto { 1 10 100 1000 10000 100000 1000000 }
    [ swap nth-integer ] with map product ;

! [ euler040 ] 100 ave-time
! 444 ms ave run time - 23.64 SD (100 trials)

SOLUTION: euler040
