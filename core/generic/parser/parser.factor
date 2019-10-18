! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel words generic namespaces effects.parser ;
IN: generic.parser

ERROR: not-in-a-method-error ;

: CREATE-GENERIC ( -- word ) CREATE dup reset-word ;

: (GENERIC:) ( quot -- )
    [ CREATE-GENERIC ] dip call complete-effect define-generic ; inline

: create-method-in ( class generic -- method )
    create-method dup set-word dup save-location ;

: define-inline-method ( class generic quot -- )
    [ create-method-in ] dip [ define ] [ drop make-inline ] 2bi ;

: CREATE-METHOD ( -- method )
    scan-word bootstrap-word scan-word create-method-in ;

SYMBOL: current-method

: with-method-definition ( method quot -- )
    over current-method set call current-method off ; inline

: (M:) ( -- method def )
    CREATE-METHOD [ parse-definition ] with-method-definition ;

