! :folding=none:collapseFolds=1:

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

IN: threads
USE: combinators
USE: continuations
USE: io-internals
USE: kernel
USE: lists
USE: stack

! Core of the multitasker. Used by io-internals.factor and
! in-thread.factor.

: run-queue ( -- queue )
    9 getenv ;

: set-run-queue ( queue -- )
    9 setenv ;

: init-threads ( -- )
    f set-run-queue ;

: next-thread ( -- quot )
    #! Get and remove the next quotation from the run queue.
    run-queue dup [ uncons set-run-queue ] when ;

: schedule-thread ( quot -- )
    #! Add a quotation to the run queue.
    run-queue cons set-run-queue ;

: (yield) ( -- )
    #! If there is a quotation in the run queue, call it,
    #! otherwise wait for I/O. The currently executing
    #! continuation is suspended. Use yield instead.
    next-thread dup [
        call
    ] [
        drop next-io-task dup [
            call
        ] [
            drop (yield)
        ] ifte
    ] ifte ;

: yield ( -- )
    #! Add the current continuation to the run queue, and yield
    #! to the next quotation. The current continuation will
    #! eventually be restored by a future call to (yield) or
    #! yield.
    [ schedule-thread (yield) ] callcc0 ;
