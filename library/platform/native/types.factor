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

IN: math         : fixnum?  ( obj -- ? ) type 0  eq? ;
IN: words        : word?    ( obj -- ? ) type 1  eq? ;
IN: lists        : cons?    ( obj -- ? ) type 2  eq? ;
IN: math         : ratio?   ( obj -- ? ) type 4  eq? ;
IN: math         : complex? ( obj -- ? ) type 5  eq? ;
IN: vectors      : vector?  ( obj -- ? ) type 9  eq? ;
IN: strings      : string?  ( obj -- ? ) type 10 eq? ;
IN: strings      : sbuf?    ( obj -- ? ) type 11 eq? ;
IN: io-internals : port?    ( obj -- ? ) type 12 eq? ;
IN: math         : bignum?  ( obj -- ? ) type 13 eq? ;
IN: math         : float?   ( obj -- ? ) type 14 eq? ;
IN: alien        : dll?     ( obj -- ? ) type 15 eq? ;
IN: alien        : alien?   ( obj -- ? ) type 16 eq? ;

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
        [ 9 | "vector" ]
        [ 10 | "string" ]
        [ 11 | "sbuf" ]
        [ 12 | "port" ]
        [ 13 | "bignum" ]
        [ 14 | "float" ]
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
