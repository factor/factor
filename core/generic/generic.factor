! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel sequences namespaces assocs hashtables
definitions kernel.private classes classes.private
quotations arrays vocabs ;
IN: generic

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop f f ;

M: generic definition drop f ;

GENERIC: perform-combination ( word combination -- quot )

: make-generic ( word -- )
    dup
    dup "combination" word-prop perform-combination
    define-compound ;

: ?make-generic ( word -- )
    [ [ ] define-compound ] [ make-generic ] if-bootstrapping ;

: init-methods ( word -- )
     dup "methods" word-prop
     H{ } assoc-like
     "methods" set-word-prop ;

: define-generic ( word combination -- )
    dupd "combination" set-word-prop
    dup init-methods ?make-generic ;

TUPLE: method loc def ;

: <method> ( def -- method )
    { set-method-def } \ method construct ;

M: f method-def ;
M: f method-loc ;
M: quotation method-def ;
M: quotation method-loc drop f ;

: method ( class generic -- method/f )
    "methods" word-prop at ;

PREDICATE: pair method-spec
    first2 generic? swap class? and ;

: order ( generic -- seq )
    "methods" word-prop keys sort-classes ;

: sort-methods ( assoc -- newassoc )
    [ keys sort-classes ] keep
    [ dupd at method-def 2array ] curry map ;

: methods ( word -- assoc )
    "methods" word-prop sort-methods ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    over class? over generic? and [
        \ check-method construct-boa throw
    ] unless ;

: with-methods ( word quot -- )
    swap [ "methods" word-prop swap call ] keep ?make-generic ;
    inline

: define-method ( method class generic -- )
    >r bootstrap-word r> check-method
    [ set-at ] with-methods ;

! Definition protocol
M: method-spec where
    dup first2 method method-loc [ ] [ second where ] ?if ;

M: method-spec set-where first2 method set-method-loc ;

M: method-spec definer drop \ M: \ ; ;

M: method-spec definition first2 method method-def ;

M: method-spec forget first2 [ delete-at ] with-methods ;

: implementors* ( classes -- words )
    all-words [
        "methods" word-prop keys
        swap [ key? ] curry contains?
    ] curry* subset ;

: implementors ( class -- seq )
    dup associate implementors* ;

: forget-methods ( class -- )
    [ implementors ] keep [ swap 2array forget ] curry each ;

M: class forget ( class -- )
    dup forget-methods
    dup uncache-class
    forget-word ;

M: class update-methods ( class -- )
    [ drop ]
    [ class-usages implementors* [ make-generic ] each ]
    if-bootstrapping ;
