! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: errors
USING: generic help tools io kernel math math-internals parser
prettyprint queues sequences sequences-internals strings test
words definitions ;

: expired-error. ( obj -- )
    "Object did not survive image save/load: " write third . ;

: undefined-word-error. ( obj -- )
    "Undefined word: " write third . ;

: io-error. ( error -- )
    "I/O error: " write third print ;

: type-check-error. ( obj -- )
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
    "FFI: " write
    dup third [ write ": " write ] when*
    fourth print ;

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

! Hook for core/ui/cocoa module
DEFER: objc-error. ( alien -- )

: datastack-underflow. "Data" stack-underflow. ;
: datastack-overflow. "Data" stack-overflow. ;
: retainstack-underflow. "Retain" stack-underflow. ;
: retainstack-overflow. "Retain" stack-overflow. ;
: callstack-underflow. "Call" stack-underflow. ;
: callstack-overflow. "Call" stack-overflow. ;

: memory-error.
    "Data heap allocation request failed" print ;

: kernel-error ( error -- word )
    #! Kernel errors are indexed by integers.
    second {
        expired-error.
        io-error.
        undefined-word-error.
        type-check-error.
        signal-error.
        negative-array-size-error.
        c-string-error.
        ffi-error.
        heap-scan-error.
        undefined-symbol-error.
        user-interrupt.
        datastack-underflow.
        datastack-overflow.
        retainstack-underflow.
        retainstack-overflow.
        callstack-underflow.
        callstack-overflow.
        memory-error.
        objc-error.
    } nth ;

M: kernel-error error. dup kernel-error execute ;

M: kernel-error error-help kernel-error ;

M: no-method summary
    drop "No suitable method" ;

M: no-method error.
    "Generic word " write
    dup no-method-generic pprint
    " does not define a method for the " write
    dup no-method-object class pprint
    " class." print
    "Allowed classes: " write dup no-method-generic order .
    "Dispatching on object: " write no-method-object short. ;

M: no-math-method summary
    drop "No suitable arithmetic method" ;

M: /0 summary
    drop "Division by zero" ;

M: bad-escape summary
    drop "Invalid escape code" ;

M: c-stream-error summary
    drop "C stream I/O does not support this feature" ;

M: check-closed summary
    drop "Attempt to perform I/O on closed stream" ;

M: check-method summary
    drop "Invalid parameters for define-method" ;

M: check-tuple summary
    drop "Invalid class for define-constructor" ;

M: check-vocab summary
    drop "Vocabulary does not exist" ;

M: empty-queue summary
    drop "Empty queue" ;

M: no-article summary
    drop "Help article does not exist" ;

M: no-cond summary
    drop "Fall-through in cond" ;

M: slice-error error.
    "Cannot create slice because " write
    slice-error-reason print ;

M: no-word summary
    drop "Word not found in current vocabulary search path" ;

: parse-dump ( error -- )
    "Parsing " write
    dup parse-error-file
    [ "<interactive>" ] unless*
    write-pathname
    ":" write
    dup parse-error-line [ 1 ] unless* number>string print
    
    dup parse-error-text dup string? [ print ] [ drop ] if
    
    parse-error-col [ 0 ] unless*
    CHAR: \s <string> write "^" print ;

M: parse-error error.
    dup parse-dump  delegate error. ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: condition error. delegate error. ;

M: condition error-help drop f ;

M: assert summary drop "Assertion failed" ;

M: no-edit-hook summary drop "No edit hook is set" ;
