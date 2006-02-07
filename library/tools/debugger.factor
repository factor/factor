! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: generic hashtables inspector io kernel kernel-internals
lists math namespaces parser prettyprint sequences
sequences-internals strings vectors words ;

SYMBOL: error
SYMBOL: error-continuation

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

: user-interrupt. ( obj -- )
    "User interrupt" print drop ;

: stack-underflow. ( obj -- )
    "Stack underflow" print drop ;

: stack-overflow. ( obj -- )
    "Stack overflow" print drop ;

: return-stack-underflow. ( obj -- )
    "Return stack underflow" print drop ;

: return-stack-overflow. ( obj -- )
    "Return stack overflow" print drop ;

PREDICATE: cons kernel-error ( obj -- ? )
    dup first kernel-error = swap second 0 11 between? and ;

M: kernel-error error. ( error -- )
    #! Kernel errors are indexed by integers.
    cdr uncons car swap {
        [ expired-error. ]
        [ io-error. ]
        [ undefined-word-error. ]
        [ type-check-error. ]
        [ float-format-error. ]
        [ signal-error. ]
        [ negative-array-size-error. ]
        [ c-string-error. ]
        [ ffi-error. ]
        [ heap-scan-error. ]
        [ undefined-symbol-error. ]
        [ user-interrupt. ]
	[ stack-underflow. ]
	[ stack-overflow. ]
	[ return-stack-underflow. ]
	[ return-stack-overflow . ]
    } dispatch ;

M: no-method summary drop "No suitable method" ;

M: no-math-method summary drop "No suitable arithmetic method" ;

: parse-dump ( error -- )
    "Parsing " write
    dup parse-error-file [ "<interactive>" ] unless* write
    ":" write
    dup parse-error-line [ 1 ] unless* number>string print
    
    dup parse-error-text dup string? [ print ] [ drop ] if
    
    parse-error-col [ 0 ] unless*
    CHAR: \s <string> write "^" print ;

M: parse-error error. ( error -- )
    dup parse-dump  delegate error. ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: tuple error. ( error -- ) describe ;

M: object error. ( error -- ) . ;

: :s ( -- ) error-continuation get continuation-data stack. ;

: :r ( -- ) error-continuation get continuation-call stack. ;

: :get ( var -- value )
    error-continuation get continuation-name hash-stack ;

: debug-help ( -- )
    ":s :r show stacks at time of error" print
    ":get ( var -- value ) accesses variables at time of error" print
    ":error starts the inspector with the error" print
    ":cc starts the inspector with the error continuation" print
    flush ;

: flush-error-handler ( -- )
    [ "Error in default error handler!" print ] when ;

: print-error ( error -- )
    "An unhandled error was caught:" print terpri
    [ dup error. ] catch nip flush-error-handler ;

: try ( quot -- ) [ print-error terpri debug-help ] recover ;

: save-error ( error continuation -- )
    error-continuation set-global error set-global ;

: error-handler ( error -- )
    dup continuation save-error rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ( kernel calls on error )
    [ error-handler ] 5 setenv
    kernel-error 12 setenv ;
