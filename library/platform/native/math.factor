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
USE: combinators
USE: errors
USE: kernel
USE: stack
USE: vectors
USE: words

: (gcd) ( x y -- z ) dup 0 = [ drop ] [ tuck mod (gcd) ] ifte ;
: gcd ( x y -- z ) abs swap abs 2dup < [ swap ] when (gcd) ;

: reduce ( x y -- x' y' )
    dup 0 < [ swap neg swap neg ] when 2dup gcd tuck /i >r /i r> ;
: ratio ( x y -- x/y ) reduce fraction> ;
: >fraction ( a/b -- a b ) dup numerator swap denominator ;
: 2>fraction ( a/b c/d -- a b c d ) >r >fraction r> >fraction ;

: ratio= ( a/b c/d -- ? ) 2>fraction 2= ;
: ratio-scale ( a/b c/d -- a*d b*c ) 2>fraction -rot * >r * r> ;
: ratio+d ( a/b c/d -- b*d ) denominator swap denominator * ;
: ratio+ ( x y -- x+y ) 2dup ratio-scale + -rot ratio+d ratio ;
: ratio- ( x y -- x-y ) 2dup ratio-scale - -rot ratio+d ratio ;
: ratio* ( x y -- x*y ) 2>fraction swapd * >r * r> ratio ;
: ratio/ ( x y -- x/y ) ratio-scale ratio ;
: ratio/f ( x y -- x/y ) ratio-scale /f ;

: ratio< ( x y -- ? ) ratio-scale < ;
: ratio<= ( x y -- ? ) ratio-scale <= ;
: ratio> ( x y -- ? ) ratio-scale > ;
: ratio>= ( x y -- ? ) ratio-scale >= ;

: >rect ( x -- x:re x: im ) dup real swap imaginary ;
: 2>rect ( x y -- x:re x:im y:re y:im ) >r >rect r> >rect ;

: complex= ( x y -- ? ) 2>rect 2= ;
: complex+ ( x y -- x+y ) 2>rect swapd + >r + r> rect> ;
: complex- ( x y -- x-y ) 2>rect swapd - >r - r> rect> ;
: complex*re ( x y -- zx:re * y:re x:im * r:im )
    2>rect swapd * >r * r> ;
: complex*im ( x y -- x:re * y:im x:im * y:re )
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

: no-method ( -- )
    "No applicable method" throw ;

: (not-=) ( x y -- f )
    2drop f ;

: number= ( x y -- ? )
    {
        fixnum=
        (not-=)
        (not-=)
        (not-=)
        ratio=
        complex=
        (not-=)
        (not-=)
        (not-=)
        (not-=)
        (not-=)
        (not-=)
        (not-=)
        bignum=
        float=
        (not-=)
        (not-=)
    } 2generic ;

: + ( x y -- x+y )
    {
        fixnum+
        no-method
        no-method
        no-method
        ratio+
        complex+
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum+
        float+
        no-method
        no-method
    } 2generic ;

: - ( x y -- x-y )
    {
        fixnum-
        no-method
        no-method
        no-method
        ratio-
        complex-
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-
        float-
        no-method
        no-method
    } 2generic ;

: * ( x y -- x*y )
    {
        fixnum*
        no-method
        no-method
        no-method
        ratio*
        complex*
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum*
        float*
        no-method
        no-method
    } 2generic ;

: / ( x y -- x/y )
    {
        ratio
        no-method
        no-method
        no-method
        ratio/
        complex/
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        ratio
        float/f
        no-method
        no-method
    } 2generic ;

: /i ( x y -- x/y )
    {
        fixnum/i
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum/i
        no-method
        no-method
        no-method
    } 2generic ;

: /f ( x y -- x/y )
    {
        fixnum/f
        no-method
        no-method
        no-method
        ratio/f
        complex/f
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum/f
        float/f
        no-method
        no-method
    } 2generic ;

: mod ( x y -- x%y )
    {
        fixnum-mod
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-mod
        no-method
        no-method
        no-method
    } 2generic ;

: /mod ( x y -- x/y x%y )
    {
        fixnum/mod
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum/mod
        no-method
        no-method
        no-method
    } 2generic ;

: bitand ( x y -- x&y )
    {
        fixnum-bitand
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-bitand
        no-method
        no-method
        no-method
    } 2generic ;

: bitor ( x y -- x|y )
    {
        fixnum-bitor
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-bitor
        no-method
        no-method
        no-method
    } 2generic ;

: bitxor ( x y -- x^y )
    {
        fixnum-bitxor
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-bitxor
        no-method
        no-method
        no-method
    } 2generic ;

: bitnot ( x -- ~x )
    {
        fixnum-bitnot
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-bitnot
        no-method
        no-method
        no-method
    } generic ;

: shift ( x n -- x<<n )
    {
        fixnum-shift
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum-shift
        no-method
        no-method
        no-method
    } 2generic ;

: < ( x y -- ? )
    {
        fixnum<
        no-method
        no-method
        no-method
        ratio<
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum<
        float<
        no-method
        no-method
    } 2generic ;

: <= ( x y -- ? )
    {
        fixnum<=
        no-method
        no-method
        no-method
        ratio<=
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum<=
        float<=
        no-method
        no-method
    } 2generic ;

: > ( x y -- ? )
    {
        fixnum>
        no-method
        no-method
        no-method
        ratio>
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum>
        float>
        no-method
        no-method
    } 2generic ;

: >= ( x y -- ? )
    {
        fixnum>=
        no-method
        no-method
        no-method
        ratio>=
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        no-method
        bignum>=
        float>=
        no-method
        no-method
    } 2generic ;
