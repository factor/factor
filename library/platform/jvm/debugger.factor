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

IN: debugger
USE: combinators
USE: continuations
USE: inspector
USE: interpreter
USE: kernel
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: unparser

: :g ( -- )
    #! Continues execution from the point of the error. Can be
    #! dangerous.
    "error-continuation" get call ;

: :x ( -- )
    #! Returns to the top level.
    !XXX
    "initial-interpreter-continuation" get dup [
        call
    ] [
        suspend
    ] ifte ;

: :s ( -- )
    #! Returns to the top level, retaining the stack.
    "initial-interpreter-callstack" get
    set-callstack ;

: exception? ( exception -- boolean )
    "java.lang.Throwable" is ;

: print-stack-trace ( exception -- )
    [ ] "java.lang.Throwable" "printStackTrace" jinvoke ;

: :j ( -- )
    ! Print the stack trace from the exception that caused the
    ! last break.
    "error" get dup exception? [
        print-stack-trace
    ] [
        "Not an exception: " write .
    ] ifte ;

: :r ( -- )
    #! Print the callstack of the last error.
    "error-callstack" get describe-stack ;

: exception. ( exception -- )
    #! If this is an Factor exception, just print the message,
    #! otherwise print the entire exception as a string.
    dup "factor.FactorException" is [
        [ ] "java.lang.Throwable" "getMessage" jinvoke
    ] [
        >str
    ] ifte print ;

: debugger-help ( -- )
    "break called." print
    "" print
    ":r prints the callstack." print
    ":j prints the Java stack." print
    ":x returns to top level." print
    ":s returns to top level, retaining the data stack." print
    ":g continues execution (but expect another error)." print
    "" print ;

: clear-error-flag ( -- )
    global [ f "error-flag" set ] bind ;

! So that Java code can call it
IN: kernel

: break ( exception -- )
    #! Called when the interpreter catches an exception.
    callstack
    <namespace> [
        "error-callstack" set
        dup "error" set
        "error-stdio" get "stdio" set

        debugger-help
        "ERROR: " write exception.

        ! XXX: move this to the game core!
        "console" get [
            [ t "expanded" set ] bind
        ] when*

        [
            "error-continuation" set
            clear-error-flag
            "    DEBUG. " interpreter-loop
            ! If we end up here, the user just exited the err
            ! interpreter. If we just call return-from-error
            ! here, its like :g and this is probably not what
            ! they wanted. So we :x instead.
            :x
        ] callcc0
    ] bind ;
