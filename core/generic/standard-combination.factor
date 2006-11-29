! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors hashtables kernel kernel-internals
math namespaces sequences vectors words ;
IN: generic

: picker ( dispatch# -- quot )
    { [ dup ] [ over ] [ pick ] } nth ;

: unpicker ( dispatch# -- quot )
    { [ nip ] [ >r nip r> swap ] [ >r >r nip r> r> -rot ] } nth ;

TUPLE: no-method object generic ;

: no-method ( object generic -- * ) <no-method> throw ;

: error-method ( dispatch# word -- method )
    >r picker r> [ no-method ] curry append ;

: empty-method ( dispatch# word -- method )
    [
        over picker % [ delegate dup ] %
        over unpicker over add ,
        [ drop ] -rot error-method append , \ if ,
    ] [ ] make ;

: class-predicates ( picker assoc -- assoc )
    [
        first2 >r >r picker r> "predicate" word-prop append
        r> 2array
    ] map-with ;

: sort-methods ( assoc n -- vtable )
    #! Input is a predicate -> method association.
    #! n is vtable size (either num-types or num-tags).
    [
        type>class [ object bootstrap-word ] unless*
        swap [ first classes-intersect? ] subset-with
    ] map-with ;

: (simplify-alist) ( class i assoc -- default assoc )
    2dup length 1- = [
        nth second [ ] rot drop
    ] [
        3dup >r 1+ r> nth first class< [
            >r 1+ r> (simplify-alist)
        ] [
            [ nth second ] 2keep swap 1+ tail rot drop
        ] if
    ] if ;

: simplify-alist ( class assoc -- default assoc )
    0 swap (simplify-alist) ;

: default-method ( dispatch# word -- pair )
    empty-method object bootstrap-word swap 2array ;

: methods* ( dispatch# word -- assoc )
    #! Make a class->method association, together with a
    #! default delegating method at the end.
    dup methods -rot default-method add* ;

: method-alist>quot ( dispatch# alist base-class -- quot )
    bootstrap-word swap simplify-alist
    swapd class-predicates alist>quot ;

: small-generic ( dispatch# word -- def )
    dupd methods* object method-alist>quot ;

: build-type-vtable ( dispatch# alist-seq -- alist-seq )
    dup length [
        type>class
        [ swap simplify-alist ] [ first second [ ] ] if*
        >r over r> class-predicates alist>quot
    ] 2map nip ;

: <type-vtable> ( dispatch# word n -- vtable )
    #! n is vtable size; either num-types or num-tags.
    >r dupd methods* r> sort-methods build-type-vtable ;

: type-generic ( dispatch# word n dispatcher -- quot )
    [
        >r pick picker % r> , <type-vtable> , \ dispatch ,
    ] [ ] make ;

: tag-generic? ( word -- ? )
    #! If all the types we dispatch upon can be identified
    #! based on tag alone, we change the dispatcher primitive
    #! from 'type' to 'tag'.
    generic-tags [ tag-mask < ] all? ;

: small-generic? ( word -- ? ) generic-tags length 3 <= ;

: standard-combination ( word dispatch# -- quot )
    swap {
        { [ dup tag-generic? ] [ num-tags \ tag type-generic ] }
        { [ dup small-generic? ] [ small-generic ] }
        { [ t ] [ num-types \ type type-generic ] }
    } cond ;

: define-generic ( word -- )
    [ 0 standard-combination ] define-generic* ;

PREDICATE: generic standard-generic
    "combination" word-prop [ standard-combination ] tail? ;
