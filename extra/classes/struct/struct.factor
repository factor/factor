USING: accessors alien alien.c-types byte-arrays classes
classes.c-types classes.parser classes.tuple
classes.tuple.parser classes.tuple.private fry kernel
kernel.private libc make math math.order sequences slots
slots.private words ;
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
    tuple-layout <tuple-boa> ; inline

: malloc-struct ( class -- struct )
    [ heap-size malloc ] keep memory>struct ; inline

: <struct> ( class -- struct )
    [ heap-size <byte-array> ] keep memory>struct ; inline

M: struct-class new
    dup "prototype" word-prop
    [ >c-ptr clone swap memory>struct ] [ <struct> ] if ; inline

! Struct slot accessors

M: struct-class reader-quot
    nip
    [ class>> c-type-getter-boxer ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

M: struct-class writer-quot
    nip
    [ class>> c-setter ]
    [ offset>> [ >c-ptr ] swap suffix ] bi prepend ;

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
    [ heap-size <byte-array> ] [ new [ 2 set-slot ] keep ] bi ; ! [ "struct-slots" word-prop ] tri
    ! [ [ initial>> ] [ name>> setter-word ] bi over [ execute( struct value -- struct ) ] [ 2drop ] if ] each ;

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
        [ check-struct-slots ] [ struct-offsets ] [ struct-align ] tri
        (define-struct-class)
    ] [ drop dup struct-prototype "prototype" set-word-prop ] 2tri ;

: parse-struct-definition ( -- class slots )
    CREATE-CLASS [ parse-tuple-slots ] { } make ;

SYNTAX: STRUCT:
    parse-struct-definition define-struct-class ;

