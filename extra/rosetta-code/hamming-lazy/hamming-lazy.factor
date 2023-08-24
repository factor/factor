! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel lists lists.lazy math ;
IN: rosetta-code.hamming-lazy

! https://rosettacode.org/wiki/Hamming_numbers#Factor

! Hamming numbers are numbers of the form
!    H = 2^i * 3^j * 5^k        where i, j, k >= 0

! Hamming numbers are also known as ugly numbers and also
! 5-smooth numbers (numbers whose prime divisors are less or equal
! to 5).

! Generate the sequence of Hamming numbers, in increasing order.
! In particular:

! 1. Show the first twenty Hamming numbers.
! 2. Show the 1691st Hamming number (the last one below 231).
! 3. Show the one millionth Hamming number (if the language – or
!    a convenient library – supports arbitrary-precision integers).

:: sort-merge ( xs ys -- result )
    xs car :> x
    ys car :> y
    {
        { [ x y < ] [ [ x ] [ xs cdr ys sort-merge ] lazy-cons ] }
        { [ x y > ] [ [ y ] [ ys cdr xs sort-merge ] lazy-cons ] }
        [ [ x ] [ xs cdr ys cdr sort-merge ] lazy-cons ]
    } cond ;

:: hamming ( -- hamming )
    f :> h!
    [ 1 ] [
        h 2 3 5 [ '[ _ * ] lmap-lazy ] tri-curry@ tri
        sort-merge sort-merge
    ] lazy-cons h! h ;
