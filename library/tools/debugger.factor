! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or wxithout
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

IN: errors
USE: kernel
USE: kernel-internals
USE: lists
USE: namespaces
USE: prettyprint
USE: stdio
USE: strings
USE: unparser
USE: vectors
USE: words
USE: math
USE: generic

: expired-error ( obj -- )
    "Object did not survive image save/load: " write . ;

: io-task-twice-error ( obj -- )
    "Attempting to perform two simultaneous I/O operations on "
    write . ;

: no-io-tasks-error ( obj -- )
    "No I/O tasks" print ;

: undefined-word-error ( obj -- )
    "Undefined word: " write . ;

: incompatible-port-error ( obj -- )
    "Unsuitable port for operation: " write . ;

: io-error ( list -- )
    "I/O error in kernel function " write
    unswons write ": " write car print ;

: type-check-error ( list -- )
    "Type check error" print
    uncons car dup "Object: " write .
    "Object type: " write class .
    "Expected type: " write builtin-type . ;

: range-error ( list -- )
    "Range check error" print
    unswons [ "Object: " write . ] when*
    unswons "Minimum index: " write .
    unswons "Requested index: " write .
    car "Maximum index: " write . ;

: float-format-error ( list -- )
    "Invalid floating point literal format: " write . ;

: signal-error ( obj -- )
    "Operating system signal " write . ;

: negative-array-size-error ( obj -- )
    "Cannot allocate array with negative size " write . ;

: c-string-error ( obj -- )
    "Cannot convert to C string: " write . ;

: ffi-disabled-error ( obj -- )
    drop "Recompile Factor with #define FFI." print ;

: ffi-error ( obj -- )
    "FFI: " write print ;

: port-closed-error ( obj -- )
    "Port closed: " write . ;

GENERIC: error. ( error -- )

PREDICATE: cons kernel-error ( obj -- ? )
    car kernel-error = ;

M: kernel-error error. ( error -- )
    cdr uncons car swap {
        expired-error
        io-task-twice-error
        no-io-tasks-error
        incompatible-port-error
        io-error
        undefined-word-error
        type-check-error
        range-error
        float-format-error
        signal-error
        negative-array-size-error
        c-string-error
        ffi-disabled-error
        ffi-error
        port-closed-error
    } vector-nth execute ;

M: string error. ( error -- )
    print ;

M: object error. ( error -- )
    . ;

: in-parser? ( -- ? )
    "error-line" get "error-col" get and ;

: parse-dump ( -- )
    [
        "Parsing " ,
        "error-file" get [ "<interactive>" ] unless* , ":" ,
        "error-line-number" get [ 1 ] unless* unparse ,
    ] make-string print
    
    "error-line" get print
    
    [ "error-col" get " " fill , "^" , ] make-string print ;

: :s ( -- ) "error-datastack"  get {.} ;
: :r ( -- ) "error-callstack"  get {.} ;
: :n ( -- ) "error-namestack"  get [.] ;
: :c ( -- ) "error-catchstack" get [.] ;

: :get ( var -- value ) "error-namestack" get (get) ;

: debug-help ( -- )
    [ :s :r :n :c ] [ prettyprint-1 " " write ] each
    "show stacks at time of error." print
    \ :get prettyprint-1
    " ( var -- value ) inspects the error namestack." print ;

: flush-error-handler ( error -- )
    #! Last resort.
    [ "Error in default error handler!" print drop ] when ;

: print-error ( error -- )
    #! Print the error.
    [
        in-parser? [ parse-dump ] when error.
    ] [
        flush-error-handler
    ] catch ;

: try ( quot -- )
    #! Execute a quotation, and if it throws an error, print it
    #! and return to the caller.
    [ [ print-error debug-help ] when* ] catch ;

: init-error-handler ( -- )
    [ 1 exit* ] >c ( last resort )
    [ print-error 1 exit* ] >c
    [ dup save-error rethrow ] 5 setenv ( kernel calls on error )
    kernel-error 12 setenv ;

: undefined-method ( object generic -- )
    #! We 2dup here to leave both values on the stack, for
    #! post-mortem inspection.
    2dup [
        "The generic word " ,
        unparse ,
        " does not have a suitable method for " ,
        unparse ,
    ] make-string throw ;

! So that stage 2 boot gives a useful error message if something
! fails after this file is loaded.
init-error-handler
