! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators gobject-introspection.common
gobject-introspection.ffi gobject-introspection.loader
gobject-introspection.types kernel lexer locals namespaces parser
sequences xml ;
IN: gobject-introspection

<PRIVATE

:: define-gir-vocab ( file-name -- )
    file-name file>xml xml>repository
    {
        [ namespace>> name>> current-namespace-name set-global ]
        [ def-ffi-repository ]
    } cleave
    V{ } clone implement-structs set-global ;

PRIVATE>

SYNTAX: GIR: scan define-gir-vocab ;

SYNTAX: IMPLEMENT-STRUCTS:
    ";" parse-tokens
    implement-structs [ swap append! ] change-global ;

SYNTAX: FOREIGN-ATOMIC-TYPE:
    scan-token scan-object swap register-atomic-type ;

SYNTAX: FOREIGN-ENUM-TYPE:
    scan-token scan-object swap register-enum-type ;

SYNTAX: FOREIGN-RECORD-TYPE:
    scan-token scan-object swap register-record-type ;
