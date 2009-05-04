! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays arrays assocs kernel kernel.private libc math
namespaces make parser sequences strings words assocs splitting
math.parser cpu.architecture alien alien.accessors alien.strings
quotations layouts system compiler.units io io.files
io.encodings.binary io.streams.memory accessors combinators effects
continuations fry classes ;
IN: alien.c-types

DEFER: <int>
DEFER: *char

: little-endian? ( -- ? ) 1 <int> *char 1 = ; foldable

TUPLE: c-type
{ class class initial: object }
boxer
{ boxer-quot callable }
unboxer
{ unboxer-quot callable }
{ getter callable }
{ setter callable }
{ reg-class initial: int-regs }
size
align
stack-align? ;

: <c-type> ( -- type )
    \ c-type new ;

SYMBOL: c-types

global [
    c-types [ H{ } assoc-like ] change
] bind

ERROR: no-c-type name ;

: (c-type) ( name -- type/f )
    c-types get-global at dup [
        dup string? [ (c-type) ] when
    ] when ;

! C type protocol
GENERIC: c-type ( name -- type ) foldable

: resolve-pointer-type ( name -- name )
    c-types get at dup string?
    [ "*" append ] [ drop "void*" ] if
    c-type ;

: resolve-typedef ( name -- type )
    dup string? [ c-type ] when ;

: parse-array-type ( name -- array )
    "[" split unclip
    [ [ "]" ?tail drop string>number ] map ] dip prefix ;

M: string c-type ( name -- type )
    CHAR: ] over member? [
        parse-array-type
    ] [
        dup c-types get at [
            resolve-typedef
        ] [
            "*" ?tail [ resolve-pointer-type ] [ no-c-type ] if
        ] ?if
    ] if ;

GENERIC: c-type-class ( name -- class )

M: c-type c-type-class class>> ;

M: string c-type-class c-type c-type-class ;

GENERIC: c-type-boxer ( name -- boxer )

M: c-type c-type-boxer boxer>> ;

M: string c-type-boxer c-type c-type-boxer ;

GENERIC: c-type-boxer-quot ( name -- quot )

M: c-type c-type-boxer-quot boxer-quot>> ;

M: string c-type-boxer-quot c-type c-type-boxer-quot ;

GENERIC: c-type-unboxer ( name -- boxer )

M: c-type c-type-unboxer unboxer>> ;

M: string c-type-unboxer c-type c-type-unboxer ;

GENERIC: c-type-unboxer-quot ( name -- quot )

M: c-type c-type-unboxer-quot unboxer-quot>> ;

M: string c-type-unboxer-quot c-type c-type-unboxer-quot ;

GENERIC: c-type-reg-class ( name -- reg-class )

M: c-type c-type-reg-class reg-class>> ;

M: string c-type-reg-class c-type c-type-reg-class ;

GENERIC: c-type-getter ( name -- quot )

M: c-type c-type-getter getter>> ;

M: string c-type-getter c-type c-type-getter ;

GENERIC: c-type-setter ( name -- quot )

M: c-type c-type-setter setter>> ;

M: string c-type-setter c-type c-type-setter ;

GENERIC: c-type-align ( name -- n )

M: c-type c-type-align align>> ;

M: string c-type-align c-type c-type-align ;

GENERIC: c-type-stack-align? ( name -- ? )

M: c-type c-type-stack-align? stack-align?>> ;

M: string c-type-stack-align? c-type c-type-stack-align? ;

: c-type-box ( n type -- )
    dup c-type-reg-class
    swap c-type-boxer [ "No boxer" throw ] unless*
    %box ;

: c-type-unbox ( n ctype -- )
    dup c-type-reg-class
    swap c-type-unboxer [ "No unboxer" throw ] unless*
    %unbox ;

GENERIC: box-parameter ( n ctype -- )

M: c-type box-parameter c-type-box ;

M: string box-parameter c-type box-parameter ;

GENERIC: box-return ( ctype -- )

M: c-type box-return f swap c-type-box ;

M: string box-return c-type box-return ;

GENERIC: unbox-parameter ( n ctype -- )

M: c-type unbox-parameter c-type-unbox ;

M: string unbox-parameter c-type unbox-parameter ;

GENERIC: unbox-return ( ctype -- )

M: c-type unbox-return f swap c-type-unbox ;

M: string unbox-return c-type unbox-return ;

! These words being foldable means that words need to be
! recompiled if a C type is redefined. Even so, folding the
! size facilitates some optimizations.
GENERIC: heap-size ( type -- size ) foldable

M: string heap-size c-type heap-size ;

M: c-type heap-size size>> ;

GENERIC: stack-size ( type -- size ) foldable

M: string stack-size c-type stack-size ;

M: c-type stack-size size>> cell align ;

GENERIC: byte-length ( seq -- n ) flushable

M: byte-array byte-length length ;

M: f byte-length drop 0 ;

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

: <c-array> ( n type -- array )
    heap-size * <byte-array> ; inline

: <c-object> ( type -- array )
    1 swap <c-array> ; inline

: malloc-array ( n type -- alien )
    heap-size calloc ; inline

