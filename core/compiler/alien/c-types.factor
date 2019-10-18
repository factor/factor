! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: byte-arrays arrays generator errors generic assocs
kernel kernel-internals libc math namespaces parser sequences
strings words assocs ;

TUPLE: c-type
boxer prep unboxer
getter setter
reg-class size align stack-align? ;

C: c-type ( -- type ) T{ int-regs } over set-c-type-reg-class ;

SYMBOL: c-types

TUPLE: no-c-type name ;

: no-c-type ( type -- * ) <no-c-type> throw ;

: (c-type) ( name -- type/f )
    c-types get at dup [
        dup string? [ (c-type) ] when
    ] when ;

GENERIC: c-type ( name -- type )

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

GENERIC: heap-size ( type -- size )

M: string heap-size c-type heap-size ;

M: c-type heap-size ( name -- size ) c-type-size ;

GENERIC: stack-size ( name -- size )

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
    global [ heap-size * <byte-array> ] bind ;

: <c-object> ( type -- array ) 1 swap <c-array> ;

: malloc-array ( n type -- alien )
    global [ heap-size calloc ] bind check-ptr ;

: malloc-object ( type -- alien ) 1 swap malloc-array ;

: malloc-byte-array ( byte-array len -- alien )
    dup malloc check-ptr [ -rot memcpy ] keep ;

: malloc-char-string ( string -- alien )
    dup string>char-alien swap length 1+ malloc-byte-array ;

: malloc-u16-string ( string -- alien )
    dup string>u16-alien swap length 1 + 2 * malloc-byte-array ;

: define-deref ( name vocab -- )
    >r dup CHAR: * add* r> create
    swap c-getter 0 add* define-inline ;

: (define-nth) ( word type quot -- )
    >r heap-size [ rot * ] swap add* r> append define-inline ;

: define-nth ( name vocab -- )
    >r dup "-nth" append r> create
    swap dup c-getter (define-nth) ;

: define-set-nth ( name vocab -- )
    >r "set-" over "-nth" 3append r> create
    swap dup c-setter (define-nth) ;

: define-out ( name vocab -- )
    over [ <c-object> tuck 0 ] over c-setter append swap
    >r >r constructor-word r> r> add* define-compound ;

: <primitive-type> ( getter setter width boxer unboxer -- type )
    <c-type>
    [ set-c-type-unboxer ] keep
    [ set-c-type-boxer ] keep
    [ set-c-type-size ] 2keep
    [ set-c-type-align ] keep
    [ set-c-type-setter ] keep
    [ set-c-type-getter ] keep ;

: typedef ( old new -- ) c-types get set-at ;

: define-c-type ( type name vocab -- )
    >r tuck typedef r> [ define-nth ] 2keep define-set-nth ;

: define-primitive-type ( type name -- )
    "alien"
    [ define-c-type ] 2keep
    [ define-deref ] 2keep
    define-out ;

TUPLE: long-long-type ;

C: long-long-type ( type -- type ) [ set-delegate ] keep ;

M: long-long-type unbox-parameter ( n type -- )
    c-type-unboxer %unbox-long-long ;

M: long-long-type unbox-return ( type -- )
    f swap unbox-parameter ;

M: long-long-type box-parameter ( n type -- )
    c-type-boxer %box-long-long ;

M: long-long-type box-return ( type -- )
    f swap box-parameter ;
