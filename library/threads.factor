! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: threads
USING: io-internals kernel kernel-internals lists namespaces ;

! Core of the multitasker. Used by io-internals.factor and
! in-thread.factor.

: run-queue ( -- queue ) 9 getenv ;
: set-run-queue ( queue -- ) 9 setenv ;

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
    next-thread [
        call
    ] [
        next-io-task [
            call
        ] [
            (yield)
        ] ifte*
    ] ifte* ;

: yield ( -- )
    #! Add the current continuation to the run queue, and yield
    #! to the next quotation. The current continuation will
    #! eventually be restored by a future call to (yield) or
    #! yield.
    [ schedule-thread (yield) ] callcc0 ;
