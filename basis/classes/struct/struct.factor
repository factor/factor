! Copyright (C) 2010, 2011 Joe Groff, Daniel Ehrenberg,
! John Benediktsson, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license
IN: classes.struct
DEFER: struct-slots ! for stack-checker
DEFER: struct-class? ! for stack-checker
DEFER: <struct-boa> ! for stack-checker
USING: accessors alien alien.c-types alien.data alien.parser
arrays assocs byte-arrays classes classes.parser classes.private
classes.struct.bit-accessors classes.tuple classes.tuple.parser
classes.tuple.private combinators combinators.short-circuit
combinators.smart cpu.architecture definitions delegate.private
effects functors.backend generalizations generic generic.parser
io kernel kernel.private lexer libc math math.order parser
quotations sequences sequences.private slots slots.private
specialized-arrays stack-checker.dependencies summary vectors
vocabs.loader vocabs.parser words ;

SPECIALIZED-ARRAY: uchar

ERROR: struct-must-have-slots ;

M: struct-must-have-slots summary
    drop "Struct definitions must have slots" ;

TUPLE: struct
    { (underlying) c-ptr read-only } ;

! We hijack the core slots vocab's slot-spec type for struct
! fields. Note that 'offset' is in bits, not bytes, to support
! bitfields.
TUPLE: struct-slot-spec < slot-spec
    type packed? ;

! For a struct-bit-slot-spec, offset is in bits, not bytes
TUPLE: struct-bit-slot-spec < struct-slot-spec
    bits signed? ;

PREDICATE: struct-class < tuple-class
    superclass-of \ struct eq? ;

SLOT: fields

: struct-slots ( struct-class -- slots )
    "c-type" word-prop fields>> ;

M: struct-class group-words
    struct-slots slot-group-words ;

! struct allocation
M: struct >c-ptr
    2 slot { c-ptr } declare ; inline

: struct-prototype ( class -- prototype ) "prototype" word-prop ; foldable

: memory>struct ( ptr class -- struct )
    ! This is sub-optimal if the class is not literal, but gets
    ! optimized down to efficient code if it is.
    struct-class check-instance
    M\ tuple-class boa execute( ptr class -- struct ) ;

: read-struct ( class -- struct )
    [ heap-size read ] [ memory>struct ] bi ;

<PRIVATE

: init-struct ( class with-prototype: ( prototype -- alien ) sans-prototype: ( class -- alien ) -- alien )
    '[ [ struct-prototype ] _ _ ?if ] keep memory>struct ; inline

PRIVATE>

: (malloc-struct) ( class -- struct )
    [ heap-size malloc ] keep memory>struct ; inline

: malloc-struct ( class -- struct )
    [ >c-ptr malloc-byte-array ] [ 1 swap heap-size calloc ] init-struct ; inline

: (struct) ( class -- struct )
    [ heap-size (byte-array) ] keep memory>struct ; inline

: <struct> ( class -- struct )
    [ >c-ptr clone ] [ heap-size <byte-array> ] init-struct ; inline

<PRIVATE

