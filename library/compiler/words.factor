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

: F-TEST ( -- fixup )
    #! Push addr where we write the branch target address.
    POP-DS
    ! ptr to condition is now in EAX
    f address EAX CMP-I-[R]
    ! jump w/ address added later
    JE ;

: branch-target ( fixup -- )
    compiled-offset swap JUMP-FIXUP ;

: ELSE ( fixup -- fixup )
    #! Push addr where we write the branch target address,
    #! and fixup branch target address from compile-f-test.
    #! Push f for the fixup if we're tail position.
    tail? [ RET f ] [ JUMP ] ifte swap branch-target ;

: END-IF ( fixup -- )
    tail? [ drop RET ] [ branch-target ] ifte ;

: compile-ifte ( compile-time: true false -- )
    pop-literal pop-literal  commit-literals
    F-TEST >r
    ( t -- ) compile-quot
    r> ELSE >r
    ( f -- ) compile-quot
    r> END-IF ;

: TABLE-JUMP ( start-fixup -- end-fixup )
    #! The 32-bit address of the code after the jump table
    #! should be written to end-fixup.
    #! The jump table must immediately follow this macro.
    tail? [ 0 ] [ 0 PUSH-I compiled-offset 4 - ] ifte >r
    ( start-fixup r:end-fixup )
    EAX JUMP-[R]
    compiled-offset swap set-compiled-cell ( update the ADD )
    r> ;

: BEGIN-JUMP-TABLE ( -- end-fixup )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the type of the Factor object in
    #! EAX.
    TYPE-OF
    2 EAX R<<I
    EAX+/PARTIAL
    TABLE-JUMP ;

: END-JUMP-TABLE ( end-fixup -- )
    compiled-offset dup 0 = [
        2drop
    ] [
        set-compiled-cell ( update the PUSH )
    ] ifte ;

: compile-generic ( compile-time: vtable -- )
    #! Compile a faster alternative to
    #! : generic ( obj vtable -- )
    #!     >r dup type r> vector-nth execute ;
    BEGIN-JUMP-TABLE
    ! write table now
    END-JUMP-TABLE ;

[
    [ ifte compile-ifte ]
    [ generic compile-generic ]
] [
    unswons "compiling" set-word-property
] each
