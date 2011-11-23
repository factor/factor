! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors words kernel sequences namespaces make assocs
hashtables definitions kernel.private classes classes.private
classes.algebra quotations arrays vocabs effects combinators
sets classes.maybe classes.algebra.private ;
FROM: namespaces => set ;
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

PREDICATE: method < word
    "method-generic" word-prop >boolean ;

ERROR: method-lookup-failed class generic ;

: ?lookup-method ( class generic -- method/f )
    "methods" word-prop at ;

: lookup-method ( class generic -- method )
    2dup ?lookup-method [ 2nip ] [ method-lookup-failed ] if* ;

<PRIVATE

: interesting-class? ( class1 class2 -- ? )
    {
        ! Case 1: no intersection. Discard and keep going
        { [ 2dup classes-intersect? not ] [ 2drop t ] }
        ! Case 2: class1 contained in class2. Add to
        ! interesting set and keep going.
        { [ 2dup class<= ] [ nip , t ] }
        ! Case 3: class1 and class2 are incomparable. Give up
        [ 2drop f ]
    } cond ;

: interesting-classes ( class classes -- interesting/f )
    [ [ interesting-class? ] with all? ] { } make and ;

PRIVATE>

: method-classes ( generic -- classes )
    "methods" word-prop keys ;

: order ( generic -- seq )
    method-classes sort-classes ;

: nearest-class ( class generic -- class/f )
    method-classes interesting-classes smallest-class ;

: method-for-class ( class generic -- method/f )
    [ nip ] [ nearest-class ] 2bi dup [ swap ?lookup-method ] [ 2drop f ] if ;

GENERIC: effective-method ( generic -- method )

\ effective-method t "no-compile" set-word-prop

: next-method-class ( class generic -- class/f )
    method-classes [ class< ] with filter smallest-class ;

: next-method ( class generic -- method/f )
    [ next-method-class ] keep ?lookup-method ;

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

: check-method ( classoid generic -- class generic )
    2dup [ classoid? ] [ generic? ] bi* and [
        \ check-method boa throw
    ] unless ; inline

: remake-generic ( generic -- )
    dup outdated-generics get set-in-unit ;

: remake-generics ( -- )
    outdated-generics get keys [ generic? ] filter [ make-generic ] each ;

GENERIC: update-generic ( class generic -- )

: with-methods ( class generic quot -- )
    [ "methods" word-prop ] prepose [ update-generic ] 2bi ; inline

GENERIC# method-word-name 1 ( class generic -- string )

M: class method-word-name ( class generic -- string )
    [ name>> ] bi@ "=>" glue ;

M: maybe method-word-name
    [ class>> name>> ] [ name>> ] bi* "=>" glue ;

M: method parent-word
    "method-generic" word-prop ;

M: method crossref?
    "forgotten" word-prop not ;

: method-word-props ( class generic -- assoc )
    [
        "method-generic" set
        "method-class" set
    ] H{ } make-assoc ;

: <method> ( class generic -- method )
    check-method
    [ method-word-name f <word> ] [ method-word-props ] 2bi
    >>props ;

GENERIC: implementor-classes ( obj -- class )

M: maybe implementor-classes class>> 1array ;

M: class implementor-classes 1array ;

M: anonymous-union implementor-classes members>> ;

M: anonymous-intersection implementor-classes participants>> ;

: with-implementors ( class generic quot -- )
    [ swap implementor-classes [ implementors-map get at ] map ] dip call ; inline

: reveal-method ( method classes generic -- )
    [ [ [ conjoin ] with each ] with-implementors ]
    [ [ set-at ] with-methods ]
    2bi ;

: create-method ( class generic -- method )
    2dup ?lookup-method dup [ 2nip dup reset-generic ] [
        drop
        [ <method> dup ] 2keep
        reveal-method
        reset-caches
    ] if ;

PREDICATE: default-method < word "default" word-prop ;

: <default-method> ( generic combination -- method )
    [ drop object bootstrap-word swap <method> ] [ make-default-method ] 2bi
    [ define ] [ drop t "default" set-word-prop ] [ drop ] 2tri ;

: define-default-method ( generic combination -- )
    dupd <default-method> "default-method" set-word-prop ;

! Definition protocol
M: method definer
    drop \ M: \ ; ;

M: method forget*
    dup "forgotten" word-prop [ drop ] [
        [
            dup default-method? [ drop ] [
                [
                    [ "method-class" word-prop ]
                    [ "method-generic" word-prop ] bi
                    2dup ?lookup-method
                ] keep eq?
                [
                    [ [ delete-at ] with-methods ]
                    [ [ [ delete-at ] with each ] with-implementors ] 2bi
                    reset-caches
                ] [ 2drop ] if
            ] if
        ]
        [ call-next-method ] bi
    ] if ;

: define-generic ( word combination effect -- )
    [ nip swap set-stack-effect ]
    [
        drop
        2dup [ "combination" word-prop ] dip = [ 2drop ] [
            {
                [ drop reset-generic ]
                [ "combination" set-word-prop ]
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

M: class forget-methods
    [ implementors ] [ [ swap ?lookup-method ] curry ] bi map forget-all ;
