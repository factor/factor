! Copyright (C) 2004, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings arrays assocs classes
classes.builtin classes.tuple classes.tuple.parser combinators
combinators.short-circuit compiler.errors compiler.units
continuations definitions destructors effects.parser fixups
generic generic.math generic.parser generic.single grouping io
io.encodings io.styles kernel kernel.private lexer libc make
math math.order math.parser math.ratios namespaces parser
prettyprint sequences sequences.private slots
source-files.errors strings strings.parser summary system vocabs
vocabs.loader vocabs.parser words ;
IN: debugger

GENERIC: error-help ( error -- topic )

M: object error-help drop f ;

M: tuple error-help class-of ;

M: source-file-error error-help error>> error-help ;

GENERIC: error. ( error -- )

M: object error. short. ;

M: string error. print ;

: traceback-link. ( continuation -- )
    "[" write [ "Traceback" ] dip write-object "]" print ;

: :s ( -- )
    error-continuation get data>> stack. ;

: :r ( -- )
    error-continuation get retain>> stack. ;

: :c ( -- )
    error-continuation get call>> callstack. ;

: :get ( variable -- value )
    error-continuation get name>> assoc-stack ;

: :res ( n -- * )
    1 - restarts [ nth f ] change-global
    [ dup no-op-restart = [ drop f ] when ] change-obj
    continue-restart ;

: :1 ( -- * ) 1 :res ;
: :2 ( -- * ) 2 :res ;
: :3 ( -- * ) 3 :res ;

