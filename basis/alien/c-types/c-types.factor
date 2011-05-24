! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors arrays byte-arrays
classes combinators compiler.units cpu.architecture delegate
fry kernel layouts locals macros math math.order quotations
sequences system words words.symbol summary ;
QUALIFIED: math
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
GENERIC: c-type ( name -- c-type ) foldable

PREDICATE: c-type-word < word
    "c-type" word-prop ;

TUPLE: pointer { to initial: void read-only } ;
C: <pointer> pointer

UNION: c-type-name
    c-type-word pointer ;

: resolve-typedef ( name -- c-type )
    dup void? [ no-c-type ] when
    dup c-type-name? [ c-type ] when ;

M: word c-type
    dup "c-type" word-prop resolve-typedef
    [ ] [ no-c-type ] ?if ;

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

GENERIC: c-type-align ( name -- n ) foldable

M: abstract-c-type c-type-align align>> ;

GENERIC: c-type-align-first ( name -- n )

M: abstract-c-type c-type-align-first align-first>> ;

GENERIC: base-type ( c-type -- c-type )

M: c-type-name base-type c-type ;

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
    c-type-align
    c-type-align-first
    base-type
    heap-size ;

CONSULT: c-type-protocol c-type-name
    c-type ;

PREDICATE: typedef-word < c-type-word
    "c-type" word-prop [ c-type-name? ] [ array? ] bi or ;

: typedef ( old new -- )
    {
        [ nip define-symbol ]
        [ swap "c-type" set-word-prop ]
    } 2cleave ;

TUPLE: long-long-type < c-type ;

: <long-long-type> ( -- c-type )
    long-long-type new ;

: if-void ( c-type true false -- )
    pick void? [ drop nip call ] [ nip call ] if ; inline

SYMBOLS:
    ptrdiff_t intptr_t uintptr_t size_t
    c-string ;

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
        { [ cpu ppc? os macosx? and ] [ 4 >>align 8 >>align-first ] }
        { [ cpu x86.32? os windows? not and ] [ 4 >>align 4 >>align-first ] }
        [ 8 >>align 8 >>align-first ]
    } cond ;

: resolve-pointer-typedef ( type -- base-type )
    dup "c-type" word-prop dup word?
    [ nip resolve-pointer-typedef ] [
        pointer? [ drop void* ] when
    ] if ;

: primitive-pointer-type? ( type -- ? )
    dup c-type-word? [
        resolve-pointer-typedef [ void? ] [ primitive-types member? ] bi or
    ] [ drop t ] if ;

: (pointer-c-type) ( void* type -- void*' )
    [ clone ] dip c-type-boxer-quot '[ _ [ f ] if* ] >>boxer-quot ;

PRIVATE>

M: pointer c-type
    [ \ void* c-type ] dip
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

    cell 8 = [
        <c-type>
            fixnum >>class
            fixnum >>boxed-class
            [ alien-signed-4 ] >>getter
            [ set-alien-signed-4 ] >>setter
            4 >>size
            4 >>align
            4 >>align-first
            "from_signed_4" >>boxer
            "to_signed_4" >>unboxer
            [ >fixnum ] >>unboxer-quot
        \ int typedef
    
        <c-type>
            fixnum >>class
            fixnum >>boxed-class
            [ alien-unsigned-4 ] >>getter
            [ set-alien-unsigned-4 ] >>setter
            4 >>size
            4 >>align
            4 >>align-first
            "from_unsigned_4" >>boxer
            "to_unsigned_4" >>unboxer
            [ >fixnum ] >>unboxer-quot
        \ uint typedef

        <c-type>
            integer >>class
            integer >>boxed-class
            [ alien-signed-cell ] >>getter
            [ set-alien-signed-cell ] >>setter
            8 >>size
            8 >>align
            8 >>align-first
            "from_signed_cell" >>boxer
            "to_fixnum" >>unboxer
            [ >integer ] >>unboxer-quot
        \ longlong typedef

        <c-type>
            integer >>class
            integer >>boxed-class
            [ alien-unsigned-cell ] >>getter
            [ set-alien-unsigned-cell ] >>setter
            8 >>size
            8 >>align
            8 >>align-first
            "from_unsigned_cell" >>boxer
            "to_cell" >>unboxer
            [ >integer ] >>unboxer-quot
        \ ulonglong typedef

        os windows? [
            \ int c-type \ long typedef
            \ uint c-type \ ulong typedef
        ] [
            \ longlong c-type \ long typedef
            \ ulonglong c-type \ ulong typedef
        ] if

        \ longlong c-type \ ptrdiff_t typedef
        \ longlong c-type \ intptr_t typedef

        \ ulonglong c-type \ uintptr_t typedef
        \ ulonglong c-type \ size_t typedef
    ] [
        <c-type>
            integer >>class
            integer >>boxed-class
            [ alien-signed-cell ] >>getter
            [ set-alien-signed-cell ] >>setter
            4 >>size
            4 >>align
            4 >>align-first
            "from_signed_cell" >>boxer
            "to_fixnum" >>unboxer
            [ >integer ] >>unboxer-quot
        \ int typedef
    
        <c-type>
            integer >>class
            integer >>boxed-class
            [ alien-unsigned-cell ] >>getter
            [ set-alien-unsigned-cell ] >>setter
            4 >>size
            4 >>align
            4 >>align-first
            "from_unsigned_cell" >>boxer
            "to_cell" >>unboxer
            [ >integer ] >>unboxer-quot
        \ uint typedef

        <long-long-type>
            integer >>class
            integer >>boxed-class
            [ alien-signed-8 ] >>getter
            [ set-alien-signed-8 ] >>setter
            8 >>size
            8-byte-alignment
            "from_signed_8" >>boxer
            "to_signed_8" >>unboxer
            [ >integer ] >>unboxer-quot
        \ longlong typedef

        <long-long-type>
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

        \ int c-type \ long typedef
        \ uint c-type \ ulong typedef

        \ int c-type \ ptrdiff_t typedef
        \ int c-type \ intptr_t typedef

        \ uint c-type \ uintptr_t typedef
        \ uint c-type \ size_t typedef
    ] if

    cpu ppc? os macosx? and \ uint \ uchar ? c-type clone
        [ >c-bool ] >>unboxer-quot
        [ c-bool> ] >>boxer-quot
        object >>boxed-class
    \ bool typedef

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
        { [ dup { char short int long longlong } member-eq? ] [ signed-interval ] }
        { [ dup { uchar ushort uint ulong ulonglong } member-eq? ] [ unsigned-interval ] }
    } cond ; foldable

: c-type-clamp ( value c-type -- value' )
    dup { float double } member-eq?
    [ drop ] [ c-type-interval clamp ] if ; inline
