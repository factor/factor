! (c)Joe Groff bsd license
USING: accessors alien alien.c-types alien.structs
alien.structs.fields arrays byte-arrays classes classes.parser
classes.tuple classes.tuple.parser classes.tuple.private
combinators combinators.short-circuit combinators.smart fry
generalizations generic.parser kernel kernel.private lexer
libc macros make math math.order parser quotations sequences
slots slots.private struct-arrays vectors words ;
FROM: slots => reader-word writer-word ;
IN: classes.struct

! struct class

TUPLE: struct
    { (underlying) c-ptr read-only } ;

TUPLE: struct-slot-spec < slot-spec
    c-type ;

PREDICATE: struct-class < tuple-class
    \ struct subclass-of? ;

: struct-slots ( struct -- slots )
    "struct-slots" word-prop ;

! struct allocation

M: struct >c-ptr
    2 slot { c-ptr } declare ; inline

M: struct equal?
    {
        [ [ class ] bi@ = ]
        [ [ >c-ptr ] [ [ >c-ptr ] [ byte-length ] bi ] bi* memory= ]
    } 2&& ;

: memory>struct ( ptr class -- struct )
    over c-ptr? [ swap \ c-ptr bad-slot-value ] unless
    tuple-layout <tuple> [ 2 set-slot ] keep ;

: malloc-struct ( class -- struct )
    [ heap-size malloc ] keep memory>struct ; inline

: (struct) ( class -- struct )
    [ heap-size <byte-array> ] keep memory>struct ; inline

: <struct> ( class -- struct )
    dup "prototype" word-prop
    [ >c-ptr clone swap memory>struct ] [ (struct) ] if* ; inline

MACRO: <struct-boa> ( class -- quot: ( ... -- struct ) )
    [
        [ <wrapper> \ (struct) [ ] 2sequence ]
        [
            struct-slots
            [ length \ ndip ]
            [ [ name>> setter-word 1quotation ] map \ spread ] bi
        ] bi
    ] [ ] output>sequence ;

