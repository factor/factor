! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words kernel sequences namespaces make assocs
hashtables definitions kernel.private classes classes.private
classes.algebra quotations arrays vocabs effects combinators
sets ;
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

: specific-method ( class generic -- method/f )
    [ nip ] [ order min-class ] 2bi
    dup [ swap method ] [ 2drop f ] if ;

GENERIC: effective-method ( generic -- method )

: next-method-class ( class generic -- class/f )
    order [ class<= ] with filter reverse dup length 1 =
    [ drop f ] [ second ] if ;

: next-method ( class generic -- method/f )
    [ next-method-class ] keep method ;

GENERIC: next-method-quot* ( class generic combination -- quot )

: next-method-quot ( method -- quot )
    next-method-quot-cache get [
        [ "method-class" word-prop ]
        [
            "method-generic" word-prop
            dup "combination" word-prop
        ] bi next-method-quot*
    ] cache ;

ERROR: no-next-method method ;

: (call-next-method) ( method -- )
    dup next-method-quot [ call ] [ no-next-method ] ?if ;

TUPLE: check-method class generic ;

: check-method ( class generic -- class generic )
    2dup [ class? ] [ generic? ] bi* and [
        \ check-method boa throw
    ] unless ; inline

: changed-generic ( class generic -- )
    changed-generics get
    [ [ [ class-or ] when* ] change-at ] [ no-compilation-unit ] if* ;

: remake-generic ( generic -- )
    dup outdated-generics get set-in-unit ;

: remake-generics ( -- )
    outdated-generics get keys [ generic? ] filter [ make-generic ] each ;

: with-methods ( class generic quot -- )
    [ drop changed-generic ]
    [ [ "methods" word-prop ] dip call ]
    [ drop remake-generic drop ]
    3tri ; inline

: method-word-name ( class word -- string )
    [ name>> ] bi@ "=>" glue ;

PREDICATE: method-body < word
    "method-generic" word-prop >boolean ;

M: method-spec stack-effect
    first2 method stack-effect ;

M: method-body stack-effect
    "method-generic" word-prop stack-effect ;

M: method-body crossref?
    "forgotten" word-prop not ;

: method-word-props ( class generic -- assoc )
    [
        "method-generic" set
        "method-class" set
    ] H{ } make-assoc ;

: <method> ( class generic -- method )
    check-method
    [ method-word-props ] 2keep
    method-word-name f <word>
    swap >>props ;

: with-implementors ( class generic quot -- )
    [ swap implementors-map get at ] dip call ; inline

: reveal-method ( method class generic -- )
    [ [ conjoin ] with-implementors ]
    [ [ set-at ] with-methods ]
    2bi ;

: create-method ( class generic -- method )
    2dup method dup [ 2nip dup reset-generic ] [
        drop
        [ <method> dup ] 2keep
        reveal-method
        reset-caches
    ] if ;

PREDICATE: default-method < word "default" word-prop ;

M: default-method irrelevant? drop t ;

: <default-method> ( generic combination -- method )
    [ drop object bootstrap-word swap <method> ] [ make-default-method ] 2bi
    [ define ] [ drop t "default" set-word-prop ] [ drop ] 2tri ;

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
    first2 method [ forgotten-definition ] [ forget* ] bi ;

M: method-spec smart-usage
    second smart-usage ;

M: method-body definer
    drop \ M: \ ; ;

M: method-body forget*
    dup "forgotten" word-prop [ drop ] [
        [
            dup default-method? [ drop ] [
                [
                    [ "method-class" word-prop ]
                    [ "method-generic" word-prop ] bi
                    2dup method
                ] keep eq?
                [
                    [ [ delete-at ] with-methods ]
                    [ [ delete-at ] with-implementors ] 2bi
                    reset-caches
                ] [ 2drop ] if
            ] if
        ]
        [ call-next-method ] bi
    ] if ;

M: method-body smart-usage
    "method-generic" word-prop smart-usage ;

M: sequence update-methods ( class seq -- )
    implementors [
        [ changed-generic ] [ remake-generic drop ] 2bi
    ] with each ;

: define-generic ( word combination effect -- )
    [ nip swap set-stack-effect ]
    [
        drop
        2dup [ "combination" word-prop ] dip = [ 2drop ] [
            {
                [ "combination" set-word-prop ]
                [ drop "methods" word-prop values forget-all ]
                [ drop H{ } clone "methods" set-word-prop ]
                [ define-default-method ]
            }
            2cleave
        ] if
    ]
    [ 2drop remake-generic ] 3tri ;

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
