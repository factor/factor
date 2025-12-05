! Copyright (C) 2003, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel sequences namespaces ;
IN: make

SYMBOL: building

<PRIVATE

: make-sequence ( quot exemplar -- seq )
    [
        32 swap new-resizable [
            building [ call ] with-variable
        ] keep
    ] keep like ; inline

: make-assoc ( quot exemplar -- assoc )
    5 swap new-assoc [
        building [ call ] with-variable
    ] keep ; inline

PRIVATE>

: make ( quot exemplar -- seq )
    dup sequence? [ make-sequence ] [ make-assoc ] if ; inline

: , ( elt -- ) building get push ;

: % ( seq -- ) building get push-all ;

: ,, ( value key -- ) building get set-at ;

: %% ( assoc -- ) building get swap assoc-union! drop ;

: ,+ ( n key -- ) building get at+ ;

: ,% ( elt key -- ) building get push-at ;
