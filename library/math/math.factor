! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2003, 2005 Slava Pestov.
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
USE: generic
USE: kernel
USE: math-internals

! Math operations
2GENERIC: number= ( x y -- ? )
M: object number= 2drop f ;

2GENERIC: <  ( x y -- ? )
2GENERIC: <= ( x y -- ? )
2GENERIC: >  ( x y -- ? )
2GENERIC: >= ( x y -- ? )

2GENERIC: +   ( x y -- x+y )
2GENERIC: -   ( x y -- x-y )
2GENERIC: *   ( x y -- x*y )
2GENERIC: /   ( x y -- x/y )
2GENERIC: /i  ( x y -- x/y )
2GENERIC: /f  ( x y -- x/y )
2GENERIC: mod ( x y -- x%y )

2GENERIC: /mod ( x y -- x/y x%y )

2GENERIC: bitand ( x y -- z )
2GENERIC: bitor  ( x y -- z )
2GENERIC: bitxor ( x y -- z )
2GENERIC: shift  ( x n -- y )

GENERIC: bitnot ( n -- n )

! Math types
BUILTIN: fixnum 0
BUILTIN: bignum 1
UNION: integer fixnum bignum ;

BUILTIN: ratio 4
UNION: rational integer ratio ;

BUILTIN: float 5
UNION: real rational float ;

BUILTIN: complex 6
UNION: number real complex ;

M: real hashcode ( n -- n ) >fixnum ;

M: number = ( n n -- ? ) number= ;

: max ( x y -- z )
    2dup > [ drop ] [ nip ] ifte ;

: min ( x y -- z )
    2dup < [ drop ] [ nip ] ifte ;

: between? ( x min max -- ? )
    #! Push if min <= x <= max. Handles case where min > max
    #! by swapping them.
    2dup > [ swap ] when  >r dupd max r> min = ;

: sq dup * ; inline

: neg 0 swap - ; inline
: recip 1 swap / ; inline

: rem ( x y -- x%y )
    #! Like modulus, but always gives a positive result.
    [ mod ] keep  over 0 < [ + ] [ drop ] ifte ; inline

: sgn ( n -- -1/0/1 )
    #! Push the sign of a real number.
    dup 0 = [ drop 0 ] [ 1 < -1 1 ? ] ifte ;

: mag2 ( x y -- mag )
    #! Returns the magnitude of the vector (x,y).
    swap sq swap sq + fsqrt ;

GENERIC: abs ( z -- |z| )
M: real abs dup 0 < [ neg ] when ;

: (gcd) ( x y -- z )
    dup 0 number= [ drop ] [ tuck mod (gcd) ] ifte ;

: gcd ( x y -- z )
    #! Greatest common divisor.
    abs swap abs 2dup < [ swap ] when (gcd) ;

: align ( offset width -- offset )
    2dup mod dup 0 number= [ 2drop ] [ - + ] ifte ;
