! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.parser prettyprint ranges sequences ;
IN: rosetta-code.gray-code

! https://rosettacode.org/wiki/Gray_code

! Gray code is a form of binary encoding where transitions
! between consecutive numbers differ by only one bit. This is a
! useful encoding for reducing hardware data hazards with values
! that change rapidly and/or connect to slower hardware as inputs.
! It is also useful for generating inputs for Karnaugh maps in
! order from left to right or top to bottom.

! Create functions to encode a number to and decode a number
! from Gray code. Display the normal binary representations, Gray
! code representations, and decoded Gray code values for all 5-bit
! binary numbers (0-31 inclusive, leading 0's not necessary).

! There are many possible Gray codes. The following encodes what
! is called "binary reflected Gray code."

! Encoding (MSB is bit 0, b is binary, g is Gray code):
!   if b[i-1] = 1
!      g[i] = not b[i]
!   else
!      g[i] = b[i]

! Or:
!   g = b xor (b logically right shifted 1 time)

! Decoding (MSB is bit 0, b is binary, g is Gray code):
!   b[0] = g[0]
!   b[i] = g[i] xor b[i-1]

: gray-encode ( n -- n' ) dup -1 shift bitxor ;

:: gray-decode ( n! -- n' )
    n :> p!
    [ n -1 shift dup n! 0 = not ] [
        p n bitxor p!
    ] while
    p ;

: gray-code-main ( -- )
    -1 32 [a..b] [
        dup [ >bin ] [ gray-encode ] bi
        [ >bin ] [ gray-decode ] bi 4array .
    ] each ;

MAIN: gray-code-main
