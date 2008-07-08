! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays arrays assocs kernel kernel.private libc math
namespaces parser sequences strings words assocs splitting
math.parser cpu.architecture alien alien.accessors quotations
layouts system compiler.units io.files io.encodings.binary
accessors combinators effects ;
IN: alien.c-types

DEFER: <int>
DEFER: *char

: little-endian? ( -- ? ) 1 <int> *char 1 = ; foldable

TUPLE: c-type
boxer boxer-quot unboxer unboxer-quot
getter setter
reg-class size align stack-align? ;

: new-c-type ( class -- type )
    new
        int-regs >>reg-class ;

: <c-type> ( -- type )
    \ c-type new-c-type ;

SYMBOL: c-types

global [
    c-types [ H{ } assoc-like ] change
] bind

ERROR: no-c-type name ;

: (c-type) ( name -- type/f )
    c-types get-global at dup [
        dup string? [ (c-type) ] when
    ] when ;

GENERIC: c-type ( name -- type ) foldable

: resolve-pointer-type ( name -- name )
    c-types get at dup string?
    [ "*" append ] [ drop "void*" ] if
    c-type ;

: resolve-typedef ( name -- type )
    dup string? [ c-type ] when ;

: parse-array-type ( name -- array )
    "[" split unclip
    >r [ "]" ?tail drop string>number ] map r> prefix ;

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

: c-type-box ( n type -- )
    dup c-type-reg-class
    swap c-type-boxer [ "No boxer" throw ] unless*
    %box ;

: c-type-unbox ( n ctype -- )
    dup c-type-reg-class
    swap c-type-unboxer [ "No unboxer" throw ] unless*
    %unbox ;

M: string c-type-align c-type c-type-align ;

M: string c-type-stack-align? c-type c-type-stack-align? ;

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

M: c-type heap-size c-type-size ;

GENERIC: stack-size ( type -- size ) foldable

M: string stack-size c-type stack-size ;

M: c-type stack-size c-type-size ;

GENERIC: byte-length ( seq -- n ) flushable

M: byte-array byte-length length ;

: c-getter ( name -- quot )
    c-type c-type-getter [
        [ "Cannot read struct fields with type" throw ]
    ] unless* ;

