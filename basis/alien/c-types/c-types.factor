! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays arrays assocs kernel kernel.private libc math
namespaces make parser sequences strings words splitting math.parser
cpu.architecture alien alien.accessors alien.strings quotations
layouts system compiler.units io io.files io.encodings.binary
io.streams.memory accessors combinators effects continuations fry
classes vocabs vocabs.loader words.symbol ;
QUALIFIED: math
IN: alien.c-types

SYMBOLS:
    char uchar
    short ushort
    int uint
    long ulong
    longlong ulonglong
    float double
    void* bool
    void ;

DEFER: <int>
DEFER: *char

: little-endian? ( -- ? ) 1 <int> *char 1 = ; foldable

TUPLE: abstract-c-type
{ class class initial: object }
{ boxed-class class initial: object }
{ boxer-quot callable }
{ unboxer-quot callable }
{ getter callable }
{ setter callable }
size
align ;

TUPLE: c-type < abstract-c-type
boxer
unboxer
{ rep initial: int-rep }
stack-align? ;

: <c-type> ( -- type )
    \ c-type new ;

SYMBOL: c-types

global [
    c-types [ H{ } assoc-like ] change
] bind

ERROR: no-c-type name ;

PREDICATE: c-type-word < word
    "c-type" word-prop ;

UNION: c-type-name string c-type-word ;

! C type protocol
GENERIC: c-type ( name -- type ) foldable

GENERIC: resolve-pointer-type ( name -- c-type )

M: word resolve-pointer-type
    dup "pointer-c-type" word-prop
    [ ] [ drop void* ] ?if ;
M: string resolve-pointer-type
    c-types get at dup c-type-name?
    [ resolve-pointer-type ] [ drop void* ] if ;

: resolve-typedef ( name -- type )
    dup c-type-name? [ c-type ] when ;

: parse-array-type ( name -- dims type )
    "[" split unclip
    [ [ "]" ?tail drop string>number ] map ] dip ;

M: string c-type ( name -- type )
    CHAR: ] over member? [
        parse-array-type prefix
    ] [
        dup c-types get at [ ] [
            "*" ?tail [ resolve-pointer-type ] [ no-c-type ] if
        ] ?if resolve-typedef
    ] if ;

M: word c-type
    "c-type" word-prop resolve-typedef ;

: void? ( c-type -- ? )
    { void "void" } member? ;

GENERIC: c-struct? ( type -- ? )

M: object c-struct?
    drop f ;
M: c-type-name c-struct?
    dup void? [ drop f ] [ c-type c-struct? ] if ;

! These words being foldable means that words need to be
! recompiled if a C type is redefined. Even so, folding the
! size facilitates some optimizations.
GENERIC: heap-size ( type -- size ) foldable

M: c-type-name heap-size c-type heap-size ;

M: abstract-c-type heap-size size>> ;

GENERIC: require-c-array ( c-type -- )

M: array require-c-array first require-c-array ;

GENERIC: c-array-constructor ( c-type -- word )

GENERIC: c-(array)-constructor ( c-type -- word )

GENERIC: c-direct-array-constructor ( c-type -- word )

GENERIC: <c-array> ( len c-type -- array )

M: c-type-name <c-array>
    c-array-constructor execute( len -- array ) ; inline

GENERIC: (c-array) ( len c-type -- array )

M: c-type-name (c-array)
    c-(array)-constructor execute( len -- array ) ; inline

GENERIC: <c-direct-array> ( alien len c-type -- array )

M: c-type-name <c-direct-array>
    c-direct-array-constructor execute( alien len -- array ) ; inline

: malloc-array ( n type -- alien )
    [ heap-size calloc ] [ <c-direct-array> ] 2bi ; inline

: (malloc-array) ( n type -- alien )
    [ heap-size * malloc ] [ <c-direct-array> ] 2bi ; inline

GENERIC: c-type-class ( name -- class )

M: abstract-c-type c-type-class class>> ;

M: c-type-name c-type-class c-type c-type-class ;

GENERIC: c-type-boxed-class ( name -- class )

M: abstract-c-type c-type-boxed-class boxed-class>> ;

M: c-type-name c-type-boxed-class c-type c-type-boxed-class ;

GENERIC: c-type-boxer ( name -- boxer )

M: c-type c-type-boxer boxer>> ;

M: c-type-name c-type-boxer c-type c-type-boxer ;

GENERIC: c-type-boxer-quot ( name -- quot )

M: abstract-c-type c-type-boxer-quot boxer-quot>> ;

M: c-type-name c-type-boxer-quot c-type c-type-boxer-quot ;

GENERIC: c-type-unboxer ( name -- boxer )

M: c-type c-type-unboxer unboxer>> ;

M: c-type-name c-type-unboxer c-type c-type-unboxer ;

GENERIC: c-type-unboxer-quot ( name -- quot )

M: abstract-c-type c-type-unboxer-quot unboxer-quot>> ;

M: c-type-name c-type-unboxer-quot c-type c-type-unboxer-quot ;

GENERIC: c-type-rep ( name -- rep )

