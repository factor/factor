! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel kernel.private slots.private math
namespaces sequences vectors words quotations definitions
hashtables layouts combinators sequences.private generic
classes classes.algebra classes.private generic.standard.engines
generic.standard.engines.tag generic.standard.engines.predicate
generic.standard.engines.tuple accessors ;
IN: generic.standard

GENERIC: dispatch# ( word -- n )

M: word dispatch# "combination" word-prop dispatch# ;

: unpickers
    {
        [ nip ]
        [ >r nip r> swap ]
        [ >r >r nip r> r> -rot ]
    } ; inline

: unpicker ( -- quot ) \ (dispatch#) get unpickers nth ;

ERROR: no-method object generic ;

: error-method ( word -- quot )
    picker swap [ no-method ] curry append ;

: empty-method ( word -- quot )
    [
        picker % [ delegate dup ] %
        unpicker over suffix ,
        error-method \ drop prefix , \ if ,
    ] [ ] make ;

: default-method ( word -- pair )
    "default-method" word-prop
    object bootstrap-word swap 2array ;

: push-method ( method specializer atomic assoc -- )
    [
        [ H{ } clone <predicate-dispatch-engine> ] unless*
        [ methods>> set-at ] keep
    ] change-at ;

: flatten-method ( class method assoc -- )
    >r >r dup flatten-class keys swap r> r> [
        >r spin r> push-method
    ] 3curry each ;

: flatten-methods ( assoc -- assoc' )
    H{ } clone [
        [
            flatten-method
        ] curry assoc-each
    ] keep ;

: <big-dispatch-engine> ( assoc -- engine )
    flatten-methods
    convert-tuple-methods
    convert-hi-tag-methods
    <lo-tag-dispatch-engine> ;

: find-default ( methods -- quot )
    #! Side-effects methods.
    object bootstrap-word swap delete-at* [
        drop generic get "default-method" word-prop 1quotation
    ] unless ;

: mangle-method ( method generic -- quot )
    [ 1quotation ] [ extra-values \ drop <repetition> ] bi*
    prepend [ ] like ;

: single-combination ( word -- quot )
    [
        object bootstrap-word assumed set {
            [ generic set ]
            [ "engines" word-prop forget-all ]
            [ V{ } clone "engines" set-word-prop ]
            [
                "methods" word-prop
                [ generic get mangle-method ] assoc-map
                [ find-default default set ]
                [
                    generic get "inline" word-prop [
                        <predicate-dispatch-engine>
                    ] [
                        <big-dispatch-engine>
                    ] if
                ] bi
                engine>quot
            ]
        } cleave
    ] with-scope ;

ERROR: inconsistent-next-method class generic ;

ERROR: no-next-method class generic ;

: single-next-method-quot ( class generic -- quot )
    [
        [ drop [ instance? ] curry % ]
        [
            2dup next-method
            [ 2nip 1quotation ]
            [ [ no-next-method ] 2curry ] if* ,
        ]
        [ [ inconsistent-next-method ] 2curry , ]
        2tri
        \ if ,
    ] [ ] make ;

: single-effective-method ( obj word -- method )
    [ order [ instance? ] with find-last nip ] keep method ;

TUPLE: standard-combination # ;

C: <standard-combination> standard-combination

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop #>> zero? ;

: define-simple-generic ( word -- )
    T{ standard-combination f 0 } define-generic ;

: with-standard ( combination quot -- quot' )
    >r #>> (dispatch#) r> with-variable ; inline

M: standard-generic extra-values drop 0 ;

M: standard-combination make-default-method
    [ empty-method ] with-standard ;

M: standard-combination perform-combination
    [ drop ] [ [ single-combination ] with-standard ] 2bi define ;

M: standard-combination dispatch# #>> ;

M: standard-combination next-method-quot*
    [
        single-next-method-quot picker prepend
    ] with-standard ;

M: standard-generic effective-method
    [ dispatch# (picker) call ] keep single-effective-method ;

TUPLE: hook-combination var ;

C: <hook-combination> hook-combination

PREDICATE: hook-generic < generic
    "combination" word-prop hook-combination? ;

: with-hook ( combination quot -- quot' )
    0 (dispatch#) [
        dip var>> [ get ] curry prepend
    ] with-variable ; inline

M: hook-combination dispatch# drop 0 ;

M: hook-generic extra-values drop 1 ;

M: hook-generic effective-method
    [ "combination" word-prop var>> get ] keep
    single-effective-method ;

M: hook-combination make-default-method
    [ error-method ] with-hook ;

M: hook-combination perform-combination
    [ drop ] [ [ single-combination ] with-hook ] 2bi define ;

M: hook-combination next-method-quot*
    [ single-next-method-quot ] with-hook ;

M: simple-generic definer drop \ GENERIC: f ;

M: standard-generic definer drop \ GENERIC# f ;

M: hook-generic definer drop \ HOOK: f ;
