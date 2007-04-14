! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel kernel.private slots.private math
namespaces sequences vectors words quotations definitions
hashtables layouts combinators sequences.private generic
classes classes.algebra classes.private ;
IN: generic.standard

TUPLE: standard-combination # ;

C: <standard-combination> standard-combination

SYMBOL: (dispatch#)

: (picker) ( n -- quot )
    {
        { 0 [ [ dup ] ] }
        { 1 [ [ over ] ] }
        { 2 [ [ pick ] ] }
        [ 1- (picker) [ >r ] swap [ r> swap ] 3append ]
    } case ;

: picker ( -- quot ) \ (dispatch#) get (picker) ;

: unpickers { [ nip ] [ >r nip r> swap ] [ >r >r nip r> r> -rot ] } ; inline

: unpicker ( -- quot ) \ (dispatch#) get unpickers nth ;

ERROR: no-method object generic ;

: error-method ( word --  quot )
    picker swap [ no-method ] curry append ;

: empty-method ( word -- quot )
    [
        picker % [ delegate dup ] %
        unpicker over add ,
        error-method \ drop add* , \ if ,
    ] [ ] make ;

: class-predicates ( assoc -- assoc )
    [
        >r >r picker r> "predicate" word-prop append r>
    ] assoc-map ;

: (simplify-alist) ( class i assoc -- default assoc )
    2dup length 1- = [
        nth second { } rot drop
    ] [
        3dup >r 1+ r> nth first class< [
            >r 1+ r> (simplify-alist)
        ] [
            [ nth second ] 2keep swap 1+ tail rot drop
        ] if
    ] if ;

: simplify-alist ( class assoc -- default assoc )
    dup empty? [
        2drop [ "Unreachable" throw ] { }
    ] [
        0 swap (simplify-alist)
    ] if ;

: default-method ( word -- pair )
    "default-method" word-prop
    object bootstrap-word swap 2array ;

: method-alist>quot ( alist base-class -- quot )
    bootstrap-word swap simplify-alist
    class-predicates alist>quot ;

: small-generic ( methods -- def )
    object method-alist>quot ;

: hash-methods ( methods -- buckets )
    V{ } clone [
        tuple bootstrap-word over class< [
            drop t
        ] [
            class-hashes
        ] if
    ] distribute-buckets ;

: class-hash-dispatch-quot ( methods quot picker -- quot )
    >r >r hash-methods r> map
    hash-dispatch-quot r> [ class-hash ] rot 3append ; inline

: big-generic ( methods -- quot )
    [ small-generic ] picker class-hash-dispatch-quot ;

: vtable-class ( n -- class )
    bootstrap-type>class [ hi-tag bootstrap-word ] unless* ;

: group-methods ( assoc -- vtable )
    #! Input is a predicate -> method association.
    #! n is vtable size (either num-types or num-tags).
    num-tags get [
        vtable-class
        [ swap first classes-intersect? ] curry subset
    ] with map ;

: build-type-vtable ( alist-seq -- alist-seq )
    dup length [
        vtable-class
        swap simplify-alist
        class-predicates alist>quot
    ] 2map ;

: tag-generic ( methods -- quot )
    [
        picker %
        \ tag ,
        group-methods build-type-vtable ,
        \ dispatch ,
    ] [ ] make ;

: flatten-method ( class body -- )
    over members pick object bootstrap-word eq? not and [
        >r members r> [ flatten-method ] curry each
    ] [
        swap set
    ] if ;

: flatten-methods ( methods -- newmethods )
    [ [ flatten-method ] assoc-each ] V{ } make-assoc ;

: dispatched-types ( methods -- seq )
    keys object bootstrap-word swap remove prune ;

: single-combination ( methods -- quot )
    dup length 4 <= [
        small-generic
    ] [
        flatten-methods
        dup dispatched-types [ number class< ] all?
        [ tag-generic ] [ big-generic ] if
    ] if ;

: standard-methods ( word -- alist )
    dup methods swap default-method add*
    [ 1quotation ] assoc-map ;

M: standard-combination make-default-method
    standard-combination-# (dispatch#)
    [ empty-method ] with-variable ;

M: standard-combination perform-combination
    standard-combination-# (dispatch#) [
        [ standard-methods ] keep "inline" word-prop
        [ small-generic ] [ single-combination ] if
    ] with-variable ;

TUPLE: hook-combination var ;

C: <hook-combination> hook-combination

: with-hook ( combination quot -- quot' )
    0 (dispatch#) [
        swap slip
        hook-combination-var [ get ] curry
        prepend
    ] with-variable ; inline

M: hook-combination make-default-method
    [ error-method ] with-hook ;

M: hook-combination perform-combination
    [
        standard-methods
        [ [ drop ] prepend ] assoc-map
        single-combination
    ] with-hook ;

: define-simple-generic ( word -- )
    T{ standard-combination f 0 } define-generic ;

PREDICATE: standard-generic < generic
    "combination" word-prop standard-combination? ;

PREDICATE: simple-generic < standard-generic
    "combination" word-prop standard-combination-# zero? ;

PREDICATE: hook-generic < generic
    "combination" word-prop hook-combination? ;

GENERIC: dispatch# ( word -- n )

M: word dispatch# "combination" word-prop dispatch# ;

M: standard-combination dispatch# standard-combination-# ;

M: hook-combination dispatch# drop 0 ;

M: simple-generic definer drop \ GENERIC: f ;

M: standard-generic definer drop \ GENERIC# f ;

M: hook-generic definer drop \ HOOK: f ;
