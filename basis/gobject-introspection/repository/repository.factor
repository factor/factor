! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: gobject-introspection.repository

TUPLE: node name ;

TUPLE: repository includes namespace ;

TUPLE: namespace < node
    prefix aliases consts classes interfaces records unions callbacks
    enums bitfields functions ;

TUPLE: alias < node target ;

TUPLE: typed < node type c-type ;

TUPLE: const < typed
    value c-identifier ffi ;

TUPLE: type-node < node
    type c-type type-name get-type ffi ;

TUPLE: field < typed
    writable? length? array-info ;

TUPLE: record < type-node
    fields constructors methods functions disguised? ;

TUPLE: union < type-node ;

TUPLE: class < record
    abstract? parent type-struct signals ;

TUPLE: interface < type-node
    methods ;

TUPLE: property < type-node
    readable? writable? construct? construct-only? ;

TUPLE: callable < type-node
    return parameters varargs? ;

TUPLE: function < callable identifier ;

TUPLE: callback < type-node return parameters varargs? ;

TUPLE: signal < callback ;

TUPLE: parameter < typed
    direction allow-none? length? transfer-ownership array-info
    local ;

TUPLE: return < typed
    transfer-ownership array-info local ;

TUPLE: type name namespace ;

TUPLE: array-info zero-terminated? fixed-size length ;

TUPLE: enum-member < node value c-identifier ;

TUPLE: enum < type-node members ;

