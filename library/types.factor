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

USE: kernel
USE: math

IN: kernel-internals

: fixnum-tag  BIN: 000 ; inline
: word-tag    BIN: 001 ; inline
: cons-tag    BIN: 010 ; inline
: object-tag  BIN: 011 ; inline
: ratio-tag   BIN: 100 ; inline
: complex-tag BIN: 101 ; inline
: header-tag  BIN: 110 ; inline

: f-type      6  ; inline
: t-type      7  ; inline
: array-type  8  ; inline
: bignum-type 9  ; inline
: float-type  10 ; inline
: vector-type 11 ; inline
: string-type 12 ; inline
: sbuf-type   13 ; inline
: port-type   14 ; inline
: dll-type    15 ; inline
: alien-type  16 ; inline

IN: math         : fixnum?  ( obj -- ? ) type fixnum-tag  eq? ;
IN: words        : word?    ( obj -- ? ) type word-tag    eq? ;
IN: lists        : cons?    ( obj -- ? ) type cons-tag    eq? ;
IN: math         : ratio?   ( obj -- ? ) type ratio-tag   eq? ;
IN: math         : complex? ( obj -- ? ) type complex-tag eq? ;
IN: math         : bignum?  ( obj -- ? ) type bignum-type eq? ;
IN: math         : float?   ( obj -- ? ) type float-type  eq? ;
IN: vectors      : vector?  ( obj -- ? ) type vector-type eq? ;
IN: strings      : string?  ( obj -- ? ) type string-type eq? ;
IN: strings      : sbuf?    ( obj -- ? ) type sbuf-type   eq? ;
IN: io-internals : port?    ( obj -- ? ) type port-type   eq? ;
IN: alien        : dll?     ( obj -- ? ) type dll-type    eq? ;
IN: alien        : alien?   ( obj -- ? ) type alien-type  eq? ;

IN: kernel

: type-name ( n -- str )
    [
        [ 0 | "fixnum" ]
        [ 1 | "word" ]
        [ 2 | "cons" ]
        [ 3 | "object" ]
        [ 4 | "ratio" ]
        [ 5 | "complex" ]
        [ 6 | "f" ]
        [ 7 | "t" ]
        [ 8 | "array" ]
        [ 9 | "bignum" ]
        [ 10 | "float" ]
        [ 11 | "vector" ]
        [ 12 | "string" ]
        [ 13 | "sbuf" ]
        [ 14 | "port" ]
        [ 15 | "dll" ]
        [ 16 | "alien" ]
        ! These values are only used by the kernel for error
        ! reporting.
        [ 100 | "fixnum/bignum" ]
        [ 101 | "fixnum/bignum/ratio" ]
        [ 102 | "fixnum/bignum/ratio/float" ]
        [ 103 | "fixnum/bignum/ratio/float/complex" ]
        [ 104 | "fixnum/string" ]
    ] assoc ;

: num-types ( -- n )
    #! One more than the maximum value from type primitive.
    17 ;
