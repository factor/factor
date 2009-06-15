USING: kernel lexer namespaces parser sequences words ;

IN: central

: define-central-getter ( word -- )
    dup [ get ] curry (( -- obj )) define-declared ;

: define-central-setter ( word with-word -- )
    [ with-variable ] with (( object quot -- )) define-declared ;

: define-central ( word-name -- )
    [ create-in dup define-central-getter ] keep
    "with-" prepend create-in [ define-central-setter ] keep
    make-inline ;

SYNTAX: CENTRAL: ( -- ) scan define-central ;