: c-setter ( name -- quot )
    c-type c-type-setter [
        [ "Cannot write struct fields with type" throw ]
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
    dup length dup malloc [ -rot memcpy ] keep ;

: memory>byte-array ( alien len -- byte-array )
    dup <byte-array> [ -rot memcpy ] keep ;

: byte-array>memory ( byte-array base -- )
    swap dup length memcpy ;

: (define-nth) ( word type quot -- )
    >r heap-size [ rot * ] swap prefix r> append define-inline ;

: nth-word ( name vocab -- word )
    >r "-nth" append r> create ;

: define-nth ( name vocab -- )
    dupd nth-word swap dup c-getter (define-nth) ;

: set-nth-word ( name vocab -- word )
    >r "set-" swap "-nth" 3append r> create ;

: define-set-nth ( name vocab -- )
    dupd set-nth-word swap dup c-setter (define-nth) ;

: typedef ( old new -- ) c-types get set-at ;

: define-c-type ( type name vocab -- )
    >r tuck typedef r> [ define-nth ] 2keep define-set-nth ;

TUPLE: long-long-type < c-type ;

: <long-long-type> ( -- type )
    long-long-type new-c-type ;

M: long-long-type unbox-parameter ( n type -- )
    c-type-unboxer %unbox-long-long ;

M: long-long-type unbox-return ( type -- )
    f swap unbox-parameter ;

M: long-long-type box-parameter ( n type -- )
    c-type-boxer %box-long-long ;

M: long-long-type box-return ( type -- )
    f swap box-parameter ;

: define-deref ( name vocab -- )
    >r dup CHAR: * prefix r> create
    swap c-getter 0 prefix define-inline ;

: define-out ( name vocab -- )
    over [ <c-object> tuck 0 ] over c-setter append swap
    >r >r constructor-word r> r> prefix define-inline ;

: c-bool> ( int -- ? )
    zero? not ;

: >c-array ( seq type word -- )
    [ [ dup length ] dip <c-array> ] dip
    [ [ execute ] 2curry each-index ] 2keep drop ; inline

: >c-array-quot ( type vocab -- quot )
    dupd set-nth-word [ >c-array ] 2curry ;

: to-array-word ( name vocab -- word )
    >r ">c-" swap "-array" 3append r> create ;

: define-to-array ( type vocab -- )
    [ to-array-word ] 2keep >c-array-quot
    (( array -- byte-array )) define-declared ;

: c-array>quot ( type vocab -- quot )
    [
        \ swap ,
        nth-word 1quotation ,
        [ curry map ] %
    ] [ ] make ;

: from-array-word ( name vocab -- word )
    >r "c-" swap "-array>" 3append r> create ;

: define-from-array ( type vocab -- )
    [ from-array-word ] 2keep c-array>quot
    (( c-ptr n -- array )) define-declared ;

: define-primitive-type ( type name -- )
    "alien.c-types"
    {
        [ define-c-type ]
        [ define-deref ]
        [ define-to-array ]
        [ define-from-array ]
        [ define-out ]
    } 2cleave ;

: expand-constants ( c-type -- c-type' )
    #! We use def>> call instead of execute to get around
    #! staging violations
    dup array? [
        unclip >r [ dup word? [ def>> call ] when ] map r> prefix
    ] when ;

: malloc-file-contents ( path -- alien len )
    binary file-contents dup malloc-byte-array swap length ;

[
    <c-type>
        [ alien-cell ] >>getter
        [ set-alien-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_alien" >>boxer
        "alien_offset" >>unboxer
    "void*" define-primitive-type

    <long-long-type>
        [ alien-signed-8 ] >>getter
        [ set-alien-signed-8 ] >>setter
        8 >>size
        8 >>align
        "box_signed_8" >>boxer
        "to_signed_8" >>unboxer
    "longlong" define-primitive-type

    <long-long-type>
        [ alien-unsigned-8 ] >>getter
        [ set-alien-unsigned-8 ] >>setter
        8 >>size
        8 >>align
        "box_unsigned_8" >>boxer
        "to_unsigned_8" >>unboxer
    "ulonglong" define-primitive-type

    <c-type>
        [ alien-signed-cell ] >>getter
        [ set-alien-signed-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_signed_cell" >>boxer
        "to_fixnum" >>unboxer
    "long" define-primitive-type

    <c-type>
        [ alien-unsigned-cell ] >>getter
        [ set-alien-unsigned-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        "box_unsigned_cell" >>boxer
        "to_cell" >>unboxer
    "ulong" define-primitive-type

    <c-type>
        [ alien-signed-4 ] >>getter
        [ set-alien-signed-4 ] >>setter
        4 >>size
        4 >>align
        "box_signed_4" >>boxer
        "to_fixnum" >>unboxer
    "int" define-primitive-type

    <c-type>
        [ alien-unsigned-4 ] >>getter
        [ set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_unsigned_4" >>boxer
        "to_cell" >>unboxer
    "uint" define-primitive-type

    <c-type>
        [ alien-signed-2 ] >>getter
        [ set-alien-signed-2 ] >>setter
        2 >>size
        2 >>align
        "box_signed_2" >>boxer
        "to_fixnum" >>unboxer
    "short" define-primitive-type

    <c-type>
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        2 >>size
        2 >>align
        "box_unsigned_2" >>boxer
        "to_cell" >>unboxer
    "ushort" define-primitive-type

    <c-type>
        [ alien-signed-1 ] >>getter
        [ set-alien-signed-1 ] >>setter
        1 >>size
        1 >>align
        "box_signed_1" >>boxer
        "to_fixnum" >>unboxer
    "char" define-primitive-type

    <c-type>
        [ alien-unsigned-1 ] >>getter
        [ set-alien-unsigned-1 ] >>setter
        1 >>size
        1 >>align
        "box_unsigned_1" >>boxer
        "to_cell" >>unboxer
    "uchar" define-primitive-type

    <c-type>
        [ alien-unsigned-4 zero? not ] >>getter
        [ 1 0 ? set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_boolean" >>boxer
        "to_boolean" >>unboxer
    "bool" define-primitive-type

    <c-type>
        [ alien-float ] >>getter
        [ >r >r >float r> r> set-alien-float ] >>setter
        4 >>size
        4 >>align
        "box_float" >>boxer
        "to_float" >>unboxer
        single-float-regs >>reg-class
        [ >float ] >>unboxer-quot
    "float" define-primitive-type

    <c-type>
        [ alien-double ] >>getter
        [ >r >r >float r> r> set-alien-double ] >>setter
        8 >>size
        8 >>align
        "box_double" >>boxer
        "to_double" >>unboxer
        double-float-regs >>reg-class
        [ >float ] >>unboxer-quot
    "double" define-primitive-type

    os winnt? cpu x86.64? and "longlong" "long" ? "ptrdiff_t" typedef

    "ulong" "size_t" typedef
] with-compilation-unit
