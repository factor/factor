! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: slots arrays definitions generic hashtables summary io
kernel math namespaces make prettyprint prettyprint.config
sequences assocs sequences.private strings io.styles
io.pathnames vectors words system splitting math.parser
classes.mixin classes.tuple continuations continuations.private
combinators generic.math classes.builtin classes compiler.units
generic.standard generic.single vocabs init kernel.private io.encodings
accessors math.order destructors source-files parser
classes.tuple.parser effects.parser lexer
generic.parser strings.parser vocabs.loader vocabs.parser see
source-files.errors ;
IN: debugger

GENERIC: error. ( error -- )
GENERIC: error-help ( error -- topic )

M: object error. . ;
M: object error-help drop f ;

M: tuple error-help class ;

M: string error. print ;

: :s ( -- )
    error-continuation get data>> stack. ;

: :r ( -- )
    error-continuation get retain>> stack. ;

: :c ( -- )
    error-continuation get call>> callstack. ;

: :get ( variable -- value )
    error-continuation get name>> assoc-stack ;

: :res ( n -- * )
    1- restarts get-global nth f restarts set-global restart ;

: :1 ( -- * ) 1 :res ;
: :2 ( -- * ) 2 :res ;
: :3 ( -- * ) 3 :res ;

: restart. ( restart n -- )
    [
        1+ dup 3 <= [ ":" % # "    " % ] [ # " :res  " % ] if
        name>> %
    ] "" make print ;

: restarts. ( -- )
    restarts get [
        nl
        "The following restarts are available:" print
        nl
        [ restart. ] each-index
    ] unless-empty ;

: print-error ( error -- )
    [ error. flush ] curry
    [ global [ "Error in print-error!" print drop ] bind ]
    recover ;

: :error ( -- )
    error get print-error ;

: print-error-and-restarts ( error -- )
    print-error
    restarts.
    nl
    "Type :help for debugging help." print flush ;

: try ( quot -- )
    [ print-error-and-restarts ] recover ; inline

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

HOOK: signal-error. os ( obj -- )

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

PREDICATE: vm-error < array
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup first "kernel-error" = not ] [ drop f ] }
        [ second 0 15 between? ]
    } cond ;

: vm-errors ( error -- n errors )
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

M: vm-error summary drop "VM error" ;

M: vm-error error. dup vm-errors case ;

M: vm-error error-help vm-errors at first ;

M: no-method summary
    drop "No suitable method" ;

M: no-method error.
    "Generic word " write
    dup generic>> pprint
    " does not define a method for the " write
    dup object>> class pprint
    " class." print
    "Dispatching on object: " write object>> short. ;

M: bad-slot-value summary drop "Bad store to specialized slot" ;

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

M: bad-superclass summary
    drop "Tuple classes can only inherit from other tuple classes" ;

M: no-initial-value summary
    drop "Initial value must be provided for slots specialized to this class" ;

M: bad-initial-value summary
    drop "Incompatible initial value" ;

M: no-cond summary
    drop "Fall-through in cond" ;

M: no-case summary
    drop "Fall-through in case" ;

M: slice-error summary
    drop "Cannot create slice" ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: condition error. error>> error. ;

M: condition summary error>> summary ;

M: condition error-help error>> error-help ;

M: assert summary drop "Assertion failed" ;

M: assert-sequence summary drop "Assertion failed" ;

M: assert-sequence error.
    standard-table-style [
        [ "=== Expected:" print expected>> stack. ]
        [ "=== Got:" print got>> stack. ] bi
    ] tabular-output ;

M: immutable summary drop "Sequence is immutable" ;

M: redefine-error error.
    "Re-definition of " write
    def>> . ;

M: undefined summary
    drop "Calling a deferred word before it has been defined" ;

M: no-compilation-unit error.
    "Attempting to define " write
    definition>> pprint
    " outside of a compilation unit" print ;

M: no-vocab summary
    drop "Vocabulary does not exist" ;

M: encode-error summary drop "Character encoding error" ;

M: decode-error summary drop "Character decoding error" ;

M: bad-create summary drop "Bad parameters to create" ;

M: attempt-all-error summary drop "Nothing to attempt" ;

M: already-disposed summary drop "Attempting to operate on disposed object" ;

M: no-current-vocab summary
    drop "Not in a vocabulary; IN: form required" ;

M: no-word-error error.
    "No word named ``" write name>> write "'' found in current vocabulary search path" print ;

M: staging-violation summary
    drop
    "A parsing word cannot be used in the same file it is defined in." ;

M: bad-number summary
    drop "Bad number literal" ;

M: duplicate-slot-names summary
    drop "Duplicate slot names" ;

M: invalid-slot-name summary
    drop "Invalid slot name" ;

M: not-in-a-method-error summary
    drop "call-next-method can only be called in a method definition" ;

GENERIC: expected>string ( obj -- str )

M: f expected>string drop "end of input" ;
M: word expected>string name>> ;
M: string expected>string ;

M: unexpected error.
    "Expected " write
    dup want>> expected>string write
    " but got " write
    got>> expected>string print ;

M: lexer-error error.
    [ lexer-dump ] [ error>> error. ] bi ;

M: lexer-error summary
    error>> summary ;

M: lexer-error compute-restarts
    error>> compute-restarts ;

M: lexer-error error-help
    error>> error-help ;

M: bad-effect summary
    drop "Bad stack effect declaration" ;

M: bad-escape summary drop "Bad escape code" ;

M: bad-literal-tuple summary drop "Bad literal tuple" ;

M: check-mixin-class summary drop "Not a mixin class" ;

M: not-found-in-roots summary drop "Cannot resolve vocab: path" ;

M: wrong-values summary drop "Quotation called with wrong stack effect" ;

{
    { [ os windows? ] [ "debugger.windows" require ] }
    { [ os unix? ] [ "debugger.unix" require ] }
} cond