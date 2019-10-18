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
USE: combinators
USE: words
USE: stack
USE: kernel
USE: math
USE: lists

: compile-test ( -- )
    POP-DS
    ! condition is now in EAX
    f address EAX CMP-I-R ;

: compile-f-test ( -- fixup )
    #! Push addr where we write the branch target address.
    compile-test
    ! jump w/ address added later
    JE ;

: compile-t-test ( -- fixup )
    #! Push addr where we write the branch target address.
    compile-test
    ! jump w/ address added later
    JNE ;

: branch-target ( fixup -- )
    compiled-offset swap JUMP-FIXUP ;

: compile-else ( fixup -- fixup )
    #! Push addr where we write the branch target address,
    #! and fixup branch target address from compile-f-test.
    #! Push f for the fixup if we're tail position.
    tail? [ RET f ] [ JUMP ] ifte swap branch-target ;

: end-if ( fixup -- )
    tail? [ RET ] when [ branch-target ] when* ;

: compile-ifte ( compile-time: true false -- )
    pop-literal pop-literal  commit-literals
    compile-f-test >r
    ( t -- ) compile-quot
    r> compile-else >r
    ( f -- ) compile-quot
    r> end-if ;

: compile-when ( compile-time: true -- )
    pop-literal  commit-literals
    compile-f-test >r
    ( t -- ) compile-quot
    r> end-if ;

: compile-unless ( compile-time: false -- )
    pop-literal  commit-literals
    compile-t-test >r
    ( f -- ) compile-quot
    r> end-if ;

\ ifte [ compile-ifte ] "compiling" set-word-property
\ when [ compile-when ] "compiling" set-word-property
\ unless [ compile-unless ] "compiling" set-word-property
