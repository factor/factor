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
USE: vectors

: compile-table-jump ( start-fixup -- end-fixup )
    #! The 32-bit address of the code after the jump table
    #! should be written to end-fixup.
    #! The jump table must immediately follow this macro.
    tail? [ 0 ] [ 0 PUSH-I compiled-offset 4 - ] ifte >r
    ( start-fixup r:end-fixup )
    EAX JUMP-[R]
    cell compile-aligned
    compiled-offset swap set-compiled-cell ( update the ADD )
    r> ;

: begin-jump-table ( -- end-fixup )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the type of the Factor object in
    #! EAX.
    TYPE-OF
    2 EAX R<<I
    EAX+/PARTIAL
    compile-table-jump ;

: jump-table-entry ( word -- )
    #! Jump table entries are absolute addresses.
    dup postpone-word
    compiled-offset 0 compile-cell 0 fixup-deferred-xt ;

: compile-jump-table ( vtable -- )
    #! Compile a table of words as a word-array of XTs.
    num-types [
        over ?vector-nth jump-table-entry
    ] times* drop ;

: end-jump-table ( end-fixup -- )
    #! update the PUSH.
    dup 0 = [
        drop
    ] [
        compiled-offset swap set-compiled-cell
    ] ifte ;

: compile-generic ( compile-time: vtable -- )
    #! Compile a faster alternative to
    #! : generic ( obj vtable -- )
    #!     >r dup type r> vector-nth execute ;
    begin-jump-table
    pop-literal compile-jump-table
    end-jump-table ;

[ compile-generic ] \ generic "compiling" set-word-property
