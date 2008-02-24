! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel sequences namespaces assocs hashtables
definitions kernel.private classes classes.private
quotations arrays vocabs effects ;
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
    dup { "unannotated-def" } reset-props
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

PREDICATE: word method-body "method" word-prop >boolean ;

M: method-body stack-effect
    "method" word-prop method-generic stack-effect ;

: <method-word> ( quot class generic -- word )
    [ make-method-def ] 2keep
    method-word-name f <word>
    dup rot define
    dup xref ;

: <method> ( quot class generic -- method )
    check-method
    [ <method-word> ] 3keep f \ method construct-boa
    dup method-word over "method" set-word-prop ;

: redefine-method ( quot class generic -- )
    [ method set-method-def ] 3keep
    [ make-method-def ] 2keep
    method method-word swap define ;

: define-method ( quot class generic -- )
    >r bootstrap-word r>
    2dup method [
        redefine-method
    ] [
        [ <method> ] 2keep
        [ set-at ] with-methods
    ] if ;

: define-default-method ( generic combination -- )
    dupd make-default-method object bootstrap-word pick <method>
    "default-method" set-word-prop ;

! Definition protocol
M: method-spec where
    dup first2 method [ method-word ] [ second ] ?if where ;

M: method-spec set-where
    first2 method method-word set-where ;

M: method-spec definer
    drop \ M: \ ; ;

M: method-spec definition
    first2 method dup [ method-def ] when ;

: forget-method ( class generic -- )
    check-method
    [ delete-at* ] with-methods
    [ method-word forget-word ] [ drop ] if ;

M: method-spec forget*
    first2 forget-method ;

M: method-body definer
    drop \ M: \ ; ;

M: method-body definition
    "method" word-prop method-def ;

M: method-body forget*
    "method" word-prop
    { method-specializer method-generic } get-slots
    forget-method ;

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

: define-generic ( word combination -- )
    over "combination" word-prop over = [
        2drop
    ] [
        2dup "combination" set-word-prop
        over H{ } clone "methods" set-word-prop
        dupd define-default-method
        make-generic
    ] if ;

GENERIC: subwords ( word -- seq )

M: word subwords drop f ;

M: generic subwords
    dup "methods" word-prop values
    swap "default-method" word-prop add
    [ method-word ] map ;

M: generic forget-word
    dup subwords [ forget-word ] each (forget-word) ;

: xref-generics ( -- )
    all-words [ subwords [ xref ] each ] each ;
