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

IN: logic USE: kernel USE: stack

: ? ( cond t f -- t/f )
    #! Push t if cond is true, otherwise push f.
    rot [ drop ] [ nip ] ifte ; inline

: and ( a b -- a&b )
    #! Logical and.
    f ? ; inline

: not ( a -- a )
    #! Pushes f is the object is not f, t if the object is f.
    f t ? ; inline

: or ( a b -- a|b) 
    #! Logical or.
    t swap ? ; inline

: xor ( a b -- a^b )
    #! Logical exclusive or.
    dup not swap ? ; inline

: >boolean t f ? ; inline

: replace ( obj old new -- obj/new )
    #! If obj is equal to old, drop it and push new.
    >r dupd = [ drop r> ] [ r> drop ] ifte ;
