! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slots arrays definitions generic hashtables inspector io
kernel math namespaces prettyprint prettyprint.config sequences
assocs sequences.private strings io.styles vectors words system
splitting math.parser classes.tuple continuations
continuations.private combinators generic.math classes.builtin
classes compiler.units generic.standard vocabs threads
threads.private init kernel.private libc io.encodings mirrors
accessors math.order destructors ;
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

: :res ( n -- * )
    1- restarts get-global nth f restarts set-global restart ;

: :1 ( -- * ) 1 :res ;
: :2 ( -- * ) 2 :res ;
: :3 ( -- * ) 3 :res ;

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

: print-error-and-restarts ( error -- )
    print-error
    restarts.
    nl
    "Type :help for debugging help." print flush ;

: try ( quot -- )
    [ print-error-and-restarts ] recover ;

ERROR: assert got expect ;

: assert= ( a b -- ) 2dup = [ 2drop ] [ assert ] if ;

: depth ( -- n ) datastack length ;

: trim-datastacks ( seq1 seq2 -- seq1' seq2' )
    2dup [ length ] bi@ min tuck tail >r tail r> ;

ERROR: relative-underflow stack ;

M: relative-underflow summary
    drop "Too many items removed from data stack" ;

ERROR: relative-overflow stack ;

M: relative-overflow summary
    drop "Superfluous items pushed to data stack" ;

: assert-depth ( quot -- )
    >r datastack r> dip >r datastack r>
    2dup [ length ] compare {
        { +lt+ [ trim-datastacks nip relative-underflow ] }
        { +eq+ [ 2drop ] }
        { +gt+ [ trim-datastacks drop relative-overflow ] }
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

: datastack-underflow. ( obj -- ) "Data" stack-underflow. ;
: datastack-overflow. ( obj -- ) "Data" stack-overflow. ;
: retainstack-underflow. ( obj -- ) "Retain" stack-underflow. ;
: retainstack-overflow. ( obj -- ) "Retain" stack-overflow. ;

: memory-error. ( error -- )
    "Memory protection fault at address " write third .h ;

: primitive-error. ( error -- ) 
    "Unimplemented primitive" print drop ;

PREDICATE: kernel-error < array
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup first "kernel-error" = not ] [ drop f ] }
        [ second 0 15 between? ]
    } cond ;

: kernel-errors ( error -- n errors )
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
    dup generic>> pprint
    " does not define a method for the " write
    dup object>> class pprint
    " class." print
    "Dispatching on object: " write object>> short. ;

M: bad-slot-value error.
    "Bad store to specialized slot" print
    dup [ index>> 2 - ] [ object>> class all-slots ] bi nth
    standard-table-style [
        [
            [ "Object" write ] with-cell
            [ over object>> short. ] with-cell
        ] with-row
        [
            [ "Slot" write ] with-cell
            [ dup name>> short. ] with-cell
        ] with-row
        [
            [ "Slot class" write ] with-cell
            [ dup class>> short. ] with-cell
        ] with-row
        [
            [ "Value" write ] with-cell
            [ over value>> short. ] with-cell
        ] with-row
        [
            [ "Value class" write ] with-cell
            [ over value>> class short. ] with-cell
        ] with-row
    ] tabular-output
    2drop ;

M: no-math-method summary
    drop "No suitable arithmetic method" ;

M: no-next-method summary
    drop "Executing call-next-method from least-specific method" ;

M: inconsistent-next-method summary
    drop "Executing call-next-method with inconsistent parameters" ;

M: check-method summary
    drop "Invalid parameters for create-method" ;

M: not-a-tuple summary
    drop "Not a tuple" ;

M: not-a-tuple-class summary
    drop "Not a tuple class" ;

M: bad-superclass summary
    drop "Tuple classes can only inherit from other tuple classes" ;

M: no-cond summary
    drop "Fall-through in cond" ;

M: no-case summary
    drop "Fall-through in case" ;

M: slice-error error.
    "Cannot create slice because " write
    slice-error-reason print ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: condition error. error>> error. ;

M: condition summary error>> summary ;

M: condition error-help error>> error-help ;

M: assert summary drop "Assertion failed" ;

M: assert error.
    "Assertion failed" print
    standard-table-style [
        15 length-limit set
        5 line-limit set
        [ expect>> [ [ "Expect:" write ] with-cell pprint-cell ] with-row ]
        [ got>> [ [ "Got:" write ] with-cell pprint-cell ] with-row ] bi
    ] tabular-output ;

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

: error-in-thread. ( thread -- )
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
            error-thread get-global error-in-thread. print-error flush
        ] bind
    ] if ;

M: encode-error summary drop "Character encoding error" ;

M: decode-error summary drop "Character decoding error" ;

M: no-such-slot summary drop "No such slot" ;

M: read-only-slot summary drop "Slot is declared read-only" ;

M: bad-create summary drop "Bad parameters to create" ;

M: attempt-all-error summary drop "Nothing to attempt" ;

M: already-disposed summary drop "Attempting to operate on disposed object" ;

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
