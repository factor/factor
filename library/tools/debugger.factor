! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors USING: generic kernel kernel-internals lists math namespaces
parser prettyprint stdio streams strings unparser vectors words ;

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
    "Object type: " write class prettyprint-word terpri
    "Expected type: " write builtin-type prettyprint-word terpri ;

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

: heap-scan-error ( obj -- )
    "Cannot do next-object outside begin/end-scan" write drop ;

PREDICATE: cons kernel-error ( obj -- ? )
    car kernel-error = ;

M: kernel-error error. ( error -- )
    #! Kernel errors are indexed by integers.
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
        heap-scan-error
    } vector-nth execute ;

M: no-method error. ( error -- )
    [
        "The generic word " ,
        dup no-method-generic unparse ,
        " does not have a suitable method for " ,
        no-method-object unparse ,
    ] make-string print ;

M: string error. ( error -- ) print ;

M: object error. ( error -- ) . ;

: :s ( -- ) "error-datastack"  get {.} ;
: :r ( -- ) "error-callstack"  get {.} ;
: :n ( -- ) "error-namestack"  get [.] ;
: :c ( -- ) "error-catchstack" get [.] ;

: :get ( var -- value ) "error-namestack" get (get) ;

: debug-help ( -- )
    [ :s :r :n :c ] [ prettyprint-word " " write ] each
    "show stacks at time of error." print
    \ :get prettyprint-word
    " ( var -- value ) inspects the error namestack." print ;

: flush-error-handler ( error -- )
    #! Last resort.
    [ "Error in default error handler!" print drop ] when ;

: print-error ( error -- )
    #! Print the error.
    [ error. ] [ flush-error-handler ] catch ;

: try ( quot -- )
    #! Execute a quotation, and if it throws an error, print it
    #! and return to the caller.
    [ [ print-error debug-help ] when* ] catch ;

: save-error ( error ds rs ns cs -- )
    #! Save the stacks and parser state for post-mortem
    #! inspection after an error.
    global [
        "error-catchstack" set
        "error-namestack" set
        "error-callstack" set
        "error-datastack" set
        "error" set
    ] bind ;

: init-error-handler ( -- )
    [ die ] >c ( last resort )
    [ print-error die ] >c
    ( kernel calls on error )
    [
        datastack dupd callstack namestack catchstack
        save-error rethrow
    ] 5 setenv
    kernel-error 12 setenv ;

! So that stage 2 boot gives a useful error message if something
! fails after this file is loaded.
init-error-handler
