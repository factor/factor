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

IN: stack
USE: vectors

: nop ( -- ) ;
: 2drop ( x x -- ) drop drop ; inline
: 3drop ( x x x -- ) drop drop drop ; inline
: 2dup ( x y -- x y x y ) over over ; inline
: 3dup ( x y z -- x y z x y z ) pick pick pick ; inline
: rot ( x y z -- y z x ) >r swap r> swap ; inline
: -rot ( x y z -- z x y ) swap >r swap r> ; inline
: dupd ( x y -- x x y ) >r dup r> ; inline
: swapd ( x y z -- y x z ) >r swap r> ; inline
: transp ( x y z -- z y x ) swap rot ; inline
: nip ( x y -- y ) swap drop ; inline
: tuck ( x y -- y x y ) dup >r swap r> ; inline

: clear ( -- )
    #! Clear the datastack. For interactive use only; invoking
    #! this from a word definition will clobber any values left
    #! on the data stack by the caller.
    { } set-datastack ;

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack vector-length ;
