! (c)2010 Joe Groff bsd license
USING: accessors definitions fry kernel locals.types namespaces parser
see sequences words ;
FROM: help.markup.private => link-effect? ;
IN: variables

PREDICATE: variable < word
    "variable-setter" word-prop ;

GENERIC: variable-setter ( word -- word' )

M: variable variable-setter "variable-setter" word-prop ;
M: local-reader variable-setter "local-writer" word-prop ;

SYNTAX: set:
    scan-object variable-setter suffix! ;

: [variable-getter] ( variable -- quot )
    '[ _ get ] ;
: [variable-setter] ( variable -- quot )
    '[ _ set ] ;

: (define-variable) ( word getter setter -- )
    [ (( -- value )) define-inline ]
    [
        [
            [ name>> "set: " prepend <uninterned-word> ]
            [ over "variable-setter" set-word-prop ] bi
        ] dip (( value -- )) define-inline
    ] bi-curry* bi ;

: define-variable ( word -- )
    dup [ [variable-getter] ] [ [variable-setter] ] bi (define-variable) ;

SYNTAX: VAR:
    CREATE-WORD define-variable ;    

M: variable definer drop \ VAR: f ;
M: variable definition drop f ;
M: variable link-effect? drop f ;
M: variable print-stack-effect? drop f ;

TUPLE: global-box value ;

PREDICATE: global-variable < variable
    "variable-setter" word-prop def>> first global-box? ;

: [global-getter] ( box -- quot )
    '[ _ value>> ] ;
: [global-setter] ( box -- quot )
    '[ _ (>>value) ] ;

: define-global ( word -- )
    global-box new [ [global-getter] ] [ [global-setter] ] bi (define-variable) ;

SYNTAX: GLOBAL:
    CREATE-WORD define-global ;

M: global-variable definer drop \ GLOBAL: f ;

