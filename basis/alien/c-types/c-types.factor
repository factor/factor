! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors arrays classes
combinators combinators.short-circuit compiler.units
cpu.architecture delegate kernel layouts math math.order
math.parser quotations sequences summary system words
words.symbol ;
IN: alien.c-types

SYMBOLS:
    char uchar
    short ushort
    int uint
    long ulong
    longlong ulonglong
    float double
    void* bool ;

SINGLETON: void

TUPLE: abstract-c-type
    { class class initial: object }
    { boxed-class class initial: object }
    { boxer-quot callable }
    { unboxer-quot callable }
    { getter callable }
    { setter callable }
    { size integer }
    { signed boolean }
    { align integer }
    { align-first integer } ;

TUPLE: c-type < abstract-c-type
    boxer
    unboxer
    { rep initial: int-rep } ;

: <c-type> ( -- c-type )
    \ c-type new ; inline

ERROR: no-c-type word ;

M: no-c-type summary drop "Not a C type" ;

! C type protocol
GENERIC: lookup-c-type ( name -- c-type ) foldable

PREDICATE: c-type-word < word
    "c-type" word-prop >boolean ;

TUPLE: pointer { to initial: void read-only } ;
C: <pointer> pointer

UNION: c-type-name
    c-type-word pointer ;

: resolve-typedef ( name -- c-type )
    [ void? ] [ no-c-type ] 1when
    [ c-type-name? ] [ lookup-c-type ] 1when ;

M: word lookup-c-type
    [ "c-type" word-prop resolve-typedef ]
    [ no-c-type ] ?unless ;

GENERIC: c-type-class ( name -- class )

M: abstract-c-type c-type-class class>> ;

GENERIC: c-type-boxed-class ( name -- class )

M: abstract-c-type c-type-boxed-class boxed-class>> ;

GENERIC: c-type-boxer-quot ( name -- quot )

M: abstract-c-type c-type-boxer-quot boxer-quot>> ;

GENERIC: c-type-unboxer-quot ( name -- quot )

M: abstract-c-type c-type-unboxer-quot unboxer-quot>> ;

GENERIC: c-type-rep ( name -- rep )

M: c-type c-type-rep rep>> ;

GENERIC: c-type-getter ( name -- quot )

M: c-type c-type-getter getter>> ;

GENERIC: c-type-copier ( name -- quot )

M: c-type c-type-copier drop [ ] ;

GENERIC: c-type-setter ( name -- quot )

M: c-type c-type-setter setter>> ;

GENERIC: c-type-signed ( name -- boolean ) foldable

M: abstract-c-type c-type-signed signed>> ;

GENERIC: c-type-align ( name -- n ) foldable

M: abstract-c-type c-type-align align>> ;

GENERIC: c-type-align-first ( name -- n )

M: abstract-c-type c-type-align-first align-first>> ;

GENERIC: base-type ( c-type -- c-type )

M: c-type-name base-type lookup-c-type ;

M: c-type base-type ;

GENERIC: heap-size ( name -- size )

M: abstract-c-type heap-size size>> ;

MIXIN: value-type

MACRO: alien-value ( c-type -- quot: ( c-ptr offset -- value ) )
    [ c-type-getter ] [ c-type-boxer-quot ] bi append ;

MACRO: alien-copy-value ( c-type -- quot: ( c-ptr offset -- value ) )
    [ c-type-getter ] [ c-type-copier ] [ c-type-boxer-quot ] tri 3append ;

