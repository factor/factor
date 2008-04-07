! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words kernel sequences namespaces assocs hashtables
definitions kernel.private classes classes.private
classes.algebra quotations arrays vocabs effects ;
IN: generic

! Method combination protocol
GENERIC: perform-combination ( word combination -- )

GENERIC: make-default-method ( generic combination -- method )

PREDICATE: generic < word
    "combination" word-prop >boolean ;

M: generic definition drop f ;

: make-generic ( word -- )
    [ { "unannotated-def" } reset-props ]
    [ dup "combination" word-prop perform-combination ]
    bi ;

: method ( class generic -- method/f )
    "methods" word-prop at ;

PREDICATE: method-spec < pair
    first2 generic? swap class? and ;

: order ( generic -- seq )
    "methods" word-prop keys sort-classes ;

GENERIC: effective-method ( ... generic -- method )

: next-method-class ( class generic -- class/f )
    order [ class< ] with subset reverse dup length 1 =
    [ drop f ] [ second ] if ;

: next-method ( class generic -- class/f )
    [ next-method-class ] keep method ;

GENERIC: next-method-quot* ( class generic -- quot )

: next-method-quot ( class generic -- quot )
    dup "combination" word-prop next-method-quot* ;

: (call-next-method) ( class generic -- )
    next-method-quot call ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    over class? over generic? and [
        \ check-method construct-boa throw
    ] unless ; inline

: with-methods ( generic quot -- )
    swap [ "methods" word-prop swap call ] keep make-generic ;
    inline

: method-word-name ( class word -- string )
    word-name "/" rot word-name 3append ;

PREDICATE: method-body < word
    "method-generic" word-prop >boolean ;

M: method-body stack-effect
    "method-generic" word-prop stack-effect ;

M: method-body crossref?
    drop t ;

: method-word-props ( class generic -- assoc )
    [
        "method-generic" set
        "method-class" set
    ] H{ } make-assoc ;

: <method> ( class generic -- method )
    check-method
    [ method-word-props ] 2keep
    method-word-name f <word>
    [ set-word-props ] keep ;

: reveal-method ( method class generic -- )
    [ set-at ] with-methods ;

: create-method ( class generic -- method )
    2dup method dup [
        2nip
    ] [
        drop [ <method> dup ] 2keep reveal-method
    ] if ;

: <default-method> ( generic combination -- method )
    object bootstrap-word pick <method>
    [ -rot make-default-method define ] keep ;

: define-default-method ( generic combination -- )
    dupd <default-method> "default-method" set-word-prop ;

! Definition protocol
M: method-spec where
    dup first2 method [ ] [ second ] ?if where ;

M: method-spec set-where
    first2 method set-where ;

M: method-spec definer
    first2 method definer ;

M: method-spec definition
    first2 method definition ;

M: method-spec forget*
    first2 method forget* ;

M: method-body definer
    drop \ M: \ ; ;

M: method-body forget*
    dup "forgotten" word-prop [ drop ] [
        [
            [   "method-class" word-prop ]
            [ "method-generic" word-prop ] bi
            dup generic? [
                [ delete-at* ] with-methods
                [ call-next-method ] [ drop ] if
            ] [ 2drop ] if
        ]
        [ t "forgotten" set-word-prop ] bi
    ] if ;

: implementors* ( classes -- words )
    all-words [
        "methods" word-prop keys
        swap [ key? ] curry contains?
    ] with subset ;

: implementors ( class -- seq )
    dup associate implementors* ;

: forget-methods ( class -- )
    [ implementors ] [ [ swap 2array ] curry ] bi map forget-all ;

M: class forget* ( class -- )
    [ forget-methods ]
    [ update-map- ]
    [ call-next-method ]
    tri ;

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

M: generic subwords
    [
        [ "default-method" word-prop , ]
        [ "methods" word-prop values % ]
        [ "engines" word-prop % ]
        tri
    ] { } make ;

M: generic forget*
    [ subwords forget-all ] [ call-next-method ] bi ;

: xref-generics ( -- )
    all-words [ subwords [ xref ] each ] each ;
