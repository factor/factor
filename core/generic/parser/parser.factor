! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: parser kernel words generic namespaces inspector ;
IN: generic.parser

ERROR: not-in-a-method-error ;

M: not-in-a-method-error summary
    drop "call-next-method can only be called in a method definition" ;

: CREATE-GENERIC ( -- word ) CREATE dup reset-word ;

: create-method-in ( class generic -- method )
    create-method f set-word dup save-location ;

: CREATE-METHOD ( -- method )
    scan-word bootstrap-word scan-word create-method-in ;

SYMBOL: current-class
SYMBOL: current-generic

: with-method-definition ( quot -- parsed )
    [
        >r
        [ "method-class" word-prop current-class set ]
        [ "method-generic" word-prop current-generic set ]
        [ ] tri
        r> call
    ] with-scope ; inline

: (M:) ( method def -- )
    CREATE-METHOD [ parse-definition ] with-method-definition ;

