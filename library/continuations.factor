!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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

IN: continuations
USE: combinators
USE: kernel
USE: lists
USE: namespaces
USE: stack

: continue ( datastack callstack namestack push -- )
    #! Do not call this directly. Used by callcc.
    ! Use a trick to carry the push parameter onto the new data stack.
    3dip
    set-namestack
    >r
    swap
    >r
    set-datastack drop
    r>
    call
    r>
    set-callstack ;

: callcc ( [ code ] -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( list -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc call, and pushes each element
    #! of the list onto the original data stack.

    ! Slightly outdated implementation note:

    ! We do a cdr since we don't want the [ code ] to be at the
    ! top of the stack when execution is restored. Also note
    ! that callstack's top is the parent callframe, not the
    ! current callframe
    datastack callstack namestack
    [ [ ] continue ] cons cons cons
    swap call ;

: callcc0 ( [ code ] -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc0 call.
    ! Like callcc except no data is pushed onto the original datastack.
    datastack callstack namestack
    [ [ f ] continue ] cons cons cons
    swap call ;

: callcc1 ( [ code ] -- )
    #! Calls the code with a special quotation at the top of the
    #! stack. The quotation has stack effect:
    #!
    #! ( X -- ... )
    #!
    #! When called, the quotation restores execution state to
    #! the point after the callcc1 call, and places X at the top
    #! of the original datastack.
    datastack callstack namestack
    [ [ unit ] continue ] cons cons cons
    swap call ;

: suspend ( -- )
    ! Suspend the current fiber.
    ! Not really implemented yet.
    "top-level-continuation" get dup [
        call
    ] [
        toplevel
    ] ifte ;
