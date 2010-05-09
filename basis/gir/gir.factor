! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators gir.common gir.ffi gir.loader
kernel lexer locals namespaces sequences vocabs.parser xml ;
IN: gir

: with-child-vocab ( name quot -- )
    swap current-vocab name>>
    [ swap "." glue set-current-vocab call ] keep
    set-current-vocab ; inline

:: define-gir-vocab ( vocab-name file-name -- )
    file-name file>xml xml>repository

    vocab-name [ set-current-vocab ] [ current-lib set ] bi
    {
        [
            namespace>> name>> vocab-name swap
            lib-aliases get set-at
        ]
        [ ffi-vocab [ define-ffi-repository ] with-child-vocab ]
    } cleave ;

SYNTAX: IN-GIR: scan scan define-gir-vocab ;
