! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables inspector io kernel
math namespaces prettyprint sequences assocs sequences.private
strings io.styles vectors words system splitting math.parser
tuples continuations continuations.private combinators
generic.math io.streams.duplex classes compiler.units
generic.standard vocabs threads threads.private init
kernel.private libc io.encodings ;
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

: :vars ( -- )
    error-continuation get continuation-name namestack. ;

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

: print-error ( error -- )
    [ error. flush ] curry
    [ global [ "Error in print-error!" print drop ] bind ]
    recover ;

SYMBOL: error-hook

[
    print-error
    restarts.
    nl
    "Type :help for debugging help." print flush
] error-hook set-global

: try ( quot -- )
    [ error-hook get call ] recover ;

ERROR: assert got expect ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

: depth ( -- n ) datastack length ;

: trim-datastacks ( seq1 seq2 -- seq1' seq2' )
    2dup [ length ] 2apply min tuck tail >r tail r> ;

ERROR: relative-underflow stack ;

M: relative-underflow summary
    drop "Too many items removed from data stack" ;

ERROR: relative-overflow stack ;

M: relative-overflow summary
    drop "Superfluous items pushed to data stack" ;

: assert-depth ( quot -- )
    >r datastack r> swap slip >r datastack r>
    2dup [ length ] compare sgn {
        { -1 [ trim-datastacks nip relative-underflow ] }
        { 0 [ 2drop ] }
        { 1 [ trim-datastacks drop relative-overflow ] }
    } case ; inline

: expired-error. ( obj -- )
    "Object did not survive image save/load: " write third . ;

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

PREDICATE: kernel-error < array
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup first "kernel-error" = not ] [ drop f ] }
        { [ t ] [ second 0 15 between? ] }
    } cond ;

: kernel-errors
    second {
        { 0  [ expired-error.          ] }
        { 1  [ io-error.               ] }
        { 2  [ primitive-error.        ] }
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

M: stream-closed-twice summary
    drop "Attempt to perform I/O on closed stream" ;

M: check-method summary
    drop "Invalid parameters for create-method" ;

M: no-tuple-class summary
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

M: redefine-error error.
    "Re-definition of " write
    redefine-error-def . ;

M: undefined summary
    drop "Calling a deferred word before it has been defined" ;

M: no-compilation-unit error.
    "Attempting to define " write
    no-compilation-unit-definition pprint
    " outside of a compilation unit" print ;

M: no-vocab summary
    drop "Vocabulary does not exist" ;

M: bad-ptr summary
    drop "Memory allocation failed" ;

M: double-free summary
    drop "Free failed since memory is not allocated" ;

M: realloc-error summary
    drop "Memory reallocation failed" ;

: error-in-thread. ( -- )
    error-thread get-global
    "Error in thread " write
    [
        dup thread-id #
        " (" % dup thread-name %
        ", " % dup thread-quot unparse-short % ")" %
    ] "" make swap write-object ":" print nl ;

! Hooks
M: thread error-in-thread ( error thread -- )
    initial-thread get-global eq? [
        die drop
    ] [
        global [
            error-in-thread. print-error flush
        ] bind
    ] if ;

M: encode-error summary drop "Character encoding error" ;

M: decode-error summary drop "Character decoding error" ;

<PRIVATE

: init-debugger ( -- )
    V{ } clone set-catchstack
    ! VM calls on error
    [
        self error-thread set-global
        continuation error-continuation set-global
        rethrow
    ] 5 setenv
    ! VM adds this to kernel errors, so that user-space
    ! can identify them
    "kernel-error" 6 setenv ;

PRIVATE>

[ init-debugger ] "debugger" add-init-hook
