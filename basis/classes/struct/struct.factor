! (c)Joe Groff bsd license
USING: accessors alien alien.c-types arrays byte-arrays classes
classes.parser classes.tuple classes.tuple.parser
classes.tuple.private combinators combinators.short-circuit
combinators.smart cpu.architecture definitions functors.backend
fry generalizations generic.parser kernel kernel.private lexer
libc locals macros make math math.order parser quotations
sequences slots slots.private specialized-arrays vectors words
summary namespaces assocs ;
IN: classes.struct

SPECIALIZED-ARRAY: uchar

ERROR: struct-must-have-slots ;

M: struct-must-have-slots summary
    drop "Struct definitions must have slots" ;

TUPLE: struct
    { (underlying) c-ptr read-only } ;

TUPLE: struct-slot-spec < slot-spec
    type ;

PREDICATE: struct-class < tuple-class
    superclass \ struct eq? ;

M: struct-class valid-superclass? drop f ;

GENERIC: struct-slots ( struct-class -- slots )

M: struct-class struct-slots "struct-slots" word-prop ;

! struct allocation

M: struct >c-ptr
    2 slot { c-ptr } declare ; inline

M: struct equal?
    {
        [ [ class ] bi@ = ]
        [ [ >c-ptr ] [ [ >c-ptr ] [ byte-length ] bi ] bi* memory= ]
    } 2&& ; inline

M: struct hashcode*
    [ >c-ptr ] [ byte-length ] bi <direct-uchar-array> hashcode* ; inline    

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

: (reader-quot) ( slot -- quot )
    [ type>> c-type-getter-boxer ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

: (writer-quot) ( slot -- quot )
    [ type>> c-setter ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

: (boxer-quot) ( class -- quot )
    '[ _ memory>struct ] ;

: (unboxer-quot) ( class -- quot )
    drop [ >c-ptr ] ;
PRIVATE>

M: struct-class boa>object
    swap pad-struct-slots
    [ <struct> ] [ struct-slots ] bi 
    [ [ (writer-quot) call( value struct -- ) ] with 2each ] curry keep ;

! Struct slot accessors

GENERIC: struct-slot-values ( struct -- sequence )

M: struct-class reader-quot
    nip (reader-quot) ;

M: struct-class writer-quot
    nip (writer-quot) ;

! c-types

TUPLE: struct-c-type < abstract-c-type
    fields
    return-in-registers? ;

INSTANCE: struct-c-type value-type

M: struct-c-type c-type ;

M: struct-c-type c-type-stack-align? drop f ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop "void*" @ ] if ; inline

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

: define-inline-method ( class generic quot -- )
    [ create-method-in ] dip [ define ] [ drop make-inline ] 2bi ;

: (define-struct-slot-values-method) ( class -- )
    [ \ struct-slot-values ] [ struct-slot-values-quot ] bi
    define-inline-method ;

: clone-underlying ( struct -- byte-array )
    [ >c-ptr ] [ byte-length ] bi memory>byte-array ; inline

: (define-clone-method) ( class -- )
    [ \ clone ]
    [ \ clone-underlying swap literalize \ memory>struct [ ] 3sequence ] bi
    define-inline-method ;

: c-type-for-class ( class -- c-type )
    struct-c-type new swap {
        [ drop byte-array >>class ]
        [ >>boxed-class ]
        [ struct-slots >>fields ]
        [ "struct-size" word-prop >>size ]
        [ "struct-align" word-prop >>align ]
        [ (unboxer-quot) >>unboxer-quot ]
        [ (boxer-quot) >>boxer-quot ]
    } cleave ;
    
: align-offset ( offset class -- offset' )
    c-type-align align ;

: struct-offsets ( slots -- size )
    0 [
        [ type>> align-offset ] keep
        [ (>>offset) ] [ type>> heap-size + ] 2bi
    ] reduce ;

: union-struct-offsets ( slots -- size )
    [ 0 >>offset type>> heap-size ] [ max ] map-reduce ;

: struct-align ( slots -- align )
    [ type>> c-type-align ] [ max ] map-reduce ;
PRIVATE>

M: struct-class c-type name>> c-type ;

M: struct-class c-type-align c-type c-type-align ;

M: struct-class c-type-getter c-type c-type-getter ;

M: struct-class c-type-setter c-type c-type-setter ;

M: struct-class c-type-boxer-quot c-type c-type-boxer-quot ;

M: struct-class c-type-unboxer-quot c-type c-type-boxer-quot ;

M: struct-class heap-size c-type heap-size ;

M: struct byte-length class "struct-size" word-prop ; foldable

! class definition

<PRIVATE
: make-struct-prototype ( class -- prototype )
    [ "struct-size" word-prop <byte-array> ]
    [ memory>struct ]
    [ struct-slots ] tri
    [
        [ initial>> ]
        [ (writer-quot) ] bi
        over [ swapd [ call( value struct -- ) ] curry keep ] [ 2drop ] if
    ] each ;

: (struct-methods) ( class -- )
    [ (define-struct-slot-values-method) ]
    [ (define-clone-method) ]
    bi ;

: (struct-word-props) ( class slots size align -- )
    [
        [ "struct-slots" set-word-prop ]
        [ define-accessors ] 2bi
    ]
    [ "struct-size" set-word-prop ]
    [ "struct-align" set-word-prop ] tri-curry*
    [ tri ] 3curry
    [ dup make-struct-prototype "prototype" set-word-prop ]
    [ (struct-methods) ] tri ;

: check-struct-slots ( slots -- )
    [ type>> c-type drop ] each ;

: redefine-struct-tuple-class ( class -- )
    [ dup class? [ forget-class ] [ drop ] if ] [ struct f define-tuple-class ] bi ;

: (define-struct-class) ( class slots offsets-quot -- )
    [ 
        empty?
        [ struct-must-have-slots ]
        [ redefine-struct-tuple-class ] if
    ]
    swap '[
        make-slots dup
        [ check-struct-slots ] _ [ struct-align [ align ] keep ] tri
        (struct-word-props)
    ]
    [ drop [ c-type-for-class ] [ name>> ] bi typedef ] 2tri ; inline
PRIVATE>

: define-struct-class ( class slots -- )
    [ struct-offsets ] (define-struct-class) ;

: define-union-struct-class ( class slots -- )
    [ union-struct-offsets ] (define-struct-class) ;

M: struct-class reset-class
    [ call-next-method ] [ name>> c-types get delete-at ] bi ;

ERROR: invalid-struct-slot token ;

: struct-slot-class ( c-type -- class' )
    c-type c-type-boxed-class
    dup \ byte-array = [ drop \ c-ptr ] when ;

: <struct-slot-spec> ( name c-type attributes -- slot-spec )
    [ struct-slot-spec new ] 3dip
    [ >>name ]
    [ [ >>type ] [ struct-slot-class >>class ] bi ]
    [ [ dup empty? ] [ peel-off-attributes ] until drop ] tri* ;

<PRIVATE
: scan-c-type ( -- c-type )
    scan dup "{" = [ drop \ } parse-until >array ] when ;

: parse-struct-slot ( -- slot )
    scan scan-c-type \ } parse-until <struct-slot-spec> ;
    
