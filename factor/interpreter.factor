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

: exception? (exception -- boolean)
    "java.lang.Throwable" is ;

: printStackTrace (exception --)
    [ ] "java.lang.Throwable" "printStackTrace" jmethod jinvoke ;

: exception. (exception --)
    ! If this is an Factor exception, just print the message, otherwise print
    ! the entire exception as a string.
    dup "factor.FactorException" is [
        [ ] "java.lang.Throwable" "getMessage" jmethod jinvoke
    ] [
        >str
    ] ifte print ;

: break (exception --)
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
    callstack$ @errorCallStack
    [
        @errorContinuation
        interpreterLoop
        ! If we end up here, the user just exited the err interpreter.
        ! If we just call returnFromError here, its like :g and this
        ! is probably not what they wanted. So we :r instead.
        :r
    ] callcc0 ;

: returnFromError (--)
    "Returning from break." print
    f @errorCallStack
    f @errorFlag
    f @error ;

: :g (--)
    ! Continues execution from the point of the error. Can be dangerous.
    returnFromError
    $errorContinuation call ;

: :r (--)
    ! Returns to the top level.
    returnFromError
    !XXX
    $initialInterpreterContinuation dup [
        call
    ] [
        suspend
    ] ifte ;

: :s (--)
    ! Returns to the top level, retaining the stack.
    returnFromError
    $initialInterpreterCallStack callstack@ ;

: :j (--)
    ! Print the stack trace from the exception that caused the last break.
    $error dup exception? [
        printStackTrace
    ] [
        "Not an exception: " write .
    ] ifte ;

: :w (--)
    ! Print the current callstack, or the callstack of the last error inside an
    ! error context.
    $errorCallStack dup [
        drop callstack$
    ] unless . ;

: printPrompt (--)
    $errorFlag "  err> " "  ok> " ? write ;

: interpreterLoop (--)
    printPrompt read [
        eval
        $quitFlag [ interpreterLoop ] unless
    ] when* ;

: initialInterpreterLoop (--)
    ! Run the stand-alone interpreter
    "Factor " $version cat2 print
    "Copyright (C) 2003, 2004 Slava Pestov" print
    "Enter ``help'' for help." print
    "Enter ``exit'' to exit." print
    ! Used by :r
    [ @initialInterpreterContinuation ] callcc0
    ! Used by :s
    ! We use the slightly redundant 'call' to push the current callframe.
    [ callstack$ @initialInterpreterCallStack ] call
    interpreterLoop ;

: words. (--)
    ! Print all defined words.
    words [ . ] each ;

: see (word --)
    dup worddef [
        (word -- worddef word)
        dup [ worddef dup shuffle? "~<< " ": " ? write ] dip

        (worddef word -- worddef)
        write "\n    " write

        dup >str write

        shuffle? " >>~\n" " ;\n" ? write
    ] [
        "Not defined: " write print
    ] ifte ;

: vars. (--)
    ! Print a list of defined variables.
    vars [ . ] each ;

: .s (--)
    ! Prints the contents of the data stack
    datastack$ . ;

: help
    "" print
    "= Dynamic, interpreted, stack-based scripting language" print
    "= Arbitrary precision math, ratio math" print
    "= First-class, higher-order, and anonymous functions" print
    "= Prototype-based object system" print
    "= Continuations" print
    "= Tail call optimization" print
    "= Rich set of primitives based on recursion" print
    "" print
    "Some basic commands:" print
    "clear       -- clear stack." print
    ".s          -- print stack." print
    ".           -- print top of stack." print
    "vars.       -- list all variables." print
    "$variable . -- show value of variable." print
    "words.      -- list all words." print
    "\"word\" see  -- show definition of word." print
    "exit        -- exit the interpreter." print
    "" print ;
