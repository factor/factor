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
USE: math
USE: real-math
USE: kernel
USE: stack

! Power-related functions:
!     exp log sqrt pow
USE: logic

: exp >rect swap fexp swap polar> ;
: log >polar swap flog swap rect> ;

: sqrt ( z -- sqrt )
    >polar dup pi = [
        drop fsqrt 0 swap rect>
    ] [
        swap fsqrt swap 2 / polar>
    ] ifte ;

: ^mag ( w abs arg -- magnitude )
    [ [ >rect swap ] dip swap fpow ] dip rot * fexp / ;

: ^theta ( w abs arg -- theta )
    [ [ >rect ] dip flog * swap ] dip * + ;

: ^ ( z w -- z^w )
    over real? over integer? and [
        fpow
    ] [
        swap >polar 3dup ^theta >r ^mag r> polar>
    ] ifte ;
