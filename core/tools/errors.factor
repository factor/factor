! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: errors
USING: generic help tools io kernel math math-internals parser
prettyprint queues sequences sequences-internals strings test
words definitions libc inspector c-streams ;

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

: divide-by-zero-error. ( obj -- )
    "Division by zero" print drop ;

: signal-error. ( obj -- )
    "Operating system signal " write third . ;

: array-size-error. ( obj -- )
    "Invalid array size: " write dup third .
    "Maximum: " write fourth 1- . ;

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
    "Memory protection fault at address " write third .h ;

: primitive-error.
    "Unimplemented primitive" print drop ;

: kernel-error ( error -- word )
    #! Kernel errors are indexed by integers.
    second {
        expired-error.
        io-error.
        undefined-word-error.
        type-check-error.
        divide-by-zero-error.
        signal-error.
        array-size-error.
        c-string-error.
        ffi-error.
        heap-scan-error.
        undefined-symbol-error.
        datastack-underflow.
        datastack-overflow.
        retainstack-underflow.
        retainstack-overflow.
        callstack-underflow.
        callstack-overflow.
        memory-error.
        objc-error.
        primitive-error.
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

M: no-case summary
    drop "Fall-through in case" ;

M: slice-error error.
    "Cannot create slice because " write
    slice-error-reason print ;

M: no-word summary
    drop "Word not found in current vocabulary search path" ;

GENERIC: expected>string ( obj -- str )

M: f expected>string drop "end of input" ;
M: word expected>string word-name ;
M: string expected>string ;

M: unexpected error.
    "Expected " write
    dup unexpected-want expected>string write
    " but got " write
    unexpected-got expected>string print ;

M: bad-escape summary
    drop "Bad escape code" ;

M: bad-number summary
    drop "Bad number literal" ;

: parse-dump ( error -- )
    "Parsing " write
    dup parse-error-file
    [
        <pathname> .
        "Line " write dup parse-error-line [ 1 ] unless* .
    ] [
        "interactive input:" print
    ] if*

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

M: check-ptr summary drop "Memory allocation failed" ;
