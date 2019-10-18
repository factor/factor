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

: continue (datastack callstack push --)
    ! Do not call this directly. Used by callcc.
    ! Use a trick to carry the push parameter onto the new data stack.
    2dip
    callstack@ (push` datastack)
    swap (datastack push`)
    >r (datastack)
    datastack@ (... [ code ])
    drop (...)
    r> (... push`)
    call ;

: callcc ([ code ] --)
    ! Calls the code with a special object on the top of the stack. This object,
    ! when called, restores execution state to just after the callcc call that
    ! generated this object, and pushes each element of the list at the top of
    ! the caller's data stack onto the original data stack.

    ! We do a cdr since we don't want the [ code ] to be at the top of the
    ! stack when execution is restored. Also note that $callstack's car is the
    ! parent callframe, not the current callframe -- the current callframe is in
    ! $callframe.
    datastack$ callstack$ [ [ ] continue ] cons cons
    swap call ;

: callcc0 ([ code ] --)
    ! Like callcc except no data is pushed onto the original datastack.
    datastack$ callstack$ [ [ f ] continue ] cons cons
    swap call ;

: callcc1 ([ code ] --)
    ! Like callcc except the continuation that is pushed onto the stack before
    ! executing the given code takes the top of the caller's data stack and
    ! pushes it onto the original datastack, instead of prepending it to the
    ! original datastack as a list.
    datastack$ callstack$ [ [ unit ] continue ] cons cons
    swap call ;

: suspend (--)
    ! Suspend the current fiber.
    ! Not really implemented yet.
    $top-level-continuation dup [
        call
    ] [
        clear unwind
    ] ifte ;