M: c-type c-type-rep rep>> ;

M: c-type-name c-type-rep c-type c-type-rep ;

GENERIC: c-type-getter ( name -- quot )

M: c-type c-type-getter getter>> ;

M: c-type-name c-type-getter c-type c-type-getter ;

GENERIC: c-type-setter ( name -- quot )

M: c-type c-type-setter setter>> ;

M: c-type-name c-type-setter c-type c-type-setter ;

GENERIC: c-type-align ( name -- n )

M: abstract-c-type c-type-align align>> ;

M: c-type-name c-type-align c-type c-type-align ;

GENERIC: c-type-stack-align? ( name -- ? )

M: c-type c-type-stack-align? stack-align?>> ;

M: c-type-name c-type-stack-align? c-type c-type-stack-align? ;

: c-type-box ( n type -- )
    [ c-type-rep ] [ c-type-boxer [ "No boxer" throw ] unless* ] bi
    %box ;

: c-type-unbox ( n ctype -- )
    [ c-type-rep ] [ c-type-unboxer [ "No unboxer" throw ] unless* ] bi
    %unbox ;

GENERIC: box-parameter ( n ctype -- )

M: c-type box-parameter c-type-box ;

M: c-type-name box-parameter c-type box-parameter ;

GENERIC: box-return ( ctype -- )

M: c-type box-return f swap c-type-box ;

M: c-type-name box-return c-type box-return ;

GENERIC: unbox-parameter ( n ctype -- )

M: c-type unbox-parameter c-type-unbox ;

M: c-type-name unbox-parameter c-type unbox-parameter ;

GENERIC: unbox-return ( ctype -- )

M: c-type unbox-return f swap c-type-unbox ;

M: c-type-name unbox-return c-type unbox-return ;

GENERIC: stack-size ( type -- size ) foldable

M: c-type-name stack-size c-type stack-size ;

M: c-type stack-size size>> cell align ;

MIXIN: value-type

M: value-type c-type-rep drop int-rep ;

M: value-type c-type-getter
    drop [ swap <displaced-alien> ] ;

M: value-type c-type-setter ( type -- quot )
    [ c-type-getter ] [ c-type-unboxer-quot ] [ heap-size ] tri
    '[ @ swap @ _ memcpy ] ;

GENERIC: byte-length ( seq -- n ) flushable

M: byte-array byte-length length ; inline

M: f byte-length drop 0 ; inline

: c-getter ( name -- quot )
    c-type-getter [
        [ "Cannot read struct fields with this type" throw ]
    ] unless* ;

: c-type-getter-boxer ( name -- quot )
    [ c-getter ] [ c-type-boxer-quot ] bi append ;

: c-setter ( name -- quot )
    c-type-setter [
        [ "Cannot write struct fields with this type" throw ]
    ] unless* ;

: <c-object> ( type -- array )
    heap-size <byte-array> ; inline

: (c-object) ( type -- array )
    heap-size (byte-array) ; inline

: malloc-object ( type -- alien )
    1 swap heap-size calloc ; inline

: (malloc-object) ( type -- alien )
    heap-size malloc ; inline

: malloc-byte-array ( byte-array -- alien )
    dup byte-length [ nip malloc dup ] 2keep memcpy ;

: memory>byte-array ( alien len -- byte-array )
    [ nip (byte-array) dup ] 2keep memcpy ;

: malloc-string ( string encoding -- alien )
    string>alien malloc-byte-array ;

M: memory-stream stream-read
    [
        [ index>> ] [ alien>> ] bi <displaced-alien>
        swap memory>byte-array
    ] [ [ + ] change-index drop ] 2bi ;

: byte-array>memory ( byte-array base -- )
    swap dup byte-length memcpy ; inline

: array-accessor ( type quot -- def )
    [
        \ swap , [ heap-size , [ * >fixnum ] % ] [ % ] bi*
    ] [ ] make ;

GENERIC: typedef ( old new -- )

PREDICATE: typedef-word < c-type-word
    "c-type" word-prop c-type-name? ;

M: string typedef ( old new -- ) c-types get set-at ;
M: word typedef ( old new -- )
    {
        [ nip define-symbol ]
        [ name>> typedef ]
        [ swap "c-type" set-word-prop ]
        [
            swap dup c-type-name? [
                resolve-pointer-type
                "pointer-c-type" set-word-prop
            ] [ 2drop ] if
        ]
    } 2cleave ;

TUPLE: long-long-type < c-type ;

: <long-long-type> ( -- type )
    long-long-type new ;

M: long-long-type unbox-parameter ( n type -- )
    c-type-unboxer %unbox-long-long ;

M: long-long-type unbox-return ( type -- )
    f swap unbox-parameter ;

M: long-long-type box-parameter ( n type -- )
    c-type-boxer %box-long-long ;

M: long-long-type box-return ( type -- )
    f swap box-parameter ;

: define-deref ( name -- )
    [ CHAR: * prefix "alien.c-types" create ] [ c-getter 0 prefix ] bi
    (( c-ptr -- value )) define-inline ;

