! Copyright (c) 2010 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: grouping kernel math project-euler.common ranges
sequences sequences.cords ;
IN: project-euler.206

! https://projecteuler.net/problem=206

! DESCRIPTION
! -----------

! Find the unique positive integer whose square has the form
! 1_2_3_4_5_6_7_8_9_0, where each “_” is a single digit.


! SOLUTION
! --------

! Through mathematical analysis, we know that the number must
! end in 00, and the only way to get the last digits to be 900,
! is for our answer to end in 30 or 70.

<PRIVATE

! 1020304050607080900 sqrt, rounded up to the nearest 30 ending
CONSTANT: lo 1010101030

! 1929394959697989900 sqrt, rounded down to the nearest 70 ending
CONSTANT: hi 1389026570

: form-fitting? ( n -- ? )
    number>digits 2 group [ first ] map
    { 1 2 3 4 5 6 7 8 9 0 } sequence= ;

: candidates ( -- seq )
    lo lo 40 + [ hi 100 <range> ] bi@ cord-append ;

PRIVATE>

: euler206 ( -- answer )
    candidates [ sq form-fitting? ] find-last nip ;

! [ euler206 ] 100 ave-time
! 321 ms ave run time - 8.33 SD (100 trials)

SOLUTION: euler206
