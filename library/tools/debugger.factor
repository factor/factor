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
USE: lists
USE: namespaces
USE: prettyprint
USE: stdio
USE: strings
USE: unparser
USE: vectors
USE: words
USE: math

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
    "Object type: " write type type-name print
    "Expected type: " write type-name print ;

: array-range-error ( list -- )
    "Array range check error" print
    unswons "Object: " write .
    uncons car "Maximum index: " write .
    "Requested index: " write . ;

: float-format-error ( list -- )
    "Invalid floating point literal format: " write . ;

: signal-error ( obj -- )
    "Operating system signal " write . ;

: negative-array-size-error ( obj -- )
    "Cannot allocate array with negative size " write . ;

: bad-primitive-error ( obj -- )
    "Bad primitive number: " write . ;

: c-string-error ( obj -- )
    "Cannot convert to C string: " write . ;

: ffi-disabled-error ( obj -- )
    drop "Recompile Factor with #define FFI." print ;

: ffi-error ( obj -- )
    "FFI: " write print ;

: port-closed-error ( obj -- )
    "Port closed: " write . ;

: kernel-error. ( obj n -- str )
    {
        expired-error
        io-task-twice-error
        no-io-tasks-error
        incompatible-port-error
        io-error
        undefined-word-error
        type-check-error
        array-range-error
        float-format-error
        signal-error
        negative-array-size-error
        bad-primitive-error
        c-string-error
        ffi-disabled-error
        ffi-error
        port-closed-error
    } vector-nth execute ;

: kernel-error? ( obj -- ? )
    dup cons? [ uncons cons? swap fixnum? and ] [ drop f ] ifte ;

: error. ( error -- str )
    dup kernel-error? [
        uncons car swap kernel-error.
    ] [
        dup string? [ print ] [ . ] ifte
    ] ifte ;

: standard-dump ( error -- )
    "ERROR: " write error. ;

: parse-dump ( error -- )
    [
        "error-file" get [ "<interactive>" ] unless* , ":" ,
        "error-line-number" get [ 1 ] unless* unparse , ": " ,
    ] make-string write
    error.
    
    "error-line" get print
    
    [ "error-col" get " " fill , "^" , ] make-string print ;

: in-parser? ( -- ? )
    "error-line" get "error-col" get and ;

: :s ( -- ) "error-datastack"  get {.} ;
: :r ( -- ) "error-callstack"  get {.} ;
: :n ( -- ) "error-namestack"  get [.] ;
: :c ( -- ) "error-catchstack" get [.] ;

: :get ( var -- value ) "error-namestack" get (get) ;

: flush-error-handler ( error -- )
    #! Last resort.
    [ "Error in default error handler!" print drop ] when ;

: default-error-handler ( error -- )
    #! Print the error.
    [
        in-parser? [ parse-dump ] [ standard-dump ] ifte

        [ :s :r :n :c ] [ prettyprint-word " " write ] each
        "show stacks at time of error." print
        \ :get prettyprint-word
        " ( var -- value ) inspects the error namestack." print
    ] [
        flush-error-handler
    ] catch ;

: print-error ( quot -- )
    #! Execute a quotation, and if it throws an error, print it
    #! and return to the caller.
    [ [ default-error-handler ] when* ] catch ;

: init-error-handler ( -- )
    [ 1 exit* ] >c ( last resort )
    [ default-error-handler 1 exit* ] >c
    [ dup save-error rethrow ] 5 setenv ( kernel calls on error ) ;

! So that stage 2 boot gives a useful error message if something
! fails after this file is loaded.
init-error-handler