: restart. ( restart n -- )
    [
        1 + dup 3 <= [ ":" % # "      " % ] [ # " :res  " % ] if
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
    [ [ "Error in print-error!" print drop ] with-global ]
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
    "I/O error #" write third [ . ] [ strerror print ] bi ;

: type-check-error. ( obj -- )
    "Type check error" print
    "Object: " write dup fourth short.
    "Object type: " write dup fourth class-of .
    "Expected type: " write third type>class . ;

: divide-by-zero-error. ( obj -- )
    "Division by zero" print drop ;

HOOK: signal-error. os ( obj -- )

: array-size-error. ( obj -- )
    "Invalid array size: " write dup third .
    "Maximum: " write fourth 1 - . ;

: fixnum-range-error. ( obj -- )
    "Cannot convert to fixnum: " write third . ;

: ffi-error. ( obj -- )
    "FFI error" print drop ;

: find-ffi-error ( string -- error )
    [ linkage-errors get ] dip
    '[ nip asset>> name>> _ = ] assoc-find drop nip
    [ error>> message>> ] [ "none" ] if* ;

: undefined-symbol-error. ( obj -- )
    "Cannot resolve C library function" print
    "Library: " write dup fourth .
    third symbol>string
    [ "Symbol: " write print ]
    [ "DlError: " write find-ffi-error print ] bi
    "See https://concatenative.org/wiki/view/Factor/Requirements" print ;

: stack-underflow. ( obj name -- )
    write " stack underflow" print drop ;

: stack-overflow. ( obj name -- )
    write " stack overflow" print drop ;

: datastack-underflow. ( obj -- ) "Data" stack-underflow. ;
: datastack-overflow. ( obj -- ) "Data" stack-overflow. ;
: retainstack-underflow. ( obj -- ) "Retain" stack-underflow. ;
: retainstack-overflow. ( obj -- ) "Retain" stack-overflow. ;
: callstack-underflow. ( obj -- ) "Call" stack-underflow. ;
: callstack-overflow. ( obj -- ) "Call" stack-overflow. ;

: memory-error. ( error -- )
    "Memory protection fault at address " write third .h ;

: fp-trap-error. ( error -- )
    "Floating point trap" print drop ;

: interrupt-error. ( error -- )
    "Interrupt" print drop ;

: callback-space-overflow. ( error -- )
    "Callback space overflow" print drop ;

PREDICATE: vm-error < array
    dup length 2 < [ drop f ] [
        {
            [ first-unsafe KERNEL-ERROR = ]
            [ second-unsafe 0 kernel-error-count 1 - between? ]
        } 1&&
    ] if ;

: vm-errors ( error -- n errors )
    second {
        [ expired-error.           ]
        [ io-error.                ]
        [ drop                     ]
        [ type-check-error.        ]
        [ divide-by-zero-error.    ]
        [ signal-error.            ]
        [ array-size-error.        ]
        [ fixnum-range-error.      ]
        [ ffi-error.               ]
        [ undefined-symbol-error.  ]
        [ datastack-underflow.     ]
        [ datastack-overflow.      ]
        [ retainstack-underflow.   ]
        [ retainstack-overflow.    ]
        [ callstack-underflow.     ]
        [ callstack-overflow.      ]
        [ memory-error.            ]
        [ fp-trap-error.           ]
        [ interrupt-error.         ]
        [ callback-space-overflow. ]
    } ; inline

M: vm-error summary drop "VM error" ;

M: vm-error error. dup vm-errors dispatch ;

M: vm-error error-help vm-errors nth first ;

M: division-by-zero summary
    drop "Division by zero" ;

M: no-method summary
    drop "No suitable method" ;

M: no-method error.
    "Generic word " write
    dup generic>> pprint
    " does not define a method for the " write
    dup object>> class-of pprint
    " class." print
    "Dispatching on object: " write object>> short. ;

M: bad-slot-value summary drop "Bad store to specialized slot" ;

M: bad-slot-name summary drop "Bad slot name in object literal" ;

M: bad-vocab-name summary drop "Vocab name cannot contain ':/\\ \"'" ;

M: no-math-method summary
    drop "No suitable arithmetic method" ;

M: no-next-method summary
    drop "Executing call-next-method from least-specific method" ;

M: inconsistent-next-method summary
    drop "Executing call-next-method with inconsistent parameters" ;

M: check-method-error summary
    drop "Invalid parameters for create-method" ;

M: bad-superclass summary
    drop "Tuple classes can only inherit from non-final tuple classes" ;

M: bad-initial-value summary
    drop "Incompatible initial value" ;

M: no-cond summary
    drop "Fall-through in cond" ;

M: no-case summary
    drop "Fall-through in case" ;

M: slice-error summary
    "Cannot create slice" swap {
        { [ dup from>> 0 < ] [ ": from < 0" ] }
        { [ dup [ to>> ] [ seq>> length ] bi > ] [ ": to > length" ] }
        { [ dup [ from>> ] [ to>> ] bi > ] [ ": from > to" ] }
        [ f ]
    } cond nip append ;

M: bounds-error summary drop "Sequence index out of bounds" ;

M: groups-error summary drop "Non positive group size" ;

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

M: undefined-word summary
    word>> undefined-word?
    "Cannot execute a deferred word before it has been defined"
    "Cannot execute a word before it has been compiled"
    ? ;

M: no-compilation-unit error.
    "Attempting to define " write
    definition>> pprint
    " outside of a compilation unit" print ;

M: no-vocab summary
    drop "Vocabulary does not exist" ;

M: encode-error summary drop "Character encoding error" ;

M: decode-error summary drop "Character decoding error" ;

M: bad-create summary drop "Bad parameters to create" ;

M: cannot-be-inline summary drop "This type of word cannot be inlined" ;

M: attempt-all-error summary drop "Nothing to attempt" ;

M: already-disposed summary drop "Attempting to operate on disposed object" ;

M: no-current-vocab-error summary
    drop "Not in a vocabulary; IN: form required" ;

M: no-word-error summary
    name>>
    "No word named “"
    "” found in current vocabulary search path" surround ;

M: no-word-error error. summary print ;

M: no-word-in-vocab summary
    [ vocab>> ] [ word>> ] bi
    [ "No word named “" % % "” found in “" % % "” vocabulary" % ] "" make ;

M: no-word-in-vocab error. summary print ;

M: ambiguous-use-error summary
    name>>
    "The name “" "” resolves to more than one word." surround ;

M: ambiguous-use-error error. summary print ;

M: staging-violation summary
    drop
    "A parsing word cannot be used in the same file it is defined in." ;

M: bad-number summary
    drop "Bad number literal" ;

M: duplicate-slot-names summary
    drop "Duplicate slot names" ;

M: invalid-slot-name summary
    drop "Invalid slot name" ;

M: bad-inheritance summary
    drop "Circularity in inheritance chain" ;

M: not-in-a-method-error summary
    drop "call-next-method can only be called in a method definition" ;

M: version-control-merge-conflict summary
    drop "Version control merge conflict in source code" ;

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
    [ error-continuation get swap compute-fixups ] [ error>> compute-restarts ] bi append ;

M: lexer-error error-help
    error>> error-help ;

M: bad-effect summary
    drop "Bad stack effect declaration" ;

M: invalid-row-variable summary
    drop "Stack effect row variables can only occur as the first input or output" ;

M: row-variable-can't-have-type summary
    drop "Stack effect row variables cannot have a declared type" ;

M: bad-escape error.
    "Bad escape code: \\" write char>> write1 ;

M: bad-literal-tuple summary drop "Bad literal tuple" ;

M: not-found-in-roots summary
    path>> "Cannot resolve vocab: " prepend ;

M: wrong-values summary drop "Quotation's stack effect does not match call site" ;

M: stack-effect-omits-dashes summary drop "Stack effect must contain “--”" ;

M: callsite-not-compiled summary
    drop "Caller not compiled with the optimizing compiler" ;

{ "threads" "debugger" } "debugger.threads" require-when

os unix? [ "debugger.unix" require ] when
