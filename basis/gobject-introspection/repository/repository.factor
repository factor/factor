! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: ;
IN: gobject-introspection.repository

TUPLE: repository
    namespace ;

TUPLE: namespace
    name
    identifier-prefixes
    symbol-prefixes
    aliases
    consts
    enums
    bitfields
    records
    unions
    boxeds
    callbacks
    classes
    interfaces
    functions ;

TUPLE: data-type
    name ;

TUPLE: simple-type < data-type
    element-types ;

TUPLE: array-type < data-type
    zero-terminated?
    fixed-size
    length
    element-type ;

TUPLE: inner-callback-type < data-type ;

TUPLE: varargs-type < data-type ;

TUPLE: alias
    name
    c-type
    type ;

TUPLE: const
    name
    value
    c-type
    type
    c-identifier ;

TUPLE: type
    name
    c-type
    get-type ;

TUPLE: enum-member
    name
    value
    c-identifier ;

TUPLE: enum < type
    members ;

TUPLE: record < type
    fields
    constructors
    methods
    functions
    disguised?
    struct-for ;

TUPLE: field
    name
    writable?
    bits
    type ;

TUPLE: union < type
    fields
    constructors
    methods
    functions ;

TUPLE: return
    type
    transfer-ownership ;

TUPLE: parameter
    name
    type
    direction
    allow-none?
    transfer-ownership ;

TUPLE: function
    name
    identifier
    return
    parameters
    throws? ;

TUPLE: callback < type
    return
    parameters
    throws? ;

TUPLE: class < type
    abstract?
    parent
    type-struct
    constructors
    methods
    functions
    signals ;

TUPLE: interface < type
    constructors
    methods
    functions
    signals ;

TUPLE: boxed < type ;

TUPLE: signal
    name
    return
    parameters ;

TUPLE: property
    name
    readable?
    writable?
    construct?
    construct-only?
    type ;
