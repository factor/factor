!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

: exception? ( exception -- boolean )
    "java.lang.Throwable" is ;

: print-stack-trace ( exception -- )
    [ ] "java.lang.Throwable" "printStackTrace" jinvoke ;

: exception. ( exception -- )
    ! If this is an Factor exception, just print the message, otherwise print
    ! the entire exception as a string.
    dup "factor.FactorException" is [
        [ ] "java.lang.Throwable" "getMessage" jinvoke
    ] [
        >str
    ] ifte print ;

: break ( exception -- )
    global [
        dup @error

        ! Called when the interpreter catches an exception.
        "break called." print
        "" print
        ":w prints the callstack." print
        ":j prints the Java stack." print
        ":r returns to top level." print
        ":s returns to top level, retaining the data stack." print
        ":g continues execution (but expect another error)." print
        "" print
        "ERROR: " write exception.

        ! XXX: move this to the game core!
        $console [
            [ t @expanded ] bind
        ] when*

        callstack$ @error-callstack
        [
            @error-continuation
            "    DEBUG. " interpreter-loop
            ! If we end up here, the user just exited the err
            ! interpreter. If we just call return-from-error
            ! here, its like :g and this is probably not what
            ! they wanted. So we :r instead.
            :r
        ] callcc0
    ] bind ;

: return-from-error ( -- )
    "Returning from break." print
    f @error-callstack
    f @error-flag
    f @error ;

: :g ( -- )
    ! Continues execution from the point of the error. Can be dangerous.
    return-from-error
    $error-continuation call ;

: :r ( -- )
    ! Returns to the top level.
    return-from-error
    !XXX
    $initial-interpreter-continuation dup [
        call
    ] [
        suspend
    ] ifte ;

: .s ( -- )
    ! Prints the contents of the data stack
    datastack$ describe ;

: :s ( -- )
    ! Returns to the top level, retaining the stack.
    return-from-error
    $initial-interpreter-callstack
    callstack@ ;

: :j ( -- )
    ! Print the stack trace from the exception that caused the
    ! last break.
    $error dup exception? [
        print-stack-trace
    ] [
        "Not an exception: " write .
    ] ifte ;

: :w ( -- )
    ! Print the current callstack, or the callstack of the last
    ! error inside an error context.
    $error-callstack [ callstack$ ] unless* describe ;
