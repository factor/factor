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

: compile-f-test ( -- fixup )
    #! Push addr where we write the branch target address.
    POP-DS
    ! ptr to condition is now in EAX
    f address-of EAX CMP-I-[R]
    compiled-offset JE ;

: branch-target ( fixup -- )
    cell compile-aligned compiled-offset swap fixup ;

: compile-else ( fixup -- fixup )
    #! Push addr where we write the branch target address,
    #! and fixup branch target address from compile-f-test.
    #! Push f for the fixup if we're tail position.
    tail? [ RET f ] [ 0 JUMP ] ifte swap branch-target ;

: compile-end-if ( fixup -- )
    tail? [ drop RET ] [ branch-target ] ifte ;

: compile-ifte ( -- )
    pop-literal pop-literal  commit-literals
    compile-f-test >r
    ( t -- ) compile-quot
    r> compile-else >r
    ( f -- ) compile-quot
    r> compile-end-if ;

[
    [ ifte compile-ifte ]
] [
    unswons "compiling" swap set-word-property
] each
