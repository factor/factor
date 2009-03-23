! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel kernel.private slots.private math
namespaces make sequences vectors words quotations definitions
hashtables layouts combinators sequences.private generic
classes classes.algebra classes.private generic.standard.engines
generic.standard.engines.tag generic.standard.engines.predicate
generic.standard.engines.tuple accessors ;
IN: generic.standard

GENERIC: dispatch# ( word -- n )

M: generic dispatch#
    "combination" word-prop dispatch# ;

GENERIC: method-declaration ( class generic -- quot )

M: generic method-declaration
    "combination" word-prop method-declaration ;

M: quotation engine>quot
    assumed get generic get method-declaration prepend ;

ERROR: no-method object generic ;

: error-method ( word -- quot )
    [ picker ] dip [ no-method ] curry append ;

: push-method ( method specializer atomic assoc -- )
    [
        [ H{ } clone <predicate-dispatch-engine> ] unless*
        [ methods>> set-at ] keep
    ] change-at ;

: flatten-method ( class method assoc -- )
    [ [ flatten-class keys ] keep ] 2dip [
        [ spin ] dip push-method
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

: mangle-method ( method -- quot )
    1quotation generic get extra-values \ drop <repetition>
    prepend [ ] like ;

: find-default ( methods -- quot )
    #! Side-effects methods.
    [ object bootstrap-word ] dip delete-at* [
        drop generic get "default-method" word-prop mangle-method
    ] unless ;

: <standard-engine> ( word -- engine )
    object bootstrap-word assumed set {
        [ generic set ]
        [ "engines" word-prop forget-all ]
        [ V{ } clone "engines" set-word-prop ]
        [
            "methods" word-prop
            [ mangle-method ] assoc-map
            [ find-default default set ]
            [ <big-dispatch-engine> ]
            bi
        ]
    } cleave ;

: single-combination ( word -- quot )
    [ <standard-engine> engine>quot ] with-scope ;

ERROR: inconsistent-next-method class generic ;

: single-next-method-quot ( class generic -- quot/f )
    2dup next-method dup [
        [
            pick "predicate" word-prop %
            1quotation ,
            [ inconsistent-next-method ] 2curry ,
            \ if ,
        ] [ ] make
    ] [ 3drop f ] if ;

: single-effective-method ( obj word -- method )
    [ [ order [ instance? ] with find-last nip ] keep method ]
    [ "default-method" word-prop ]
    bi or ;

TUPLE: standard-combination # ;

C: <standard-combination> standard-combination

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop #>> zero? ;

CONSTANT: simple-combination T{ standard-combination f 0 }

: define-simple-generic ( word effect -- )
    [ simple-combination ] dip define-generic ;

: with-standard ( combination quot -- quot' )
    [ #>> (dispatch#) ] dip with-variable ; inline

M: standard-generic extra-values drop 0 ;

M: standard-combination make-default-method
    [ error-method ] with-standard ;

M: standard-combination perform-combination
    [ drop ] [ [ single-combination ] with-standard ] 2bi define ;

M: standard-combination dispatch# #>> ;

M: standard-combination method-declaration
    dispatch# object <array> swap prefix [ declare ] curry [ ] like ;

M: standard-combination next-method-quot*
    [
        single-next-method-quot
        dup [ picker prepend ] when
    ] with-standard ;

M: standard-generic effective-method
    [ dispatch# (picker) call ] keep single-effective-method ;

TUPLE: hook-combination var ;

C: <hook-combination> hook-combination

PREDICATE: hook-generic < generic
    "combination" word-prop hook-combination? ;

: with-hook ( combination quot -- quot' )
    0 (dispatch#) [
        [ hook-combination ] dip with-variable
    ] with-variable ; inline

: prepend-hook-var ( quot -- quot' )
    hook-combination get var>> [ get ] curry prepend ;

M: hook-combination dispatch# drop 0 ;

M: hook-combination method-declaration 2drop [ ] ;

M: hook-generic extra-values drop 1 ;

M: hook-generic effective-method
    [ "combination" word-prop var>> get ] keep
    single-effective-method ;

M: hook-combination make-default-method
    [ error-method prepend-hook-var ] with-hook ;

M: hook-combination perform-combination
    [ drop ] [
        [ single-combination prepend-hook-var ] with-hook
    ] 2bi define ;

M: hook-combination next-method-quot*
    [
        single-next-method-quot
        dup [ prepend-hook-var ] when
    ] with-hook ;

M: simple-generic definer drop \ GENERIC: f ;

M: standard-generic definer drop \ GENERIC# f ;

M: hook-generic definer drop \ HOOK: f ;