MACRO: set-alien-value ( c-type -- quot: ( value c-ptr offset -- ) )
    [ c-type-unboxer-quot [ [ ] ] [ '[ _ 2dip ] ] if-empty ]
    [ c-type-setter ]
    bi append ;

: array-accessor ( n c-ptr c-type -- c-ptr offset c-type )
    [ swapd heap-size * >fixnum ] keep ; inline

: alien-element ( n c-ptr c-type -- value )
    array-accessor alien-value ; inline

: set-alien-element ( value n c-ptr c-type -- )
    array-accessor set-alien-value ; inline

PROTOCOL: c-type-protocol
    c-type-class
    c-type-boxed-class
    c-type-boxer-quot
    c-type-unboxer-quot
    c-type-rep
    c-type-getter
    c-type-copier
    c-type-setter
    c-type-signed
    c-type-align
    c-type-align-first
    base-type
    heap-size ;

CONSULT: c-type-protocol c-type-name
    lookup-c-type ;

PREDICATE: typedef-word < c-type-word
    "c-type" word-prop { [ c-type-name? ] [ array? ] } 1|| ;

: typedef ( old new -- )
    {
        [ nip define-symbol ]
        [ swap "c-type" set-word-prop ]
    } 2cleave ;

TUPLE: long-long-type < c-type ;

: <long-long-type> ( -- c-type )
    long-long-type new ;

: if-void ( ..a c-type true: ( ..a -- ..b ) false: ( ..a c-type -- ..b ) -- ..b )
    pick void? [ drop nip call ] [ nip call ] if ; inline

SYMBOLS:
    ptrdiff_t intptr_t uintptr_t size_t
    c-string int8_t uint8_t int16_t uint16_t
    int32_t uint32_t int64_t uint64_t ;

SYMBOLS:
    isize usize
    s8 u8 s16 u16 s32 u32 s64 u64
    f32 f64 ;

CONSTANT: primitive-types
    {
        char uchar
        short ushort
        int uint
        long ulong
        longlong ulonglong
        float double
        void* bool
        c-string
    }

: >c-bool ( ? -- int ) 1 0 ? ; inline

: c-bool> ( int -- ? ) 0 = not ; inline

<PRIVATE

: 8-byte-alignment ( c-type -- c-type )
    {
        { [ cpu x86.32? os windows? not and ] [ 4 >>align 4 >>align-first ] }
        [ 8 >>align 8 >>align-first ]
    } cond ;

: resolve-pointer-typedef ( type -- base-type )
    dup "c-type" word-prop dup word?
    [ nip resolve-pointer-typedef ] [
        pointer? [ drop void* ] when
    ] if ;

: primitive-pointer-type? ( type -- ? )
    [ c-type-word? ] [
        resolve-pointer-typedef
        { [ void? ] [ primitive-types member? ] } 1||
    ] [ drop t ] 1if ;

: (pointer-c-type) ( void* type -- void*' )
    [ clone ] dip c-type-boxer-quot '[ _ [ f ] if* ] >>boxer-quot ;

PRIVATE>

M: pointer lookup-c-type
    [ \ void* lookup-c-type ] dip
    to>> dup primitive-pointer-type? [ drop ] [ (pointer-c-type) ] if ;

[
    <c-type>
        c-ptr >>class
        c-ptr >>boxed-class
        [ alien-cell ] >>getter
        [ set-alien-cell ] >>setter
        bootstrap-cell >>size
        bootstrap-cell >>align
        bootstrap-cell >>align-first
        [ >c-ptr ] >>unboxer-quot
        "allot_alien" >>boxer
        "alien_offset" >>unboxer
    \ void* typedef

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-signed-2 ] >>getter
        [ set-alien-signed-2 ] >>setter
        2 >>size
        t >>signed
        2 >>align
        2 >>align-first
        "from_signed_2" >>boxer
        "to_signed_2" >>unboxer
        [ >fixnum ] >>unboxer-quot
    \ short typedef

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        2 >>size
        2 >>align
        2 >>align-first
        "from_unsigned_2" >>boxer
        "to_unsigned_2" >>unboxer
        [ >fixnum ] >>unboxer-quot
    \ ushort typedef

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-signed-1 ] >>getter
        [ set-alien-signed-1 ] >>setter
        1 >>size
        t >>signed
        1 >>align
        1 >>align-first
        "from_signed_1" >>boxer
        "to_signed_1" >>unboxer
        [ >fixnum ] >>unboxer-quot
    \ char typedef

    <c-type>
        fixnum >>class
        fixnum >>boxed-class
        [ alien-unsigned-1 ] >>getter
        [ set-alien-unsigned-1 ] >>setter
        1 >>size
        1 >>align
        1 >>align-first
        "from_unsigned_1" >>boxer
        "to_unsigned_1" >>unboxer
        [ >fixnum ] >>unboxer-quot
    \ uchar typedef

    <c-type>
        math:float >>class
        math:float >>boxed-class
        [ alien-float ] >>getter
        [ set-alien-float ] >>setter
        4 >>size
        4 >>align
        4 >>align-first
        "from_float" >>boxer
        "to_float" >>unboxer
        float-rep >>rep
        [ >float ] >>unboxer-quot
    \ float typedef

    <c-type>
        math:float >>class
        math:float >>boxed-class
        [ alien-double ] >>getter
        [ set-alien-double ] >>setter
        8 >>size
        8-byte-alignment
        "from_double" >>boxer
        "to_double" >>unboxer
        double-rep >>rep
        [ >float ] >>unboxer-quot
    \ double typedef

    <c-type>
        cell 8 = fixnum integer ? >>class
        cell 8 = fixnum integer ? >>boxed-class
        [ alien-signed-4 ] >>getter
        [ set-alien-signed-4 ] >>setter
        4 >>size
        t >>signed
        4 >>align
        4 >>align-first
        "from_signed_4" >>boxer
        "to_signed_4" >>unboxer
        cell 8 = [ >fixnum ] [ >integer ] ? >>unboxer-quot
    \ int typedef

    <c-type>
        cell 8 = fixnum integer ? >>class
        cell 8 = fixnum integer ? >>boxed-class
        [ alien-unsigned-4 ] >>getter
        [ set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        4 >>align-first
        "from_unsigned_4" >>boxer
        "to_unsigned_4" >>unboxer
        cell 8 = [ >fixnum ] [ >integer ] ? >>unboxer-quot
    \ uint typedef

    cell 8 = [ <c-type> ] [ <long-long-type> ] if
        integer >>class
        integer >>boxed-class
        [ alien-signed-8 ] >>getter
        [ set-alien-signed-8 ] >>setter
        8 >>size
        t >>signed
        8-byte-alignment
        "from_signed_8" >>boxer
        "to_signed_8" >>unboxer
        [ >integer ] >>unboxer-quot
    \ longlong typedef

    cell 8 = [ <c-type> ] [ <long-long-type> ] if
        integer >>class
        integer >>boxed-class
        [ alien-unsigned-8 ] >>getter
        [ set-alien-unsigned-8 ] >>setter
        8 >>size
        8-byte-alignment
        "from_unsigned_8" >>boxer
        "to_unsigned_8" >>unboxer
        [ >integer ] >>unboxer-quot
    \ ulonglong typedef

    cell 8 = [
        os windows? [
            \ int lookup-c-type \ long typedef
            \ uint lookup-c-type \ ulong typedef
        ] [
            \ longlong lookup-c-type \ long typedef
            \ ulonglong lookup-c-type \ ulong typedef
        ] if

        \ longlong lookup-c-type \ ptrdiff_t typedef
        \ longlong lookup-c-type \ intptr_t typedef

        \ ulonglong lookup-c-type \ uintptr_t typedef
        \ ulonglong lookup-c-type \ size_t typedef

        \ longlong lookup-c-type \ isize typedef
        \ ulonglong lookup-c-type \ usize typedef
    ] [
        \ int lookup-c-type \ long typedef
        \ uint lookup-c-type \ ulong typedef

        \ int lookup-c-type \ ptrdiff_t typedef
        \ int lookup-c-type \ intptr_t typedef

        \ uint lookup-c-type \ uintptr_t typedef
        \ uint lookup-c-type \ size_t typedef

        \ int lookup-c-type \ isize typedef
        \ uint lookup-c-type \ usize typedef
    ] if

    \ uchar lookup-c-type clone
        [ >c-bool ] >>unboxer-quot
        [ c-bool> ] >>boxer-quot
        object >>boxed-class
    \ bool typedef

    \ char lookup-c-type int8_t typedef
    \ short lookup-c-type int16_t typedef
    \ int lookup-c-type int32_t typedef
    \ longlong lookup-c-type int64_t typedef

    \ uchar lookup-c-type uint8_t typedef
    \ ushort lookup-c-type uint16_t typedef
    \ uint lookup-c-type uint32_t typedef
    \ ulonglong lookup-c-type uint64_t typedef

    \ char lookup-c-type s8 typedef
    \ short lookup-c-type s16 typedef
    \ int lookup-c-type s32 typedef
    \ longlong lookup-c-type s64 typedef

    \ uchar lookup-c-type u8 typedef
    \ ushort lookup-c-type u16 typedef
    \ uint lookup-c-type u32 typedef
    \ ulonglong lookup-c-type u64 typedef

    \ float lookup-c-type f32 typedef
    \ double lookup-c-type f64 typedef
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
        { [ dup { float double } member-eq? ] [ drop -1/0. 1/0. ] }
        { [ dup c-type-signed ] [ signed-interval ] }
        { [ dup c-type-signed not ] [ unsigned-interval ] }
    } cond ; foldable

: c-type-clamp ( value c-type -- value' )
    [ { float double } member-eq? ]
    [ drop ] [ c-type-interval clamp ] 1if ; inline

GENERIC: pointer-string ( pointer -- string/f )
M: object pointer-string drop f ;
M: word pointer-string name>> ;
M: pointer pointer-string to>> pointer-string [ CHAR: * suffix ] [ f ] if* ;

GENERIC: c-type-string ( c-type -- string )

M: integer c-type-string number>string ;
M: word c-type-string name>> ;
M: pointer c-type-string pointer-string ;
M: wrapper c-type-string wrapped>> c-type-string ;
M: array c-type-string
    unclip
    [ [ c-type-string "[" "]" surround ] map ]
    [ c-type-string ] bi*
    prefix concat ;
