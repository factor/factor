! (c)Joe Groff, Daniel Ehrenberg bsd license
USING: accessors alien alien.c-types alien.data alien.parser
arrays byte-arrays classes classes.private classes.parser
classes.tuple classes.tuple.parser classes.tuple.private
combinators combinators.short-circuit combinators.smart
cpu.architecture definitions functors.backend fry
generalizations generic.parser kernel kernel.private lexer libc
locals macros make math math.order parser quotations sequences
slots slots.private specialized-arrays vectors words summary
namespaces assocs vocabs.parser math.functions
classes.struct.bit-accessors bit-arrays
stack-checker.dependencies ;
QUALIFIED: math
IN: classes.struct

SPECIALIZED-ARRAY: uchar

ERROR: struct-must-have-slots ;

M: struct-must-have-slots summary
    drop "Struct definitions must have slots" ;

TUPLE: struct
    { (underlying) c-ptr read-only } ;

TUPLE: struct-slot-spec < slot-spec
    type ;

! For a struct-bit-slot-spec, offset is in bits, not bytes
TUPLE: struct-bit-slot-spec < struct-slot-spec
    bits signed? ;

PREDICATE: struct-class < tuple-class
    superclass \ struct eq? ;

SLOT: fields

: struct-slots ( struct-class -- slots )
    "c-type" word-prop fields>> ;

! struct allocation

M: struct >c-ptr
    2 slot { c-ptr } declare ; inline

M: struct equal?
    {
        [ [ class ] bi@ = ]
        [ [ >c-ptr ] [ binary-object ] bi* memory= ]
    } 2&& ; inline

M: struct hashcode*
    binary-object <direct-uchar-array> hashcode* ; inline

: struct-prototype ( class -- prototype ) "prototype" word-prop ; foldable

: memory>struct ( ptr class -- struct )
    ! This is sub-optimal if the class is not literal, but gets
    ! optimized down to efficient code if it is.
    '[ _ boa ] call( ptr -- struct ) ; inline

<PRIVATE
: (init-struct) ( class with-prototype: ( prototype -- alien ) sans-prototype: ( class -- alien ) -- alien )
    '[ dup struct-prototype _ _ ?if ] keep memory>struct ; inline
PRIVATE>

: (malloc-struct) ( class -- struct )
    [ heap-size malloc ] keep memory>struct ; inline

: malloc-struct ( class -- struct )
    [ >c-ptr malloc-byte-array ] [ 1 swap heap-size calloc ] (init-struct) ; inline

: (struct) ( class -- struct )
    [ heap-size (byte-array) ] keep memory>struct ; inline

: <struct> ( class -- struct )
    [ >c-ptr clone ] [ heap-size <byte-array> ] (init-struct) ; inline

MACRO: <struct-boa> ( class -- quot: ( ... -- struct ) )
    [
        [ <wrapper> \ (struct) [ ] 2sequence ]
        [
            struct-slots
            [ length \ ndip ]
            [ [ name>> setter-word 1quotation ] map \ spread ] bi
        ] bi
    ] [ ] output>sequence ;

