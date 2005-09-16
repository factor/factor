! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: generic kernel kernel-internals lists math namespaces
parser prettyprint sequences io strings vectors words ;

: expired-error. ( obj -- )
    "Object did not survive image save/load: " write . ;

: undefined-word-error. ( obj -- )
    "Undefined word: " write . ;

: io-error. ( error -- )
    "I/O error: " write print ;

: type-check-error. ( list -- )
    "Type check error" print
    uncons car dup "Object: " write short.
    "Object type: " write class .
    "Expected type: " write type>class . ;

: float-format-error. ( list -- )
    "Invalid floating point literal format: " write . ;

: signal-error. ( obj -- )
    "Operating system signal " write . ;

: negative-array-size-error. ( obj -- )
    "Cannot allocate array with negative size " write . ;

: c-string-error. ( obj -- )
    "Cannot convert to C string: " write . ;

: ffi-error. ( obj -- )
    "FFI: " write print ;

: heap-scan-error. ( obj -- )
    "Cannot do next-object outside begin/end-scan" print drop ;

: undefined-symbol-error. ( obj -- )
    "The image refers to a library or symbol that was not found"
    " at load time" append print drop ;

PREDICATE: cons kernel-error ( obj -- ? )
    car kernel-error = ;

M: f error. ( f -- ) drop ;

M: kernel-error error. ( error -- )
    #! Kernel errors are indexed by integers.
    cdr uncons car swap {
        expired-error.
        io-error.
        undefined-word-error.
        type-check-error.
        float-format-error.
        signal-error.
        negative-array-size-error.
        c-string-error.
        ffi-error.
        heap-scan-error.
        undefined-symbol-error.
    } nth execute ;

M: no-method error. ( error -- )
    "No suitable method." print
    "Generic word: " write dup no-method-generic .
    "Object: " write no-method-object short. ;

M: no-math-method error. ( error -- )
    "No suitable arithmetic method." print
    "Generic word: " write dup no-math-method-generic .
    "Left operand: " write dup no-math-method-left short.
    "Right operand: " write no-math-method-right short. ;

: parse-dump ( error -- )
    "Parsing " write
    dup parse-error-file [ "<interactive>" ] unless* write
    ":" write
    dup parse-error-line [ 1 ] unless* number>string print
    
    dup parse-error-text dup string? [ print ] [ drop ] ifte
    
    parse-error-col [ 0 ] unless* CHAR: \s fill write "^" print ;

M: parse-error error. ( error -- )
    dup parse-dump  delegate error. ;

M: bounds-error error. ( error -- )
    "Sequence index out of bounds" print
    "Sequence: " write dup bounds-error-seq short.
    "Minimum: 0" print
    "Maximum: " write dup bounds-error-seq length .
    "Requested: " write bounds-error-index . ;

M: string error. ( error -- ) print ;

M: object error. ( error -- ) . ;

: :s ( -- ) "error-datastack"  get stack. ;
: :r ( -- ) "error-callstack"  get stack. ;

: :get ( var -- value ) "error-namestack" get (get) ;

: debug-help ( -- )
    ":s :r show stacks at time of error." print
    ":get ( var -- value ) inspects the error namestack." print ;

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
    [ die ] quot>interp >c ( last resort )
    [ global [ print-error ] bind die ] quot>interp >c
    ( kernel calls on error )
    [
        datastack dupd callstack namestack catchstack
        save-error rethrow
    ] 5 setenv
    kernel-error 12 setenv ;