: pad-struct-slots ( values class -- values' class )
    [ struct-slots [ initial>> ] map over length tail append ] keep ;

: (reader-quot) ( slot -- quot )
    [ c-type>> c-type-getter-boxer ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

: (writer-quot) ( slot -- quot )
    [ c-type>> c-setter ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

: (boxer-quot) ( class -- quot )
    '[ _ memory>struct ] ;

: (unboxer-quot) ( class -- quot )
    drop [ >c-ptr ] ;

M: struct-class boa>object
    swap pad-struct-slots
    [ (struct) ] [ struct-slots ] bi 
    [ [ (writer-quot) call( value struct -- ) ] with 2each ] curry keep ;

! Struct slot accessors

GENERIC: struct-slot-values ( struct -- sequence )

M: struct-class reader-quot
    nip (reader-quot) ;

M: struct-class writer-quot
    nip (writer-quot) ;

: struct-slot-values-quot ( class -- quot )
    struct-slots
    [ name>> reader-word 1quotation ] map
    \ cleave [ ] 2sequence
    \ output>array [ ] 2sequence ;

: (define-struct-slot-values-method) ( class -- )
    [ \ struct-slot-values create-method-in ]
    [ struct-slot-values-quot ] bi define ;

: (define-byte-length-method) ( class -- )
    [ \ byte-length create-method-in ]
    [ heap-size \ drop swap [ ] 2sequence ] bi define ;

! Struct as c-type

: slot>field ( slot -- field )
    field-spec new swap {
        [ name>> >>name ]
        [ offset>> >>offset ]
        [ c-type>> >>type ]
        [ name>> reader-word >>reader ]
        [ name>> writer-word >>writer ]
    } cleave ;

: define-struct-for-class ( class -- )
    [
        {
            [ name>> ]
            [ "struct-size" word-prop ]
            [ "struct-align" word-prop ]
            [ struct-slots [ slot>field ] map ]
        } cleave
        struct-type (define-struct)
    ] [
        {
            [ name>> c-type ]
            [ (unboxer-quot) >>unboxer-quot ]
            [ (boxer-quot) >>boxer-quot ]
            [ >>boxed-class ]
        } cleave drop
    ] bi ;

: align-offset ( offset class -- offset' )
    c-type-align align ;

: struct-offsets ( slots -- size )
    0 [
        [ c-type>> align-offset ] keep
        [ (>>offset) ] [ c-type>> heap-size + ] 2bi
    ] reduce ;

: union-struct-offsets ( slots -- size )
    [ 0 >>offset c-type>> heap-size ] [ max ] map-reduce ;

: struct-align ( slots -- align )
    [ c-type>> c-type-align ] [ max ] map-reduce ;

M: struct-class c-type
    name>> c-type ;

M: struct-class c-type-align
    "struct-align" word-prop ;

M: struct-class c-type-getter
    drop [ swap <displaced-alien> ] ;

M: struct-class c-type-setter
    [ c-type-getter ] [ c-type-unboxer-quot ] [ heap-size ] tri
    '[ @ swap @ _ memcpy ] ;

M: struct-class c-type-boxer-quot
    (boxer-quot) ;

M: struct-class c-type-unboxer-quot
    (unboxer-quot) ;

M: struct-class heap-size
    "struct-size" word-prop ;

! class definition

: struct-prototype ( class -- prototype )
    [ heap-size <byte-array> ]
    [ memory>struct ]
    [ struct-slots ] tri
    [
        [ initial>> ]
        [ (writer-quot) ] bi
        over [ swapd [ call( value struct -- ) ] curry keep ] [ 2drop ] if
    ] each ;

: (struct-methods) ( class -- )
    [ (define-struct-slot-values-method) ]
    [ (define-byte-length-method) ] bi ;

: (struct-word-props) ( class slots size align -- )
    [
        [ "struct-slots" set-word-prop ]
        [ define-accessors ] 2bi
    ]
    [ "struct-size" set-word-prop ]
    [ "struct-align" set-word-prop ] tri-curry*
    [ tri ] 3curry
    [ dup struct-prototype "prototype" set-word-prop ]
    [ (struct-methods) ] tri ;

: check-struct-slots ( slots -- )
    [ c-type>> c-type drop ] each ;

: (define-struct-class) ( class slots offsets-quot -- )
    [ drop struct f define-tuple-class ]
    swap '[
        make-slots dup
        [ check-struct-slots ] _ [ struct-align [ align ] keep ] tri
        (struct-word-props)
    ]
    [ drop define-struct-for-class ] 2tri ; inline

: define-struct-class ( class slots -- )
    [ struct-offsets ] (define-struct-class) ;

: define-union-struct-class ( class slots -- )
    [ union-struct-offsets ] (define-struct-class) ;

ERROR: invalid-struct-slot token ;

: struct-slot-class ( c-type -- class' )
    c-type c-type-boxed-class
    dup \ byte-array = [ drop \ c-ptr ] when ;

: parse-struct-slot ( -- slot )
    struct-slot-spec new
    scan >>name
    scan [ >>c-type ] [ struct-slot-class >>class ] bi
    \ } parse-until [ dup empty? ] [ peel-off-attributes ] until drop ;
    
: parse-struct-slots ( slots -- slots' more? )
    scan {
        { ";" [ f ] }
        { "{" [ parse-struct-slot over push t ] }
        [ invalid-struct-slot ]
    } case ;

: parse-struct-definition ( -- class slots )
    CREATE-CLASS 8 <vector> [ parse-struct-slots ] [ ] while >array ;

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;
SYNTAX: UNION-STRUCT:
    parse-struct-definition define-union-struct-class ;

SYNTAX: S{
    scan-word dup struct-slots parse-tuple-literal-slots parsed ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "classes.struct.prettyprint" require ] when
