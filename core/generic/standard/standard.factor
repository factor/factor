! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel kernel.private slots.private math
namespaces sequences vectors words quotations definitions
hashtables layouts combinators combinators.private generic
classes classes.private ;
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

TUPLE: no-method object generic ;

: no-method ( object generic -- * )
    \ no-method construct-boa throw ;

: error-method ( word -- method )
    picker swap [ no-method ] curry append ;

: empty-method ( word -- method )
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
    empty-method object bootstrap-word swap 2array ;

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

: big-generic ( methods -- quot )
    hash-methods [ small-generic ] map
    hash-dispatch-quot picker [ class-hash ] rot 3append ;

: vtable-class ( n -- class )
    type>class [ hi-tag bootstrap-word ] unless* ;

: group-methods ( assoc -- vtable )
    #! Input is a predicate -> method association.
    #! n is vtable size (either num-types or num-tags).
    num-tags get [
        vtable-class
        [ swap first classes-intersect? ] curry subset
    ] curry* map ;

: build-type-vtable ( alist-seq -- alist-seq )
    dup length [
        vtable-class swap simplify-alist
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
    dup methods swap default-method add* ;

M: standard-combination perform-combination
    standard-combination-# (dispatch#) [
        standard-methods single-combination
    ] with-variable ;

: default-hook-method ( word -- pair )
    error-method object bootstrap-word swap 2array ;

: hook-methods ( word -- methods )
    dup methods [ [ drop ] swap append ] assoc-map
    swap default-hook-method add* ;

TUPLE: hook-combination var ;

C: <hook-combination> hook-combination

M: hook-combination perform-combination
    0 (dispatch#) [
        [
            hook-combination-var [ get ] curry %
            hook-methods single-combination %
        ] [ ] make
    ] with-variable ;

: define-simple-generic ( word -- )
    T{ standard-combination f 0 } define-generic ;

PREDICATE: generic standard-generic
    "combination" word-prop standard-combination? ;

PREDICATE: standard-generic simple-generic
    "combination" word-prop standard-combination-# zero? ;

PREDICATE: generic hook-generic
    "combination" word-prop hook-combination? ;

GENERIC: dispatch# ( word -- n )

M: word dispatch# "combination" word-prop dispatch# ;

M: standard-combination dispatch# standard-combination-# ;

M: hook-combination dispatch# drop 0 ;

M: simple-generic definer drop \ GENERIC: f ;
