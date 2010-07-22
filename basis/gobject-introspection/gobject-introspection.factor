! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators gobject-introspection.common
gobject-introspection.ffi gobject-introspection.loader
kernel lexer locals math namespaces sequences vocabs.parser xml ;
IN: gobject-introspection

: with-child-vocab ( name quot -- )
    swap current-vocab name>>
    [ swap "." glue set-current-vocab call ] keep
    set-current-vocab ; inline

:: define-gir-vocab ( file-name -- )
    file-name file>xml xml>repository

    current-vocab name>> dup ffi-vocab tail?
    [ ffi-vocab length 1 + head* current-lib set-global ]
    [ drop ] if ! throw the error
    {
        [ define-ffi-repository ]
    } cleave
    f implement-structs set-global ;

SYNTAX: GIR: scan define-gir-vocab ;

SYNTAX: IMPLEMENT-STRUCTS:
    ";" parse-tokens implement-structs set-global ;
