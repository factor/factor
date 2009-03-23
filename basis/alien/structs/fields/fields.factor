! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel kernel.private math namespaces
make sequences strings words effects combinators alien.c-types ;
IN: alien.structs.fields

TUPLE: field-spec name offset type reader writer ;

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

: define-getter ( spec -- )
    [ reader>> ] [ type>> c-type-getter-boxer ] [ ] tri
    (( c-ptr -- value )) define-struct-slot-word ;

: define-setter ( spec -- )
    [ writer>> ] [ type>> c-setter ] [ ] tri
    (( value c-ptr -- )) define-struct-slot-word ;

: define-field ( spec -- )
    [ define-getter ] [ define-setter ] bi ;
