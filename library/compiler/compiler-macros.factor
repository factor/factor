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

IN: compiler

: LITERAL ( cell -- )
    #! Push literal on data stack.
    #! Assume that it is ok to clobber EAX without saving.
    DATASTACK EAX [I]>R
    EAX I>[R]
    4 DATASTACK I+[I] ;

: [LITERAL] ( cell -- )
    #! Push complex literal on data stack by following an
    #! indirect pointer.
    ECX PUSH-R
    ( cell -- ) ECX [I]>R
    DATASTACK EAX [I]>R
    ECX EAX R>[R]
    4 DATASTACK I+[I]
    ECX POP-R ;

: PUSH-DS ( -- )
    #! Push contents of EAX onto datastack.
    ECX PUSH-R
    DATASTACK ECX [I]>R
    EAX ECX R>[R]
    4 DATASTACK I+[I]
    ECX POP-R ;

: POP-DS ( -- )
    #! Pop datastack, store pointer to datastack top in EAX.
    DATASTACK EAX [I]>R
    4 EAX R-I
    EAX DATASTACK R>[I] ;
