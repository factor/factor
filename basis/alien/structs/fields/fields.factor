! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private math namespaces
make sequences strings words effects combinators alien.c-types ;
IN: alien.structs.fields

TUPLE: field-spec name offset type reader writer ;

: reader-effect ( type spec -- effect )
    [ 1array ] [ name>> 1array ] bi* <effect> ;

PREDICATE: slot-reader < word "reading" word-prop >boolean ;

: set-reader-props ( class spec -- )
    2dup reader-effect
    over reader>>
    swap "declared-effect" set-word-prop
    reader>> swap "reading" set-word-prop ;

: writer-effect ( type spec -- effect )
    name>> swap 2array 0 <effect> ;

PREDICATE: slot-writer < word "writing" word-prop >boolean ;

: set-writer-props ( class spec -- )
    2dup writer-effect
    over writer>>
    swap "declared-effect" set-word-prop
    writer>> swap "writing" set-word-prop ;

: reader-word ( class name vocab -- word )
    [ "-" glue ] dip create ;

: writer-word ( class name vocab -- word )
    [ [ swap "set-" % % "-" % % ] "" make ] dip create ;

: <field-spec> ( struct-name vocab type field-name -- spec )
    field-spec new
        0 >>offset
        swap >>name
        swap expand-constants >>type
        3dup name>> swap reader-word >>reader
        3dup name>> swap writer-word >>writer
    2nip ;

: align-offset ( offset type -- offset )
    c-type-align align ;

: struct-offsets ( specs -- size )
    0 [
        [ type>> align-offset ] keep
        [ (>>offset) ] [ type>> heap-size + ] 2bi
    ] reduce ;

: define-struct-slot-word ( word quot spec effect -- )
    [ offset>> prefix ] dip define-inline ;

: define-getter ( type spec -- )
    [ set-reader-props ] keep
    [ reader>> ]
    [ type>> c-type-getter-boxer ]
    [ ] tri
    (( c-ptr -- value )) define-struct-slot-word ;

: define-setter ( type spec -- )
    [ set-writer-props ] keep
    [ writer>> ] [ type>> c-setter ] [ ] tri
    (( value c-ptr -- )) define-struct-slot-word ;

: define-field ( type spec -- )
    [ define-getter ] [ define-setter ] 2bi ;
