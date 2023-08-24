! Copyright (C) 2017 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private math math.functions
math.functions.private math.private sequences.private ;
IN: math.functions.integer-logs

<PRIVATE

GENERIC: (integer-log10) ( x -- n ) foldable

! For 32 bits systems, we could reduce
! this to the first 27 elements..
CONSTANT: log10-guesses {
    0 0 0 0 1 1 1 2 2 2 3 3 3 3
    4 4 4 5 5 5 6 6 6 6 7 7 7 8
    8 8 9 9 9 9 10 10 10 11 11 11
    12 12 12 12 13 13 13 14 14 14
    15 15 15 15 16 16 16 17 17
}

! This table will hold a few unused bignums on 32 bits systems...
! It could be reduced to the first 8 elements
! Note that even though the 64 bits most-positive-fixnum
! is hardcoded here this table also works (by chance) for 32bit systems.
! This is because there is only one power of 2 greater than the
! greatest power of 10 for 27 bit unsigned integers so we don't
! need to hardcode the 32 bits most-positive-fixnum. See the
! table below for powers of 2 and powers of 10 around the
! most-positive-fixnum.
!
! 67108864  2^26    | 72057594037927936   2^56
! 99999999  10^8    | 99999999999999999  10^17
! 134217727 2^27-1  | 144115188075855872  2^57
!                   | 288230376151711744  2^58
!                   | 576460752303423487  2^59-1
CONSTANT: log10-thresholds {
    9 99 999 9999 99999 999999
    9999999 99999999 999999999
    9999999999 99999999999
    999999999999 9999999999999
    99999999999999 999999999999999
    9999999999999999 99999999999999999
    576460752303423487
}

: fixnum-integer-log10 ( n -- x )
    dup (log2) { array-capacity } declare
    log10-guesses nth-unsafe { array-capacity } declare
    dup log10-thresholds nth-unsafe { fixnum } declare
    rot < [ 1 + ] when ; inline

! bignum-integer-log10-find-down and bignum-integer-log10-find-up
! work with very bad guesses, but in practice they will never loop
! more than once.
: bignum-integer-log10-find-down ( guess 10^guess n -- log10 )
    [ 2dup > ] [ [ [ 1 - ] [ 10 / ] bi* ] dip ] do while 2drop ;

: bignum-integer-log10-find-up ( guess 10^guess n -- log10 )
    [ 10 * ] dip
    [ 2dup <= ] [ [ [ 1 + ] [ 10 * ] bi* ] dip ] while 2drop ;

: bignum-integer-log10-guess ( n -- guess 10^guess )
    (log2) >integer log10-2 * >integer dup 10^ ;

: bignum-integer-log10 ( n -- x )
    [ bignum-integer-log10-guess ] keep 2dup >
    [ bignum-integer-log10-find-down ]
    [ bignum-integer-log10-find-up ] if ; inline

M: fixnum (integer-log10) fixnum-integer-log10 { fixnum } declare ; inline

M: bignum (integer-log10) bignum-integer-log10 ; inline

PRIVATE>

<PRIVATE

GENERIC: (integer-log2) ( x -- n ) foldable

M: integer (integer-log2) (log2) ; inline

: ((ratio-integer-log)) ( ratio quot -- log )
    [ >integer ] dip call ; inline

: (ratio-integer-log) ( ratio quot base -- log )
    pick 1 >=
    [ drop ((ratio-integer-log)) ] [
        [ recip ] 2dip
        [ drop ((ratio-integer-log)) ] [ nip pick ^ = ] 3bi
        [ 1 + ] unless neg
    ] if ; inline

M: ratio (integer-log2) [ (integer-log2) ] 2 (ratio-integer-log) ;

M: ratio (integer-log10) [ (integer-log10) ] 10 (ratio-integer-log) ;

PRIVATE>

: integer-log10 ( x -- n )
    assert-positive (integer-log10) ; inline

: integer-log2 ( x -- n )
    assert-positive (integer-log2) ; inline
