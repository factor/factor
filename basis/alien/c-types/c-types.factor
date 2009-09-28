! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays arrays assocs kernel kernel.private math
math.order math.parser namespaces make parser sequences strings
words splitting cpu.architecture alien alien.accessors
alien.strings quotations layouts system compiler.units io
io.files io.encodings.binary io.streams.memory accessors
combinators effects continuations fry classes vocabs
vocabs.loader words.symbol ;
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

: <c-type> ( -- c-type )
    \ c-type new ; inline

SYMBOL: c-types

global [
    c-types [ H{ } assoc-like ] change
] bind

ERROR: no-c-type name ;

PREDICATE: c-type-word < word
    "c-type" word-prop ;

UNION: c-type-name string word ;

! C type protocol
GENERIC: c-type ( name -- c-type ) foldable

GENERIC: resolve-pointer-type ( name -- c-type )

<< \ void \ void* "pointer-c-type" set-word-prop >>

M: word resolve-pointer-type
    dup "pointer-c-type" word-prop
    [ ] [ drop void* ] ?if ;

M: string resolve-pointer-type
    dup "*" append dup c-types get at
    [ nip ] [
        drop
        c-types get at dup c-type-name?
        [ resolve-pointer-type ] [ drop void* ] if
    ] if ;

: resolve-typedef ( name -- c-type )
    dup c-type-name? [ c-type ] when ;

: parse-array-type ( name -- dims c-type )
    "[" split unclip
    [ [ "]" ?tail drop string>number ] map ] dip ;

M: string c-type ( name -- c-type )
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

GENERIC: c-struct? ( c-type -- ? )

M: object c-struct?
    drop f ;
M: c-type-name c-struct?
    dup void? [ drop f ] [ c-type c-struct? ] if ;

! These words being foldable means that words need to be
! recompiled if a C type is redefined. Even so, folding the
! size facilitates some optimizations.
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

: c-type-box ( n c-type -- )
    [ c-type-rep ] [ c-type-boxer [ "No boxer" throw ] unless* ] bi
    %box ;

: c-type-unbox ( n c-type -- )
    [ c-type-rep ] [ c-type-unboxer [ "No unboxer" throw ] unless* ] bi
    %unbox ;

GENERIC: box-parameter ( n c-type -- )

M: c-type box-parameter c-type-box ;

M: c-type-name box-parameter c-type box-parameter ;

GENERIC: box-return ( c-type -- )

M: c-type box-return f swap c-type-box ;

M: c-type-name box-return c-type box-return ;

GENERIC: unbox-parameter ( n c-type -- )

M: c-type unbox-parameter c-type-unbox ;

M: c-type-name unbox-parameter c-type unbox-parameter ;

GENERIC: unbox-return ( c-type -- )

M: c-type unbox-return f swap c-type-unbox ;

M: c-type-name unbox-return c-type unbox-return ;

: little-endian? ( -- ? ) 1 <int> *char 1 = ; foldable

GENERIC: heap-size ( name -- size ) foldable

M: c-type-name heap-size c-type heap-size ;

M: abstract-c-type heap-size size>> ;

GENERIC: stack-size ( name -- size ) foldable

M: c-type-name stack-size c-type stack-size ;

M: c-type stack-size size>> cell align ;

GENERIC: byte-length ( seq -- n ) flushable

M: byte-array byte-length length ; inline

M: f byte-length drop 0 ; inline

MIXIN: value-type

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

: array-accessor ( c-type quot -- def )
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

: <long-long-type> ( -- c-type )
    long-long-type new ;

M: long-long-type unbox-parameter ( n c-type -- )
    c-type-unboxer %unbox-long-long ;

M: long-long-type unbox-return ( c-type -- )
    f swap unbox-parameter ;

M: long-long-type box-parameter ( n c-type -- )
    c-type-boxer %box-long-long ;

M: long-long-type box-return ( c-type -- )
    f swap box-parameter ;

: define-deref ( name -- )
    [ CHAR: * prefix "alien.c-types" create ] [ c-getter 0 prefix ] bi
    (( c-ptr -- value )) define-inline ;

: define-out ( name -- )
    [ "alien.c-types" constructor-word ]
    [ dup c-setter '[ _ heap-size <byte-array> [ 0 @ ] keep ] ] bi
    (( value -- c-ptr )) define-inline ;

: define-primitive-type ( c-type name -- )
    [ typedef ]
    [ name>> define-deref ]
    [ name>> define-out ]
    tri ;

: if-void ( c-type true false -- )
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
        [ alien-unsigned-1 0 = not ] >>getter
        [ [ 1 0 ? ] 2dip set-alien-unsigned-1 ] >>setter
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

M: char-16-rep rep-component-type drop char ;
M: uchar-16-rep rep-component-type drop uchar ;
M: short-8-rep rep-component-type drop short ;
M: ushort-8-rep rep-component-type drop ushort ;
M: int-4-rep rep-component-type drop int ;
M: uint-4-rep rep-component-type drop uint ;
M: longlong-2-rep rep-component-type drop longlong ;
M: ulonglong-2-rep rep-component-type drop ulonglong ;
M: float-4-rep rep-component-type drop float ;
M: double-2-rep rep-component-type drop double ;

: (unsigned-interval) ( bytes -- from to ) [ 0 ] dip 8 * 2^ 1 - ; foldable
: unsigned-interval ( c-type -- from to ) heap-size (unsigned-interval) ; foldable
: (signed-interval) ( bytes -- from to ) 8 * 1 - 2^ [ neg ] [ 1 - ] bi ; foldable
: signed-interval ( c-type -- from to ) heap-size (signed-interval) ; foldable

: c-type-interval ( c-type -- from to )
    {
        { [ dup { float double } memq? ] [ drop -1/0. 1/0. ] }
        { [ dup { char short int long longlong } memq? ] [ signed-interval ] }
        { [ dup { uchar ushort uint ulong ulonglong } memq? ] [ unsigned-interval ] }
    } cond ; foldable

: c-type-clamp ( value c-type -- value' ) c-type-interval clamp ; inline
