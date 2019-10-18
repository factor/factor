! Copyright (C) 2005, 2006 Eduardo Cavazos

! Thanks to Mackenzie Straight for the idea

USING: accessors kernel parser lexer words words.symbol
namespaces sequences quotations ;

IN: vars

: define-var-getter ( word -- )
    [ name>> ">" append create-in ] [ [ get ] curry ] bi
    (( -- value )) define-declared ;

: define-var-setter ( word -- )
    [ name>> ">" prepend create-in ] [ [ set ] curry ] bi
    (( value -- )) define-declared ;

: define-var ( str -- )
    create-in
    [ define-symbol ]
    [ define-var-getter ]
    [ define-var-setter ] tri ;

SYNTAX: VAR: ! var
    scan define-var ;

: define-vars ( seq -- )
    [ define-var ] each ;

SYNTAX: VARS: ! vars ...
    ";" parse-tokens define-vars ;