<PRIVATE
: pad-struct-slots ( values class -- values' class )
    [ struct-slots [ initial>> ] map over length tail append ] keep ;

: sign-extend ( n bits -- n' )
    ! formula from:
    ! http://guru.multimedia.cx/fast-sign-extension/
    1 - -1 swap shift [ + ] keep bitxor ; inline

: sign-extender ( signed? bits -- quot )
    '[ _ [ _ sign-extend ] when ] ;

GENERIC: (reader-quot) ( slot -- quot )

M: struct-slot-spec (reader-quot)
    [ type>> c-type-getter-boxer ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

M: struct-bit-slot-spec (reader-quot)
    [ [ offset>> ] [ bits>> ] bi bit-reader ]
    [ [ signed?>> ] [ bits>> ] bi sign-extender ]
    bi compose
    [ >c-ptr ] prepose ;

GENERIC: (writer-quot) ( slot -- quot )

M: struct-slot-spec (writer-quot)
    [ type>> c-setter ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

M: struct-bit-slot-spec (writer-quot)
    [ offset>> ] [ bits>> ] bi bit-writer
    [ >c-ptr ] prepose ;

: (boxer-quot) ( class -- quot )
    '[ _ memory>struct ] ;

: (unboxer-quot) ( class -- quot )
    drop [ >c-ptr ] ;

MACRO: read-struct-slot ( slot -- )
    dup type>> depends-on-c-type
    (reader-quot) ;

MACRO: write-struct-slot ( slot -- )
    dup type>> depends-on-c-type
    (writer-quot) ;
PRIVATE>

M: struct-class boa>object
    swap pad-struct-slots
    [ <struct> ] [ struct-slots ] bi
    [ [ (writer-quot) call( value struct -- ) ] with 2each ] curry keep ;

M: struct-class initial-value* <struct> ; inline

! Struct slot accessors

GENERIC: struct-slot-values ( struct -- sequence )

M: struct-class reader-quot
    dup type>> array? [ dup type>> first define-array-vocab drop ] when
    nip '[ _ read-struct-slot ] ;

M: struct-class writer-quot
    nip '[ _ write-struct-slot ] ;

: offset-of ( field struct -- offset )
    struct-slots slot-named offset>> ; inline

! c-types

TUPLE: struct-c-type < abstract-c-type
    fields
    return-in-registers? ;

INSTANCE: struct-c-type value-type

M: struct-c-type c-type ;

M: struct-c-type c-type-stack-align? drop f ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop void* @ ] if ; inline

M: struct-c-type unbox-parameter
    [ %unbox-large-struct ] [ unbox-parameter ] if-value-struct ;

M: struct-c-type box-parameter
    [ %box-large-struct ] [ box-parameter ] if-value-struct ;

: if-small-struct ( c-type true false -- ? )
    [ dup return-struct-in-registers? ] 2dip '[ f swap @ ] if ; inline

M: struct-c-type unbox-return
    [ %unbox-small-struct ] [ %unbox-large-struct ] if-small-struct ;

M: struct-c-type box-return
    [ %box-small-struct ] [ %box-large-struct ] if-small-struct ;

M: struct-c-type stack-size
    [ heap-size ] [ stack-size ] if-value-struct ;

M: struct-c-type c-struct? drop t ;

<PRIVATE
: struct-slot-values-quot ( class -- quot )
    struct-slots
    [ name>> reader-word 1quotation ] map
    \ cleave [ ] 2sequence
    \ output>array [ ] 2sequence ;

: (define-struct-slot-values-method) ( class -- )
    [ \ struct-slot-values ] [ struct-slot-values-quot ] bi
    define-inline-method ;

: clone-underlying ( struct -- byte-array )
    binary-object memory>byte-array ; inline

: (define-clone-method) ( class -- )
    [ \ clone ]
    [ \ clone-underlying swap literalize \ memory>struct [ ] 3sequence ] bi
    define-inline-method ;

:: c-type-for-class ( class slots size align -- c-type )
    struct-c-type new
        byte-array >>class
        class >>boxed-class
        slots >>fields
        size >>size
        align >>align
        align >>align-first
        class (unboxer-quot) >>unboxer-quot
        class (boxer-quot) >>boxer-quot ;

GENERIC: compute-slot-offset ( offset class -- offset' )

: c-type-align-at ( class offset -- n )
    0 = [ c-type-align-first ] [ c-type-align ] if ;

M: struct-slot-spec compute-slot-offset
    [ type>> over c-type-align-at 8 * align ] keep
    [ [ 8 /i ] dip (>>offset) ] [ type>> heap-size 8 * + ] 2bi ;

M: struct-bit-slot-spec compute-slot-offset
    [ (>>offset) ] [ bits>> + ] 2bi ;

: compute-struct-offsets ( slots -- size )
    0 [ compute-slot-offset ] reduce 8 align 8 /i ;

: compute-union-offsets ( slots -- size )
    1 [ 0 >>offset type>> heap-size max ] reduce ;

: struct-alignment ( slots -- align )
    [ struct-bit-slot-spec? not ] filter
    1 [ [ type>> ] [ offset>> ] bi c-type-align-at max ] reduce ;

PRIVATE>

M: struct byte-length class "struct-size" word-prop ; foldable

! class definition

<PRIVATE
GENERIC: binary-zero? ( value -- ? )

M: object binary-zero? drop f ;
M: f binary-zero? drop t ;
M: number binary-zero? 0 = ;
M: struct binary-zero? >c-ptr [ 0 = ] all? ;

: struct-needs-prototype? ( class -- ? )
    struct-slots [ initial>> binary-zero? ] all? not ;

: make-struct-prototype ( class -- prototype )
    dup struct-needs-prototype? [
        [ "c-type" word-prop size>> <byte-array> ]
        [ memory>struct ]
        [ struct-slots ] tri
        [
            [ initial>> ]
            [ (writer-quot) ] bi
            over [ swapd [ call( value struct -- ) ] curry keep ] [ 2drop ] if
        ] each
    ] [ drop f ] if ;

: (struct-methods) ( class -- )
    [ (define-struct-slot-values-method) ]
    [ (define-clone-method) ]
    bi ;

: check-struct-slots ( slots -- )
    [ type>> c-type drop ] each ;

: redefine-struct-tuple-class ( class -- )
    [ struct f define-tuple-class ] [ make-final ] bi ;

:: (define-struct-class) ( class slots offsets-quot -- )
    slots empty? [ struct-must-have-slots ] when
    class redefine-struct-tuple-class
    slots make-slots dup check-struct-slots :> slot-specs
    slot-specs offsets-quot call :> unaligned-size
    slot-specs struct-alignment :> alignment
    unaligned-size alignment align :> size

    class  slot-specs  size  alignment  c-type-for-class :> c-type

    c-type class typedef
    class slot-specs define-accessors
    class size "struct-size" set-word-prop
    class dup make-struct-prototype "prototype" set-word-prop
    class (struct-methods) ; inline
PRIVATE>

: define-struct-class ( class slots -- )
    [ compute-struct-offsets ] (define-struct-class) ;

: define-union-struct-class ( class slots -- )
    [ compute-union-offsets ] (define-struct-class) ;

ERROR: invalid-struct-slot token ;

: struct-slot-class ( c-type -- class' )
    c-type c-type-boxed-class
    dup \ byte-array = [ drop \ c-ptr ] when ;

SYMBOL: bits:

<PRIVATE

ERROR: bad-type-for-bits type ;

:: set-bits ( slot-spec n -- slot-spec )
    struct-bit-slot-spec new
        n >>bits
        slot-spec type>> {
            { int [ t ] }
            { uint [ f ] }
            [ bad-type-for-bits ]
        } case >>signed?
        slot-spec name>> >>name
        slot-spec class>> >>class
        slot-spec type>> >>type
        slot-spec read-only>> >>read-only
        slot-spec initial>> >>initial ;

: peel-off-struct-attributes ( slot-spec array -- slot-spec array )
    dup empty? [
        unclip {
            { initial: [ [ first >>initial ] [ rest ] bi ] }
            { read-only [ [ t >>read-only ] dip ] }
            { bits: [ [ first set-bits ] [ rest ] bi ] }
            [ bad-slot-attribute ]
        } case
    ] unless ;

PRIVATE>

: <struct-slot-spec> ( name c-type attributes -- slot-spec )
    [ struct-slot-spec new ] 3dip
    [ >>name ]
    [ [ >>type ] [ struct-slot-class >>class ] bi ]
    [ [ dup empty? ] [ peel-off-struct-attributes ] until drop ] tri* ;

<PRIVATE
: parse-struct-slot ( -- slot )
    scan scan-c-type \ } parse-until <struct-slot-spec> ;

: parse-struct-slots ( slots -- slots' more? )
    scan {
        { ";" [ f ] }
        { "{" [ parse-struct-slot suffix! t ] }
        { f [ unexpected-eof ] }
        [ invalid-struct-slot ]
    } case ;

: parse-struct-definition ( -- class slots )
    CREATE-CLASS 8 <vector> [ parse-struct-slots ] [ ] while >array
    dup [ name>> ] map check-duplicate-slots ;
PRIVATE>

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;
SYNTAX: UNION-STRUCT:
    parse-struct-definition define-union-struct-class ;

SYNTAX: S{
    scan-word dup struct-slots parse-tuple-literal-slots suffix! ;

SYNTAX: S@
    scan-word scan-object swap memory>struct suffix! ;

! functor support

<PRIVATE
: scan-c-type` ( -- c-type/param )
    scan dup "{" = [ drop \ } parse-until >array ] [ search ] if ;

: parse-struct-slot` ( accum -- accum )
    scan-string-param scan-c-type` \ } parse-until
    [ <struct-slot-spec> suffix! ] 3curry append! ;

: parse-struct-slots` ( accum -- accum more? )
    scan {
        { ";" [ f ] }
        { "{" [ parse-struct-slot` t ] }
        [ invalid-struct-slot ]
    } case ;
PRIVATE>

FUNCTOR-SYNTAX: STRUCT:
    scan-param suffix!
    [ 8 <vector> ] append!
    [ parse-struct-slots` ] [ ] while
    [ >array define-struct-class ] append! ;

USING: vocabs vocabs.loader ;

{ "classes.struct" "prettyprint" } "classes.struct.prettyprint" require-when
