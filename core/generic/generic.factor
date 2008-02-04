! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel sequences namespaces assocs hashtables
definitions kernel.private classes classes.private
quotations arrays vocabs ;
IN: generic

! Method combination protocol
GENERIC: perform-combination ( word combination -- quot )

M: object perform-combination
    #! We delay the invalid method combination error for a
    #! reason. If we call forget-vocab on a vocabulary which
    #! defines a method combination, a generic using this
    #! method combination, and a method on the generic, and the
    #! method combination is forgotten first, then forgetting
    #! the method will throw an error. We don't want that.
    nip [ "Invalid method combination" throw ] curry [ ] like ;

GENERIC: method-prologue ( class combination -- quot )

M: object method-prologue 2drop [ ] ;

GENERIC: make-default-method ( generic combination -- method )

PREDICATE: word generic "combination" word-prop >boolean ;

M: generic definer drop f f ;

M: generic definition drop f ;

: make-generic ( word -- )
    dup dup "combination" word-prop perform-combination define ;

TUPLE: method word def specializer generic loc ;

: method ( class generic -- method/f )
    "methods" word-prop at ;

PREDICATE: pair method-spec
    first2 generic? swap class? and ;

: order ( generic -- seq )
    "methods" word-prop keys sort-classes ;

: methods ( word -- assoc )
    "methods" word-prop
    [ keys sort-classes ] keep
    [ dupd at method-word ] curry { } map>assoc ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    over class? over generic? and [
        \ check-method construct-boa throw
    ] unless ;

: with-methods ( word quot -- )
    swap [ "methods" word-prop swap call ] keep make-generic ;
    inline

: method-word-name ( class word -- string )
    word-name "/" rot word-name 3append ;

: make-method-def ( quot word combination -- quot )
    "combination" word-prop method-prologue swap append ;

: <method-word> ( quot class generic -- word )
    [ make-method-def ] 2keep
    [ method-word-name f <word> dup ] keep
    "parent-generic" set-word-prop
    dup rot define ;

: <method> ( quot class generic -- method )
    check-method
    [ <method-word> ] 3keep f \ method construct-boa ;

: define-method ( quot class generic -- )
    >r bootstrap-word r>
    [ <method> ] 2keep
    [ set-at ] with-methods ;

: define-default-method ( generic combination -- )
    dupd make-default-method object bootstrap-word pick <method>
    "default-method" set-word-prop ;

! Definition protocol
M: method-spec where
    dup first2 method [ method-loc ] [ second where ] ?if ;

M: method-spec set-where first2 method set-method-loc ;

M: method-spec definer drop \ M: \ ; ;

M: method-spec definition
    first2 method dup [ method-def ] when ;

: forget-method ( class generic -- )
    check-method [ delete-at ] with-methods ;

M: method-spec forget* first2 forget-method ;

: implementors* ( classes -- words )
    all-words [
        "methods" word-prop keys
        swap [ key? ] curry contains?
    ] with subset ;

: implementors ( class -- seq )
    dup associate implementors* ;

: forget-methods ( class -- )
    [ implementors ] keep [ swap 2array ] curry map forget-all ;

M: class forget* ( class -- )
    dup forget-methods
    dup uncache-class
    forget-word ;

M: assoc update-methods ( assoc -- )
    implementors* [ make-generic ] each ;

: init-methods ( word -- )
     dup "methods" word-prop
     H{ } assoc-like
     "methods" set-word-prop ;

: define-generic ( word combination -- )
    2dup "combination" set-word-prop
    dupd define-default-method
    dup init-methods
    make-generic ;
