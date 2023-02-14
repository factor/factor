! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs combinators.short-circuit
gobject-introspection.common gobject-introspection.repository
kernel namespaces parser sequences sets ;
IN: gobject-introspection.types

SYMBOL: type-infos
type-infos [ H{ } ] initialize

SYMBOL: standard-types
standard-types [ V{ } ] initialize

TUPLE: type-info c-type ;

TUPLE: atomic-info < type-info ;
TUPLE: enum-info < type-info ;
TUPLE: bitfield-info < type-info ;
TUPLE: record-info < type-info ;
TUPLE: union-info < type-info ;
TUPLE: boxed-info < type-info ;
TUPLE: callback-info < type-info ;
TUPLE: class-info < type-info ;
TUPLE: interface-info < type-info ;

DEFER: find-type-info

PREDICATE: none-type < simple-type
    name>> "none" = ;

PREDICATE: atomic-type < simple-type
    find-type-info atomic-info? ;

PREDICATE: utf8-type < atomic-type
    name>> "utf8" = ;

PREDICATE: enum-type < simple-type
    find-type-info enum-info? ;

PREDICATE: bitfield-type < simple-type
    find-type-info bitfield-info? ;

PREDICATE: record-type < simple-type
    find-type-info record-info? ;

PREDICATE: union-type < simple-type
    find-type-info union-info? ;

PREDICATE: boxed-type < simple-type
    find-type-info boxed-info? ;

PREDICATE: callback-type < simple-type
    find-type-info callback-info? ;

PREDICATE: class-type < simple-type
    find-type-info class-info? ;

PREDICATE: interface-type < simple-type
    find-type-info interface-info? ;

PREDICATE: boxed-array-type < array-type name>> >boolean ;
PREDICATE: c-array-type < array-type name>> not ;
PREDICATE: fixed-size-array-type < c-array-type fixed-size>> >boolean ;

: standard-type? ( data-type -- ? )
    name>> standard-types get-global in? ;

: qualified-name ( name -- qualified-name )
    current-namespace-name get-global swap "." glue ;

: qualified-type-name ( data-type -- name )
    [ name>> ] keep {
        [ name>> CHAR: . swap member? ]
        [ none-type? ]
        [ standard-type? ]
    } 1|| [ qualified-name ] unless ;

ERROR: unknown-type-error type ;

: get-type-info ( data-type -- info )
    qualified-type-name
    [ type-infos get-global at ]
    [ unknown-type-error ] ?unless ;

: find-type-info ( data-type -- info/f )
    qualified-type-name type-infos get-global at ;

:: register-type ( c-type type-info name -- )
    type-info c-type >>c-type name
    type-infos get-global set-at ;

: register-standard-type ( c-type name -- )
    dup standard-types get-global adjoin
    atomic-info new swap register-type ;

: register-atomic-type ( c-type name -- )
    atomic-info new swap register-type ;

: register-enum-type ( c-type name -- )
    enum-info new swap register-type ;

: register-record-type ( c-type name -- )
    record-info new swap register-type ;

ERROR: deferred-type-error ;

<<
void* lookup-c-type clone
    [ drop deferred-type-error ] >>unboxer-quot
    [ drop deferred-type-error ] >>boxer-quot
    object >>boxed-class
"deferred-type" create-word-in typedef
>>
