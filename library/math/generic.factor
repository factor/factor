! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: math
USE: errors
USE: generic
USE: kernel
USE: vectors
USE: words

DEFER: number=

: (gcd) ( x y -- z ) dup 0 = [ drop ] [ tuck mod (gcd) ] ifte ;
: gcd ( x y -- z ) abs swap abs 2dup < [ swap ] when (gcd) ;

: >rect ( x -- x:re x: im ) dup real swap imaginary ;
: 2>rect ( x y -- x:re y:re x:im y:im )
    [ swap real swap real ] 2keep
    swap imaginary swap imaginary ;

: 2>fraction ( a/b c/d -- a c b d )
    [ swap numerator swap numerator ] 2keep
    swap denominator swap denominator ;

IN: math-internals

: reduce ( x y -- x' y' )
    dup 0 < [ swap neg swap neg ] when 2dup gcd tuck /i >r /i r> ;
: ratio ( x y -- x/y ) reduce fraction> ;

: ratio= ( a/b c/d -- ? )
    2>fraction number= [ number= ] [ 2drop f ] ifte ;
: ratio-scale ( a/b c/d -- a*d b*c )
    2>fraction >r * swap r> * swap ;
: ratio+d ( a/b c/d -- b*d ) denominator swap denominator * ;
: ratio+ ( x y -- x+y ) 2dup ratio-scale + -rot ratio+d ratio ;
: ratio- ( x y -- x-y ) 2dup ratio-scale - -rot ratio+d ratio ;
: ratio* ( x y -- x*y ) 2>fraction * >r * r> ratio ;
: ratio/ ( x y -- x/y ) ratio-scale ratio ;
: ratio/f ( x y -- x/y ) ratio-scale /f ;

: ratio< ( x y -- ? ) ratio-scale < ;
: ratio<= ( x y -- ? ) ratio-scale <= ;
: ratio> ( x y -- ? ) ratio-scale > ;
: ratio>= ( x y -- ? ) ratio-scale >= ;

: complex= ( x y -- ? )
    2>rect number= [ number= ] [ 2drop f ] ifte ;

: complex+ ( x y -- x+y ) 2>rect + >r + r> rect> ;
: complex- ( x y -- x-y ) 2>rect - >r - r> rect> ;
: complex*re ( x y -- x:re * y:re x:im * r:im )
    2>rect * >r * r> ;
: complex*im ( x y -- x:im * y:re x:re * y:im )
    2>rect >r * swap r> * ;
: complex* ( x y -- x*y )
    2dup complex*re - -rot complex*im + rect> ;
: abs^2 ( x -- y ) >rect sq swap sq + ;
: (complex/) ( x y -- r i m )
    #! r = x:re * y:re + x:im * y:im
    #! i = x:im * y:re - x:re * y:im
    #! m = y:re * y:re + y:im * y:im
    dup abs^2 >r 2dup complex*re + -rot complex*im - r> ;
: complex/ ( x y -- x/y )
    (complex/) tuck / >r / r> rect> ;
: complex/f ( x y -- x/y )
    (complex/) tuck /f >r /f r> rect> ;

IN: math
USE: math-internals

: number= ( x y -- ? )
    {
        [ fixnum= ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
        [ ratio= ]
        [ complex= ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
        [ bignum= ]
        [ float= ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
        [ 2drop f ]
    } 2generic ;

: + ( x y -- x+y )
    {
        [ fixnum+ ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio+ ]
        [ complex+ ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum+ ]
        [ float+ ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: - ( x y -- x-y )
    {
        [ fixnum- ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio- ]
        [ complex- ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum- ]
        [ float- ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: * ( x y -- x*y )
    {
        [ fixnum* ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio* ]
        [ complex* ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum* ]
        [ float* ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: / ( x y -- x/y )
    {
        [ ratio ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio/ ]
        [ complex/ ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio ]
        [ float/f ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: /i ( x y -- x/y )
    {
        [ fixnum/i ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum/i ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: /f ( x y -- x/y )
    {
        [ fixnum/f ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio/f ]
        [ complex/f ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum/f ]
        [ float/f ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: mod ( x y -- x%y )
    {
        [ fixnum-mod ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-mod ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: /mod ( x y -- x/y x%y )
    {
        [ fixnum/mod ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum/mod ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: bitand ( x y -- x&y )
    {
        [ fixnum-bitand ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-bitand ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: bitor ( x y -- x|y )
    {
        [ fixnum-bitor ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-bitor ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: bitxor ( x y -- x^y )
    {
        [ fixnum-bitxor    ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-bitxor    ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: bitnot ( x -- ~x )
    {
        [ fixnum-bitnot    ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-bitnot    ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } generic ;

: shift ( x n -- x<<n )
    {
        [ fixnum-shift     ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum-shift     ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: < ( x y -- ? )
    {
        [ fixnum<          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio<           ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum<          ]
        [ float<           ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: <= ( x y -- ? )
    {
        [ fixnum<=         ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio<=          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum<=         ]
        [ float<=          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: > ( x y -- ? )
    {
        [ fixnum>          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio>           ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum>          ]
        [ float>           ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;

: >= ( x y -- ? )
    {
        [ fixnum>=         ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ ratio>=          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ bignum>=         ]
        [ float>=          ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
        [ undefined-method ]
    } 2generic ;
