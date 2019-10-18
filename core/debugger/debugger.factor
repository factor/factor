! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables inspector io kernel
math namespaces prettyprint sequences assocs sequences.private
strings io.styles vectors words system splitting math.parser
tuples continuations continuations.private combinators
generic.math io.streams.duplex classes
generic.standard ;
IN: debugger

GENERIC: error. ( error -- )
GENERIC: error-help ( error -- topic )

M: object error. . ;
M: object error-help drop f ;

M: tuple error. describe ;
M: tuple error-help class ;

M: string error. print ;

: :s ( -- )
    error-continuation get continuation-data stack. ;

: :r ( -- )
    error-continuation get continuation-retain stack. ;

: :c ( -- )
    error-continuation get continuation-call callstack. ;

: :get ( variable -- value )
    error-continuation get continuation-name assoc-stack ;

: :res ( n -- )
    1- restarts get-global nth f restarts set-global restart ;

: :1 1 :res ;
: :2 2 :res ;
: :3 3 :res ;

: restart. ( restart n -- )
    [
        1+ dup 3 <= [ ":" % # "    " % ] [ # " :res  " % ] if
        restart-name %
    ] "" make print ;

: restarts. ( -- )
    restarts get dup empty? [
        drop
    ] [
        nl
        "The following restarts are available:" print
        nl
        dup length [ restart. ] 2each
    ] if ;

: debug-help ( -- )
    nl
    "Debugger commands:" print
    nl
    ":help - documentation for this error" print
    ":s    - data stack at exception time" print
    ":r    - retain stack at exception time" print
    ":c    - call stack at exception time" print
    ":edit - jump to source location (parse errors only)" print

    ":get  ( var -- value ) accesses variables at time of the error" print
    flush ;

: print-error ( error -- )
    [ error. flush ] curry
    [ global [ "Error in print-error!" print drop ] bind ]
    recover ;

SYMBOL: error-hook

[ print-error restarts. debug-help ] error-hook set-global

: try ( quot -- )
    [ error-hook get call ] recover ;

TUPLE: assert got expect ;

: assert ( got expect -- * ) \ assert construct-boa throw ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

: depth ( -- n ) datastack length ;

: assert-depth ( quot -- ) depth slip depth swap assert= ;

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

: datastack-underflow. "Data" stack-underflow. ;
: datastack-overflow. "Data" stack-overflow. ;
: retainstack-underflow. "Retain" stack-underflow. ;
: retainstack-overflow. "Retain" stack-overflow. ;

: memory-error.
    "Memory protection fault at address " write third .h ;

: primitive-error.
    "Unimplemented primitive" print drop ;

PREDICATE: array kernel-error ( obj -- ? )
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup first "kernel-error" = not ] [ drop f ] }
        { [ t ] [ second 0 16 between? ] }
    } cond ;

: kernel-errors
    second {
        { 0  [ expired-error.          ] }
        { 1  [ io-error.               ] }
        { 2  [ undefined-word-error.   ] }
        { 3  [ type-check-error.       ] }
        { 4  [ divide-by-zero-error.   ] }
        { 5  [ signal-error.           ] }
        { 6  [ array-size-error.       ] }
        { 7  [ c-string-error.         ] }
        { 8  [ ffi-error.              ] }
        { 9  [ heap-scan-error.        ] }
        { 10 [ undefined-symbol-error. ] }
        { 11 [ datastack-underflow.    ] }
        { 12 [ datastack-overflow.     ] }
        { 13 [ retainstack-underflow.  ] }
        { 14 [ retainstack-overflow.   ] }
        { 15 [ memory-error.           ] }
        { 16 [ primitive-error.        ] }
    } ; inline

M: kernel-error error. dup kernel-errors case ;

M: kernel-error error-help kernel-errors at first ;

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

M: check-closed summary
    drop "Attempt to perform I/O on closed stream" ;

M: check-method summary
    drop "Invalid parameters for define-method" ;

M: check-tuple summary
    drop "Invalid class for define-constructor" ;

M: no-cond summary
    drop "Fall-through in cond" ;

M: no-case summary
    drop "Fall-through in case" ;

M: slice-error error.
    "Cannot create slice because " write
    slice-error-reason print ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: condition error. delegate error. ;

M: condition error-help drop f ;

M: assert summary drop "Assertion failed" ;

M: immutable summary drop "Sequence is immutable" ;