: pad-struct-slots ( values class -- values' class )
    [ struct-slots [ initial>> ] map over length tail append ] keep ;

: sign-extend ( n bits -- n' )
    ! formula from:
    ! https://guru.multimedia.cx/fast-sign-extension/
    1 - -1 swap shift [ + ] keep bitxor ; inline

: sign-extender ( signed? bits -- quot )
    '[ _ [ _ sign-extend ] when ] ;

GENERIC: (reader-quot) ( slot -- quot: ( struct -- value ) )

M: struct-slot-spec (reader-quot)
    [ offset>> ] [ type>> ] bi '[ >c-ptr _ _ alien-value ] ;

M: struct-bit-slot-spec (reader-quot)
    [ [ offset>> ] [ bits>> ] bi bit-reader ]
    [ [ signed?>> ] [ bits>> ] bi sign-extender ]
    bi compose
    [ >c-ptr ] prepose ;

GENERIC: (writer-quot) ( slot -- quot: ( value struct -- ) )

M: struct-slot-spec (writer-quot)
    [ offset>> ] [ type>> ] bi '[ >c-ptr _ _ set-alien-value ] ;

M: struct-bit-slot-spec (writer-quot)
    [ offset>> ] [ bits>> ] bi bit-writer [ >c-ptr ] prepose ;

: (boxer-quot) ( class -- quot )
    '[ _ memory>struct ] ;

: (unboxer-quot) ( class -- quot )
    drop [ >c-ptr ] ;

MACRO: read-struct-slot ( slot -- quot: ( struct -- value ) )
    dup type>> add-depends-on-c-type
    (reader-quot) ;

MACRO: write-struct-slot ( slot -- quot: ( value struct -- ) )
    dup type>> add-depends-on-c-type
    (writer-quot) ;

PRIVATE>

MACRO: <struct-boa> ( class -- quot: ( ... -- struct ) )
    dup struct-slots
    [ length ] [ [ (writer-quot) '[ over @ ] ] map ] bi
    '[ [ _ (struct) ] _ ndip _ spread ] ;

M: struct-class boa>object
    swap pad-struct-slots
    [ <struct> ] [ struct-slots ] bi
    [ [ (writer-quot) call( value struct -- ) ] with 2each ] keepd ;

M: struct-class new <struct> ;

M: struct-class boa <struct-boa> ;

M: struct-class boa-effect
    [ struct-slots [ name>> ] map ] [ name>> 1array ] bi <effect> ;

M: struct-class initial-value* <struct> t ; inline

! Struct slot accessors

GENERIC: struct-slot-values ( struct -- sequence )

M: struct-class reader-quot
    dup type>> array? [ dup type>> first define-array-vocab drop ] when
    nip '[ _ read-struct-slot ] ;

M: struct-class writer-quot
    nip '[ _ write-struct-slot ] ;

: offset-of ( field struct -- offset )
    struct-slots slot-named offset>> ; inline

M: struct equal?
    2dup [ class-of ] same? [
        [ struct-slot-values ] same?
    ] [ 2drop f ] if ; inline

M: struct hashcode*
    nip dup >c-ptr [ struct-slot-values hashcode ] [ drop 0 ] if ; inline

! c-types

TUPLE: struct-c-type < abstract-c-type
    fields
    return-in-registers? ;

INSTANCE: struct-c-type value-type

M: struct-c-type lookup-c-type ;

M: struct-c-type base-type ;

: large-struct? ( type -- ? )
    {
        { [ dup void? ] [ drop f ] }
        { [ dup base-type struct-c-type? not ] [ drop f ] }
        [ return-struct-in-registers? not ]
    } cond ;

<PRIVATE
: struct-slot-values-quot ( class -- quot )
    struct-slots
    [ name>> reader-word 1quotation ] map
    '[ _ cleave>array ] ;

: define-struct-slot-values-method ( class -- )
    [ \ struct-slot-values ] [ struct-slot-values-quot ] bi
    define-inline-method ;

: forget-struct-slot-values-method ( class -- )
    \ struct-slot-values ?lookup-method forget ;

: clone-underlying ( struct -- byte-array )
    binary-object memory>byte-array ; inline

: define-clone-method ( class -- )
    [ \ clone ] [ '[ clone-underlying _ memory>struct ] ] bi
    define-inline-method ;

: forget-clone-method ( class -- )
    \ clone ?lookup-method forget ;

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

: c-type-align-at ( slot-spec offset -- n )
    over packed?>> [ 2drop 1 ] [
        [ type>> ] dip
        0 = [ c-type-align-first ] [ c-type-align ] if
    ] if ;

M: struct-slot-spec compute-slot-offset
    [ over c-type-align-at 8 * align ] keep
    [ [ 8 /i ] dip offset<< ] [ type>> heap-size 8 * + ] 2bi ;

M: struct-bit-slot-spec compute-slot-offset
    [ offset<< ] [ bits>> + ] 2bi ;

: compute-struct-offsets ( slots -- size )
    0 [ compute-slot-offset ] reduce 8 align 8 /i ;

: compute-union-offsets ( slots -- size )
    1 [ 0 >>offset type>> heap-size max ] reduce ;

: struct-alignment ( slots -- align )
    [ struct-bit-slot-spec? ] reject
    1 [ dup offset>> c-type-align-at max ] reduce ;

PRIVATE>

: struct-size ( class -- n ) "struct-size" word-prop ; inline

M: struct byte-length class-of struct-size ; inline foldable
M: struct binary-zero? binary-object uchar <c-direct-array> [ 0 = ] all? ; inline

! class definition

<PRIVATE
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
            over [ swapd [ call( value struct -- ) ] keepd ] [ 2drop ] if
        ] each
    ] [ drop f ] if ;

: define-struct-methods ( class -- )
    [ define-struct-slot-values-method ] [ define-clone-method ] bi ;

: check-struct-slots ( slots -- )
    [ type>> lookup-c-type drop ] each ;

: redefine-struct-tuple-class ( class -- )
    [ struct f redefine-tuple-class ] [ make-final ] bi ;

: resize-underlying ( struct -- )
    [ 2 slot dup byte-array? ]
    [ class-of "struct-size" word-prop '[ _ swap resize ] [ drop f ] if ]
    [ 2 set-slot ] tri ;

M: struct update-tuple
    ! make sure underlying byte-array is correct size, but maybe
    ! has incorrect contents... is there something better to do?
    [ resize-underlying ] [ call-next-method ] bi ;

: forget-struct-slot-accessors ( class -- )
    dup "c-type" word-prop [
        dup struct-c-type? [
            fields>> forget-slot-accessors
        ] [ 2drop ] if
    ] [ drop ] if* ;

:: (define-struct-class) ( class slot-specs offsets-quot alignment-quot -- )
    slot-specs check-struct-slots
    slot-specs empty? [ struct-must-have-slots ] when
    class redefine-struct-tuple-class
    slot-specs offsets-quot call :> unaligned-size
    slot-specs alignment-quot call :> alignment
    unaligned-size alignment align :> size

    class slot-specs size alignment c-type-for-class :> c-type

    class forget-struct-slot-accessors

    c-type class typedef
    class slot-specs define-accessors
    class size "struct-size" set-word-prop
    class dup make-struct-prototype "prototype" set-word-prop
    class define-struct-methods ; inline

: make-packed-slots ( slots -- slot-specs )
    make-slots [ t >>packed? ] map! ;

PRIVATE>

: define-struct-class ( class slots -- )
    make-slots
    [ compute-struct-offsets ] [ struct-alignment ]
    (define-struct-class) ;

: define-packed-struct-class ( class slots -- )
    make-packed-slots
    [ compute-struct-offsets ] [ drop 1 ]
    (define-struct-class) ;

: define-union-struct-class ( class slots -- )
    make-slots
    [ compute-union-offsets ] [ struct-alignment ]
    (define-struct-class) ;

ERROR: invalid-struct-slot token ;

: struct-slot-class ( c-type -- class' )
    lookup-c-type c-type-boxed-class
    dup \ byte-array = [ drop \ c-ptr ] when ;

M: struct-class reset-class
    {
        [ \ <struct-boa> def>> first delete-at ]
        [ forget-struct-slot-accessors ]
        [ forget-struct-slot-values-method ]
        [ forget-clone-method ]
        [ { "c-type" "layout" "struct-size" } remove-word-props ]
        [ call-next-method ]
    } cleave ;

SYMBOL: bits:

<PRIVATE

:: set-bits ( slot-spec n -- slot-spec )
    struct-bit-slot-spec new
        n >>bits
        slot-spec type>> c-type-signed >>signed?
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
    [ [ >>type ] [ struct-slot-class init-slot-class ] bi ]
    [ [ dup empty? ] [ peel-off-struct-attributes ] until drop ] tri* ;

<PRIVATE
: parse-struct-slot ( -- slot )
    scan-token scan-c-type \ } parse-until <struct-slot-spec> ;

: parse-struct-slots ( slots -- slots' more? )
    scan-token {
        { ";" [ f ] }
        { "{" [ parse-struct-slot suffix! t ] }
        [ invalid-struct-slot ]
    } case ;

: parse-struct-definition ( -- class slots )
    scan-new-class 8 <vector> [ parse-struct-slots ] [ ] while >array
    dup [ name>> ] map check-duplicate-slots ;
PRIVATE>

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;

SYNTAX: PACKED-STRUCT:
    parse-struct-definition define-packed-struct-class ;

SYNTAX: UNION-STRUCT:
    parse-struct-definition define-union-struct-class ;

SYNTAX: S{
    scan-word dup struct-slots parse-tuple-literal-slots suffix! ;

SYNTAX: S@
    scan-word scan-object swap memory>struct suffix! ;

! functor support

<PRIVATE
: scan-c-type* ( -- c-type/param )
    scan-token dup "{" = [ drop \ } parse-until >array ] [ search ] if ;

: parse-struct-slot* ( accum -- accum )
    scan-string-param scan-c-type* \ } parse-until
    [ <struct-slot-spec> suffix! ] 3curry append! ;

: parse-struct-slots* ( accum -- accum more? )
    scan-token {
        { ";" [ f ] }
        { "{" [ parse-struct-slot* t ] }
        [ invalid-struct-slot ]
    } case ;

PRIVATE>

FUNCTOR-SYNTAX: STRUCT:
    scan-param suffix!
    [ 8 <vector> ] append!
    [ parse-struct-slots* ] [ ] while
    [ >array define-struct-class ] append! ;

{ "classes.struct" "prettyprint" } "classes.struct.prettyprint" require-when
