! :folding=indent:collapseFolds=1:

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

IN: kernel-internals
USE: generic
USE: kernel
USE: vectors

: dispatch ( n vtable -- )
    #! This word is unsafe in compiled code since n is not
    #! bounds-checked. Do not call it directly.
    vector-nth call ;

IN: kernel

GENERIC: hashcode ( obj -- n )
M: object hashcode drop 0 ;

GENERIC: = ( obj obj -- ? )
M: object = eq? ;

: cpu ( -- arch )
    #! Returns one of "x86" or "unknown".
    7 getenv ;

: os ( -- arch )
    #! Returns one of "unix" or "win32".
    11 getenv ;

: set-boot ( quot -- )
    #! Set the boot quotation.
    8 setenv ;

: num-types ( -- n )
    #! One more than the maximum value from type primitive.
    18 ;

: ? ( cond t f -- t/f )
    #! Push t if cond is true, otherwise push f.
    rot [ drop ] [ nip ] ifte ; inline

: >boolean t f ? ; inline

: and ( a b -- a&b ) f ? ; inline
: not ( a -- ~a ) f t ? ; inline
: or ( a b -- a|b ) t swap ? ; inline
: xor ( a b -- a^b ) dup not swap ? ; inline

IN: syntax

! The canonical t is a heap-allocated dummy object. It is always
! the first in the image.
BUILTIN: t 7

! In the runtime, the canonical f is represented as a null
! pointer with tag 3. So
! f address . ==> 3
BUILTIN: f 9

IN: kernel
UNION: boolean f t ;
COMPLEMENT: general-t f
