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

IN: math         : fixnum?  ( obj -- ? ) type-of 0  eq? ;
IN: words        : word?    ( obj -- ? ) type-of 1  eq? ;
IN: lists        : cons?    ( obj -- ? ) type-of 2  eq? ;
IN: math         : ratio?   ( obj -- ? ) type-of 4  eq? ;
IN: math         : complex? ( obj -- ? ) type-of 5  eq? ;
IN: vectors      : vector?  ( obj -- ? ) type-of 9  eq? ;
IN: strings      : string?  ( obj -- ? ) type-of 10 eq? ;
IN: strings      : sbuf?    ( obj -- ? ) type-of 11 eq? ;
IN: io-internals : port?    ( obj -- ? ) type-of 12 eq? ;
IN: math         : bignum?  ( obj -- ? ) type-of 13 eq? ;
IN: math         : float?   ( obj -- ? ) type-of 14 eq? ;
IN: alien        : dll?     ( obj -- ? ) type-of 15 eq? ;
