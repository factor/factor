! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic hashtables inspector io kernel
kernel-internals math namespaces parser prettyprint sequences
sequences-internals strings styles vectors words ;
IN: errors

SYMBOL: error
SYMBOL: error-continuation
SYMBOL: restarts

: expired-error. ( obj -- )
    "Object did not survive image save/load: " write third . ;

: undefined-word-error. ( obj -- )
    "Undefined word: " write third . ;

: io-error. ( error -- )
    "I/O error: " write third print ;

: type-check-error. ( list -- )
    "Type check error" print
    "Object: " write dup fourth short.
    "Object type: " write dup fourth class .
    "Expected type: " write third type>class . ;

: signal-error. ( obj -- )
    "Operating system signal " write third . ;

: negative-array-size-error. ( obj -- )
    "Cannot allocate array with negative size " write third . ;

: c-string-error. ( obj -- )
    "Cannot convert to C string: " write third . ;

: ffi-error. ( obj -- )
    "FFI: " write third print ;

: heap-scan-error. ( obj -- )
    "Cannot do next-object outside begin/end-scan" print drop ;

: undefined-symbol-error. ( obj -- )
    "The image refers to a library or symbol that was not found"
    " at load time" append print drop ;

: user-interrupt. ( obj -- )
    "User interrupt" print drop ;

: stack-underflow. ( obj name -- )
    write " stack underflow" print drop ;

: stack-overflow. ( obj name -- )
    write " stack overflow" print drop ;

! Hook for library/cocoa/
DEFER: objc-error. ( alien -- )

PREDICATE: array kernel-error ( obj -- ? )
    dup first kernel-error eq? swap second 0 18 between? and ;

M: kernel-error error. ( error -- )
    #! Kernel errors are indexed by integers.
    dup second {
        [ expired-error. ]
        [ io-error. ]
        [ undefined-word-error. ]
        [ type-check-error. ]
        [ signal-error. ]
        [ negative-array-size-error. ]
        [ c-string-error. ]
        [ ffi-error. ]
        [ heap-scan-error. ]
        [ undefined-symbol-error. ]
        [ user-interrupt. ]
        [ "Data" stack-underflow. ]
        [ "Data" stack-overflow. ]
        [ "Retain" stack-underflow. ]
        [ "Retain" stack-overflow. ]
        [ "Call" stack-underflow. ]
        [ "Call" stack-overflow. ]
        [ objc-error. ]
    } dispatch ;

M: no-method summary
    "No suitable method" ;

M: no-method error. ( error -- )
    "Generic word " write
    dup no-method-generic pprint
    " does not define a method for the " write
    dup no-method-object class pprint
    " class." print
    "Allowed classes: " write dup no-method-generic order .
    "Dispatching on object: " write no-method-object short. ;

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

M: condition error. delegate error. ;

M: tuple error. ( error -- ) describe ;

M: object error. ( error -- ) . ;

: :s ( -- ) error-continuation get continuation-data stack. ;

: :r ( -- ) error-continuation get continuation-retain stack. ;

: :c ( -- ) error-continuation get continuation-call callstack. ;

: :get ( var -- value )
    error-continuation get continuation-name hash-stack ;

: :res ( n -- ) restarts get nth first3 continue-with ;

: (debug-help) ( string quot -- )
    <input> simple-object terpri ;

: restart. ( restart n -- )
    [ [ # " :res  " % first % ] "" make ] keep
    [ :res ] curry (debug-help) ;

: restarts. ( -- )
    restarts get dup empty? [
        drop
    ] [
        terpri
        "The following restarts are available:" print
        terpri
        dup length [ restart. ] 2each
    ] if ;

DEFER: :error
DEFER: :cc

: debug-help ( -- )
    terpri
    "Debugger commands:" print
    terpri
    ":s  data stack at exception time" [ :s ] (debug-help)
    ":r  retain stack at exception time" [ :r ] (debug-help)
    ":c  call stack at exception time" [ :c ] (debug-help)
    ":error starts the inspector with the error" [ :error ] (debug-help)
    ":cc starts the inspector with the error continuation" [ :cc ] (debug-help)
    ":get ( var -- value ) accesses variables at time of error" print
    flush ;

: flush-error-handler ( -- )
    [ "Error in default error handler!" print ] when ;

: print-error ( error -- )
    [
        dup error.
        restarts.
        debug-help
    ] [
        "Error in print-error!" print
    ] recover drop ;

: try ( quot -- ) [ print-error ] recover ;

: save-error ( error continuation -- )
    error-continuation set-global
    dup error set-global
    compute-restarts restarts set-global ;

: error-handler ( error -- )
    dup continuation save-error rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ( kernel calls on error )
    [ error-handler ] 5 setenv
    kernel-error 12 setenv ;
