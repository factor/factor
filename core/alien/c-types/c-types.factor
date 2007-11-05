! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays arrays generator.registers assocs
kernel kernel.private libc math namespaces parser sequences
strings words assocs splitting math.parser cpu.architecture
alien quotations system ;
IN: alien.c-types

TUPLE: c-type
boxer prep unboxer
getter setter
reg-class size align stack-align? ;

: <c-type> ( -- type )
    T{ int-regs } { set-c-type-reg-class } \ c-type construct ;

SYMBOL: c-types

global [
    c-types [ H{ } assoc-like ] change
] bind

TUPLE: no-c-type name ;

: no-c-type ( type -- * ) \ no-c-type construct-boa throw ;

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
    >r [ "]" ?tail drop string>number ] map r> add* ;

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

: malloc-char-string ( string -- alien )
    string>char-alien malloc-byte-array ;

: malloc-u16-string ( string -- alien )
    string>u16-alien malloc-byte-array ;

: (define-nth) ( word type quot -- )
    >r heap-size [ rot * ] swap add* r> append define-inline ;

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

TUPLE: long-long-type ;

: <long-long-type> ( type -- type )
    long-long-type construct-delegate ;

M: long-long-type unbox-parameter ( n type -- )
    c-type-unboxer %unbox-long-long ;

M: long-long-type unbox-return ( type -- )
    f swap unbox-parameter ;

M: long-long-type box-parameter ( n type -- )
    c-type-boxer %box-long-long ;

M: long-long-type box-return ( type -- )
    f swap box-parameter ;

: define-deref ( name vocab -- )
    >r dup CHAR: * add* r> create
    swap c-getter 0 add* define-inline ;

: define-out ( name vocab -- )
    over [ <c-object> tuck 0 ] over c-setter append swap
    >r >r constructor-word r> r> add* define-inline ;

: >c-array ( seq type word -- )
    >r >r dup length dup r> <c-array> dup -roll r>
    [ execute ] 2curry 2each ; inline

: >c-array-quot ( type vocab -- quot )
    dupd set-nth-word [ >c-array ] 2curry ;

: to-array-word ( name vocab -- word )
    >r ">c-" swap "-array" 3append r> create ;

: define-to-array ( type vocab -- )
    [ to-array-word ] 2keep >c-array-quot define-compound ;

: c-array>quot ( type vocab -- quot )
    [
        \ swap ,
        nth-word 1quotation ,
        [ curry map ] %
    ] [ ] make ;

: from-array-word ( name vocab -- word )
    >r "c-" swap "-array>" 3append r> create ;

: define-from-array ( type vocab -- )
    [ from-array-word ] 2keep c-array>quot define-compound ;

: <primitive-type> ( getter setter width boxer unboxer -- type )
    <c-type>
    [ set-c-type-unboxer ] keep
    [ set-c-type-boxer ] keep
    [ set-c-type-size ] 2keep
    [ set-c-type-align ] keep
    [ set-c-type-setter ] keep
    [ set-c-type-getter ] keep ;

: define-primitive-type ( type name -- )
    "alien.c-types"
    [ define-c-type ] 2keep
    [ define-deref ] 2keep
    [ define-to-array ] 2keep
    [ define-from-array ] 2keep
    define-out ;

: expand-constants ( c-type -- c-type' )
    dup array? [
        unclip >r [ dup word? [ execute ] when ] map r> add*
    ] when ;

[ alien-cell ]
[ set-alien-cell ]
bootstrap-cell
"box_alien"
"alien_offset" <primitive-type>
"void*" define-primitive-type

[ alien-signed-8 ]
[ set-alien-signed-8 ]
8
"box_signed_8"
"to_signed_8" <primitive-type> <long-long-type>
"longlong" define-primitive-type

[ alien-unsigned-8 ]
[ set-alien-unsigned-8 ]
8
"box_unsigned_8"
"to_unsigned_8" <primitive-type> <long-long-type>
"ulonglong" define-primitive-type

[ alien-signed-cell ]
[ set-alien-signed-cell ]
bootstrap-cell
"box_signed_cell"
"to_fixnum" <primitive-type>
"long" define-primitive-type

[ alien-unsigned-cell ]
[ set-alien-unsigned-cell ]
bootstrap-cell
"box_unsigned_cell"
"to_cell" <primitive-type>
"ulong" define-primitive-type

[ alien-signed-4 ]
[ set-alien-signed-4 ]
4
"box_signed_4"
"to_fixnum" <primitive-type>
"int" define-primitive-type

[ alien-unsigned-4 ]
[ set-alien-unsigned-4 ]
4
"box_unsigned_4"
"to_cell" <primitive-type>
"uint" define-primitive-type

[ alien-signed-2 ]
[ set-alien-signed-2 ]
2
"box_signed_2"
"to_fixnum" <primitive-type>
"short" define-primitive-type

[ alien-unsigned-2 ]
[ set-alien-unsigned-2 ]
2
"box_unsigned_2"
"to_cell" <primitive-type>
"ushort" define-primitive-type

[ alien-signed-1 ]
[ set-alien-signed-1 ]
1
"box_signed_1"
"to_fixnum" <primitive-type>
"char" define-primitive-type

[ alien-unsigned-1 ]
[ set-alien-unsigned-1 ]
1
"box_unsigned_1"
"to_cell" <primitive-type>
"uchar" define-primitive-type

[ alien-unsigned-4 zero? not ]
[ 1 0 ? set-alien-unsigned-4 ]
4
"box_boolean"
"to_boolean" <primitive-type>
"bool" define-primitive-type

[ alien-float ]
[ >r >r >float r> r> set-alien-float ]
4
"box_float"
"to_float" <primitive-type>
"float" define-primitive-type

T{ float-regs f 4 } "float" c-type set-c-type-reg-class
[ >float ] "float" c-type set-c-type-prep

[ alien-double ]
[ >r >r >float r> r> set-alien-double ]
8
"box_double"
"to_double" <primitive-type>
"double" define-primitive-type

T{ float-regs f 8 } "double" c-type set-c-type-reg-class
[ >float ] "double" c-type set-c-type-prep

[ alien-cell alien>char-string ]
[ set-alien-cell ]
bootstrap-cell
"box_char_string"
"alien_offset" <primitive-type>
"char*" define-primitive-type

"char*" "uchar*" typedef

[ string>char-alien ] "char*" c-type set-c-type-prep

[ alien-cell alien>u16-string ]
[ set-alien-cell ]
4
"box_u16_string"
"alien_offset" <primitive-type>
"ushort*" define-primitive-type

[ string>u16-alien ] "ushort*" c-type set-c-type-prep
