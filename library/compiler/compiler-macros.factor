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
USE: alien

: LITERAL ( cell -- )
    #! Push literal on data stack.
    ESI I>[R]
    4 ESI R+I ;

: [LITERAL] ( cell -- )
    #! Push complex literal on data stack by following an
    #! indirect pointer.
    EAX [I]>R
    EAX ESI R>[R]
    4 ESI R+I ;

: PUSH-DS ( -- )
    #! Push contents of EAX onto datastack.
    EAX ESI R>[R]
    4 ESI R+I ;

: PEEK-DS ( -- )
    #! Peek datastack, store pointer to datastack top in EAX.
    ESI EAX R>R
    4 EAX R-I ;

: POP-DS ( -- )
    #! Pop datastack, store pointer to datastack top in EAX.
    PEEK-DS
    EAX ESI R>R ;

: SELF-CALL ( name -- )
    #! Call named C function in Factor interpreter executable.
    dlsym-self CALL JUMP-FIXUP ;

: TYPE ( -- )
    #! Peek datastack, store type # in EAX.
    PEEK-DS
    EAX PUSH-[R]
    "type_of" SELF-CALL
    4 ESP R+I ;

: ARITHMETIC-TYPE ( -- )
    #! Peek top two on datastack, store arithmetic type # in EAX.
    PEEK-DS
    EAX PUSH-[R]
    4 EAX R-I
    EAX PUSH-[R]
    "arithmetic_type" SELF-CALL
    8 ESP R+I ;
