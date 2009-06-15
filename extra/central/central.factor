USING: destructors kernel lexer namespaces parser sequences words ;

IN: central

: define-central-getter ( word -- )
    dup [ get ] curry (( -- obj )) define-declared ;

: define-centrals ( str -- getter setter )
    [ create-in dup define-central-getter ]
    [ "with-" prepend create-in dup make-inline ] bi ;

: central-setter-def ( word with-word -- with-word quot )
    [ with-variable ] with ;

: disposable-setter-def ( word with-word -- with-word quot )
    [ pick [ drop with-variable ] with-disposal ] with ;

: declare-central ( with-word quot -- ) (( object quot -- )) define-declared ;

: define-central ( word-name -- )
    define-centrals central-setter-def declare-central ;

: define-disposable-central ( word-name -- )
    define-centrals disposable-setter-def declare-central ;

SYNTAX: CENTRAL: ( -- ) scan define-central ;

SYNTAX: DISPOSABLE-CENTRAL: ( -- ) scan define-disposable-central ;