: malloc-object ( type -- alien )
    1 swap malloc-array ; inline

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
    swap dup byte-length memcpy ;

: array-accessor ( type quot -- def )
    [
        \ swap , [ heap-size , [ * >fixnum ] % ] [ % ] bi*
    ] [ ] make ;

: typedef ( old new -- ) c-types get set-at ;

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

: c-bool> ( int -- ? )
    0 = not ; inline

: define-primitive-type ( type name -- )
    [ typedef ]
    [ define-deref ]
    [ define-out ]
    tri ;

: expand-constants ( c-type -- c-type' )
    dup array? [
        unclip [
            [
                dup word? [
                    def>> call( -- object )
                ] when
            ] map
        ] dip prefix
    ] when ;

: malloc-file-contents ( path -- alien len )
    binary file-contents [ malloc-byte-array ] [ length ] bi ;

: if-void ( type true false -- )
    pick "void" = [ drop nip call ] [ nip call ] if ; inline

CONSTANT: primitive-types
    {
        "char" "uchar"
        "short" "ushort"
        "int" "uint"
        "long" "ulong"
        "longlong" "ulonglong"
        "float" "double"
        "void*" "bool"
    }

[
    <c-type>
        c-ptr >>class
        [ alien-cell ] >>getter
        [ [ >c-ptr ] 2dip set-alien-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        [ >c-ptr ] >>unboxer-quot
        "box_alien" >>boxer
        "alien_offset" >>unboxer
    "void*" define-primitive-type

    <long-long-type>
        integer >>class
        [ alien-signed-8 ] >>getter
        [ set-alien-signed-8 ] >>setter
        8 >>size
        8 >>align
        "box_signed_8" >>boxer
        "to_signed_8" >>unboxer
    "longlong" define-primitive-type

    <long-long-type>
        integer >>class
        [ alien-unsigned-8 ] >>getter
        [ set-alien-unsigned-8 ] >>setter
        8 >>size
        8 >>align
        "box_unsigned_8" >>boxer
        "to_unsigned_8" >>unboxer
    "ulonglong" define-primitive-type

    <c-type>
        integer >>class
        [ alien-signed-cell ] >>getter
        [ set-alien-signed-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_signed_cell" >>boxer
        "to_fixnum" >>unboxer
    "long" define-primitive-type

    <c-type>
        integer >>class
        [ alien-unsigned-cell ] >>getter
        [ set-alien-unsigned-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_unsigned_cell" >>boxer
        "to_cell" >>unboxer
    "ulong" define-primitive-type

    <c-type>
        integer >>class
        [ alien-signed-4 ] >>getter
        [ set-alien-signed-4 ] >>setter
        4 >>size
        4 >>align
        "box_signed_4" >>boxer
        "to_fixnum" >>unboxer
    "int" define-primitive-type

    <c-type>
        integer >>class
        [ alien-unsigned-4 ] >>getter
        [ set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_unsigned_4" >>boxer
        "to_cell" >>unboxer
    "uint" define-primitive-type

    <c-type>
        fixnum >>class
        [ alien-signed-2 ] >>getter
        [ set-alien-signed-2 ] >>setter
        2 >>size
        2 >>align
        "box_signed_2" >>boxer
        "to_fixnum" >>unboxer
    "short" define-primitive-type

    <c-type>
        fixnum >>class
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        2 >>size
        2 >>align
        "box_unsigned_2" >>boxer
        "to_cell" >>unboxer
    "ushort" define-primitive-type

    <c-type>
        fixnum >>class
        [ alien-signed-1 ] >>getter
        [ set-alien-signed-1 ] >>setter
        1 >>size
        1 >>align
        "box_signed_1" >>boxer
        "to_fixnum" >>unboxer
    "char" define-primitive-type

    <c-type>
        fixnum >>class
        [ alien-unsigned-1 ] >>getter
        [ set-alien-unsigned-1 ] >>setter
        1 >>size
        1 >>align
        "box_unsigned_1" >>boxer
        "to_cell" >>unboxer
    "uchar" define-primitive-type

    <c-type>
        [ alien-unsigned-4 zero? not ] >>getter
        [ [ 1 0 ? ] 2dip set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_boolean" >>boxer
        "to_boolean" >>unboxer
    "bool" define-primitive-type

    <c-type>
        float >>class
        [ alien-float ] >>getter
        [ [ >float ] 2dip set-alien-float ] >>setter
        4 >>size
        4 >>align
        "box_float" >>boxer
        "to_float" >>unboxer
        single-float-regs >>reg-class
        [ >float ] >>unboxer-quot
    "float" define-primitive-type

    <c-type>
        float >>class
        [ alien-double ] >>getter
        [ [ >float ] 2dip set-alien-double ] >>setter
        8 >>size
        8 >>align
        "box_double" >>boxer
        "to_double" >>unboxer
        double-float-regs >>reg-class
        [ >float ] >>unboxer-quot
    "double" define-primitive-type

    "long" "ptrdiff_t" typedef
    "long" "intptr_t" typedef
    "ulong" "size_t" typedef
] with-compilation-unit
