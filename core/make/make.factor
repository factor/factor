! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces ;
IN: make

SYMBOL: building

: make ( quot exemplar -- seq )
    [
        [
            32 swap new-resizable [
                building set call
            ] keep
        ] keep like
    ] with-scope ; inline

: , ( elt -- ) building get push ;

: % ( seq -- ) building get push-all ;