: parse-struct-slots ( slots -- slots' more? )
    scan {
        { ";" [ f ] }
        { "{" [ parse-struct-slot over push t ] }
        { f [ unexpected-eof ] }
        [ invalid-struct-slot ]
    } case ;

: parse-struct-definition ( -- class slots )
    CREATE-CLASS 8 <vector> [ parse-struct-slots ] [ ] while >array ;
PRIVATE>

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;
SYNTAX: UNION-STRUCT:
    parse-struct-definition define-union-struct-class ;

SYNTAX: S{
    scan-word dup struct-slots parse-tuple-literal-slots parsed ;

SYNTAX: S@
    scan-word scan-object swap memory>struct parsed ;

! functor support

<PRIVATE
: scan-c-type` ( -- c-type/param )
    scan dup "{" = [ drop \ } parse-until >array ] [ >string-param ] if ;

: parse-struct-slot` ( accum -- accum )
    scan-string-param scan-c-type` \ } parse-until
    [ <struct-slot-spec> over push ] 3curry over push-all ;

: parse-struct-slots` ( accum -- accum more? )
    scan {
        { ";" [ f ] }
        { "{" [ parse-struct-slot` t ] }
        [ invalid-struct-slot ]
    } case ;
PRIVATE>

FUNCTOR-SYNTAX: STRUCT:
    scan-param parsed
    [ 8 <vector> ] over push-all
    [ parse-struct-slots` ] [ ] while
    [ >array define-struct-class ] over push-all ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "classes.struct.prettyprint" require ] when
