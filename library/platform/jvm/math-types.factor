! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

IN: arithmetic
USE: combinators
USE: kernel
USE: logic
USE: stack

: number? "java.lang.Number" is ; inline
: >number "java.lang.Number" coerce ; inline

: fixnum? "java.lang.Integer" is ; inline
: >fixnum "int" coerce ; inline

: bignum? "java.math.BigInteger" is ; inline
: >bignum "java.math.BigInteger" coerce ; inline

: integer? dup fixnum? swap bignum? or ;

: ratio? "factor.math.Ratio" is ; inline

: numerator ( x/y -- x )
    dup ratio? [
        "factor.math.Ratio" "numerator" jvar-get
    ] [
        >number
    ] ifte ;

: denominator ( x/y -- y )
    dup ratio? [
        "factor.math.Ratio" "denominator" jvar-get
    ] [
        >number drop 1
    ] ifte ;

: rational? dup integer? swap ratio? or ;

: float? ( obj -- boolean )
    dup  "java.lang.Float"  is
    swap "java.lang.Double" is or ; inline
: >float "double" coerce ; inline

: complex? "factor.math.Complex" is ; inline

: real ( complex -- real )
    dup complex? [
        "factor.math.Complex" "real" jvar-get
    ] [
        >number
    ] ifte ;

: imaginary ( complex -- imaginary )
    dup complex? [
        "factor.math.Complex" "imaginary" jvar-get
    ] [
        >number drop 0
    ] ifte ;

: rect> ( real imaginary -- complex )
    [ "java.lang.Number" "java.lang.Number" ]
    "factor.math.Complex" "valueOf" jinvoke-static ;

: >rect ( complex -- real imaginary )
    dup complex? [
        dup
        "factor.math.Complex" "real" jvar-get
        swap
        "factor.math.Complex" "imaginary" jvar-get
    ] [
        >number 0
    ] ifte ;

: real? dup number? swap complex? not and ;