: define-out ( name -- )
    [ "alien.c-types" constructor-word ]
    [ dup c-setter '[ _ <c-object> [ 0 @ ] keep ] ] bi
    (( value -- c-ptr )) define-inline ;

: >c-bool ( ? -- int ) 1 0 ? ; inline

: c-bool> ( int -- ? ) 0 = not ; inline

: define-primitive-type ( type name -- )
    [ typedef ]
    [ name>> define-deref ]
    [ name>> define-out ]
    tri ;

: malloc-file-contents ( path -- alien len )
    binary file-contents [ malloc-byte-array ] [ length ] bi ;

: if-void ( type true false -- )
    pick void? [ drop nip call ] [ nip call ] if ; inline

CONSTANT: primitive-types
    {
        char uchar
        short ushort
        int uint
        long ulong
        longlong ulonglong
        float double
        void* bool
    }

SYMBOLS:
    ptrdiff_t intptr_t size_t
    char* uchar* ;

[
    <c-type>
        c-ptr >>class
        c-ptr >>boxed-class
        [ alien-cell ] >>getter
        [ [ >c-ptr ] 2dip set-alien-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        [ >c-ptr ] >>unboxer-quot
        "box_alien" >>boxer
        "alien_offset" >>unboxer
    \ void* define-primitive-type

    <long-long-type>
        integer >>class
        integer >>boxed-class
        [ alien-signed-8 ] >>getter
        [ set-alien-signed-8 ] >>setter
        8 >>size
        8 >>align
        "box_signed_8" >>boxer
        "to_signed_8" >>unboxer
    \ longlong define-primitive-type

    <long-long-type>
        integer >>class
        integer >>boxed-class
        [ alien-unsigned-8 ] >>getter
        [ set-alien-unsigned-8 ] >>setter
        8 >>size
        8 >>align
        "box_unsigned_8" >>boxer
        "to_unsigned_8" >>unboxer
    \ ulonglong define-primitive-type

    <c-type>
        integer >>class
        integer >>boxed-class
        [ alien-signed-cell ] >>getter
        [ set-alien-signed-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_signed_cell" >>boxer
        "to_fixnum" >>unboxer
    \ long define-primitive-type

    <c-type>
        integer >>class
        integer >>boxed-class
        [ alien-unsigned-cell ] >>getter
        [ set-alien-unsigned-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_unsigned_cell" >>boxer
        "to_cell" >>unboxer
    \ ulong define-primitive-type

    <c-type>
        integer >>class
        integer >>boxed-class
        [ alien-signed-4 ] >>getter
        [ set-alien-signed-4 ] >>setter
        4 >>size
        4 >>align
        "box_signed_4" >>boxer
        "to_fixnum" >>unboxer
    \ int define-primitive-type

    <c-type>
        integer >>class
        integer >>boxed-class
        [ alien-unsigned-4 ] >>getter
        [ set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_unsigned_4" >>boxer
        "to_cell" >>unboxer
    \ uint define-primitive-type

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-signed-2 ] >>getter
        [ set-alien-signed-2 ] >>setter
        2 >>size
        2 >>align
        "box_signed_2" >>boxer
        "to_fixnum" >>unboxer
    \ short define-primitive-type

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        2 >>size
        2 >>align
        "box_unsigned_2" >>boxer
        "to_cell" >>unboxer
    \ ushort define-primitive-type

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-signed-1 ] >>getter
        [ set-alien-signed-1 ] >>setter
        1 >>size
        1 >>align
        "box_signed_1" >>boxer
        "to_fixnum" >>unboxer
    \ char define-primitive-type

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-unsigned-1 ] >>getter
        [ set-alien-unsigned-1 ] >>setter
        1 >>size
        1 >>align
        "box_unsigned_1" >>boxer
        "to_cell" >>unboxer
    \ uchar define-primitive-type

    <c-type>
        [ alien-unsigned-1 c-bool> ] >>getter
        [ [ >c-bool ] 2dip set-alien-unsigned-1 ] >>setter
        1 >>size
        1 >>align
        "box_boolean" >>boxer
        "to_boolean" >>unboxer
    \ bool define-primitive-type

    <c-type>
        math:float >>class
        math:float >>boxed-class
        [ alien-float ] >>getter
        [ [ >float ] 2dip set-alien-float ] >>setter
        4 >>size
        4 >>align
        "box_float" >>boxer
        "to_float" >>unboxer
        float-rep >>rep
        [ >float ] >>unboxer-quot
    \ float define-primitive-type

    <c-type>
        math:float >>class
        math:float >>boxed-class
        [ alien-double ] >>getter
        [ [ >float ] 2dip set-alien-double ] >>setter
        8 >>size
        8 >>align
        "box_double" >>boxer
        "to_double" >>unboxer
        double-rep >>rep
        [ >float ] >>unboxer-quot
    \ double define-primitive-type

    \ long \ ptrdiff_t typedef
    \ long \ intptr_t typedef
    \ ulong \ size_t typedef
] with-compilation-unit

