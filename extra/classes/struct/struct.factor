! (c)Joe Groff bsd license
USING: accessors alien alien.c-types byte-arrays classes
classes.c-types classes.parser classes.tuple
classes.tuple.parser classes.tuple.private combinators
combinators.smart fry generalizations generic.parser kernel
kernel.private libc macros make math math.order quotations
sequences slots slots.private words ;
IN: classes.struct

! struct class

TUPLE: struct
    { (underlying) c-ptr read-only } ;

PREDICATE: struct-class < tuple-class
    \ struct subclass-of? ;

! struct allocation

M: struct >c-ptr
    2 slot { c-ptr } declare ; inline

: memory>struct ( ptr class -- struct )
    over c-ptr? [ swap \ c-ptr bad-slot-value ] unless
    tuple-layout <tuple> [ 2 set-slot ] keep ;

: malloc-struct ( class -- struct )
    [ heap-size malloc ] keep memory>struct ; inline

: <struct> ( class -- struct )
    [ heap-size <byte-array> ] keep memory>struct ; inline

M: struct-class new
    dup "prototype" word-prop
    [ >c-ptr clone swap memory>struct ] [ <struct> ] if* ; inline

MACRO: <struct-boa> ( class -- quot: ( ... -- struct ) )
    [
        [ \ <struct> [ ] 2sequence ]
        [
            "struct-slots" word-prop
            [ length \ ndip ]
            [ [ name>> setter-word 1quotation ] map \ spread ] bi
        ] bi
    ] [ ] output>sequence ;

M: struct-class boa
    <struct-boa> ; inline

: pad-struct-slots ( slots class -- slots' class )
    [ class-slots [ initial>> ] map over length tail append ] keep ;

M: struct-class boa>object
    swap pad-struct-slots
    [ <struct> swap ] [ "struct-slots" word-prop ] bi 
    [ name>> setter-word execute( struct value -- struct ) ] 2each ;

! Struct slot accessors

M: struct-class reader-quot
    nip
    [ class>> c-type-getter-boxer ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

: (writer-quot) ( slot -- quot )
    [ class>> c-setter ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

M: struct-class writer-quot
    nip (writer-quot) ;

M: struct-class class-slots
    "struct-slots" word-prop ;

: object-slots-quot ( class -- quot )
    "struct-slots" word-prop
    [ name>> reader-word 1quotation ] map
    \ cleave [ ] 2sequence
    \ output>array [ ] 2sequence ;

: (define-object-slots-method) ( class -- )
    [ \ object-slots create-method-in ]
    [ object-slots-quot ] bi define ;

! Struct as c-type

: align-offset ( offset class -- offset' )
    c-type-align align ;

: struct-offsets ( slots -- size )
    0 [
        [ class>> align-offset ] keep
        [ (>>offset) ] [ class>> heap-size + ] 2bi
    ] reduce ;

: struct-align ( slots -- align )
    [ class>> c-type-align ] [ max ] map-reduce ;

M: struct-class c-type ;

M: struct-class c-type-align
    "struct-align" word-prop ;

M: struct-class c-type-getter
    drop [ swap <displaced-alien> ] ;

M: struct-class c-type-setter
    [ c-type-getter ] [ c-type-unboxer-quot ] [ heap-size ] tri
    '[ @ swap @ _ memcpy ] ;

M: struct-class c-type-boxer-quot
    '[ _ memory>struct ] ;

M: struct-class c-type-unboxer-quot
    drop [ >c-ptr ] ;

M: struct-class heap-size
    "struct-size" word-prop ;

! class definition

: struct-prototype ( class -- prototype )
    [ heap-size <byte-array> ]
    [ memory>struct ]
    [ "struct-slots" word-prop ] tri
    [
        [ initial>> ]
        [ (writer-quot) ] bi
        over [ swapd [ call( value struct -- ) ] curry keep ] [ 2drop ] if
    ] each ;

: (define-struct-class) ( class slots size align -- )
    [
        [ "struct-slots" set-word-prop ]
        [ define-accessors ] 2bi
    ]
    [ "struct-size" set-word-prop ]
    [ "struct-align" set-word-prop ] tri-curry* tri ;

: check-struct-slots ( slots -- )
    [ class>> c-type drop ] each ;

: define-struct-class ( class slots -- )
    [ drop struct f define-tuple-class ] [
        make-slots dup
        [ check-struct-slots ] [ struct-offsets ] [ struct-align [ align ] keep ] tri
        (define-struct-class)
    ] [
        drop
        [ dup struct-prototype "prototype" set-word-prop ]
        [ (define-object-slots-method) ] bi
    ] 2tri ;

: parse-struct-definition ( -- class slots )
    CREATE-CLASS [ parse-tuple-slots ] { } make ;

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [ "classes.struct.prettyprint" require ] when
