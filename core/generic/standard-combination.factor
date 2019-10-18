! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays errors assocs kernel kernel-internals
math namespaces sequences vectors words quotations
definitions ;
IN: generic

: pickers { [ dup ] [ over ] [ pick ] } ; inline

: picker ( dispatch# -- quot ) pickers nth ;

: unpickers { [ nip ] [ >r nip r> swap ] [ >r >r nip r> r> -rot ] } ; inline

: unpicker ( dispatch# -- quot ) unpickers nth ;

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

: method-alist>quot ( dispatch# alist base-class -- quot )
    bootstrap-word swap simplify-alist
    swapd class-predicates alist>quot ;

: small-generic ( dispatch# methods -- def )
    object method-alist>quot ;

: build-type-vtable ( dispatch# alist-seq -- alist-seq )
    dup length [
        type>class
        [ swap simplify-alist ] [ first second [ ] ] if*
        >r over r> class-predicates alist>quot
    ] 2map nip ;

: <type-vtable> ( dispatch# methods n -- vtable )
    #! n is vtable size; either num-types or num-tags.
    sort-methods build-type-vtable ;

: type-generic ( dispatch# methods symbol dispatcher -- quot )
    [
        >r pick picker % r> , get <type-vtable> , \ dispatch ,
    ] [ ] make ;

: tag-generic? ( word -- ? )
    #! If all the types we dispatch upon can be identified
    #! based on tag alone, we change the dispatcher primitive
    #! from 'type' to 'tag'.
    generic-tags [ tag-mask get < ] all? ;

: small-generic? ( word -- ? )
    dup generic-tags length swap
    "methods" word-prop assoc-size min 3 <= ;

: empty-generic? ( word -- ? )
    "methods" word-prop assoc-empty? ;

: single-combination ( dispatch# methods word -- quot )
    {
        { [ dup empty-generic? ] [ drop small-generic ] }
        { [ dup tag-generic? ] [ drop num-tags \ tag type-generic ] }
        { [ dup small-generic? ] [ drop small-generic ] }
        { [ t ] [ drop num-types \ type type-generic ] }
    } cond ;

: standard-methods ( dispatch# word -- methods )
    #! Make a class->method association, together with a
    #! default delegating method at the end.
    dup methods -rot default-method add* ;

: standard-combination ( word dispatch# -- quot )
    swap 2dup standard-methods swap single-combination ;

: simple-combination ( word -- quot )
    0 standard-combination ;

: default-hook-method ( word variable -- pair )
    [ get ] curry 0 rot error-method append
    object bootstrap-word swap 2array ;

: hook-methods ( word variable -- methods )
    over methods [ [ drop ] swap append ] assoc-map
    -rot default-hook-method add* ;

: hook-combination ( word variable -- quot )
    dup [ get ] curry -rot
    over >r hook-methods 0 swap r> single-combination append ;

: define-simple-generic ( word -- )
    [ simple-combination ] define-generic ;

PREDICATE: generic standard-generic
    "combination" word-prop
    dup [ simple-combination ] =
    swap [ standard-combination ] tail? or ;

PREDICATE: standard-generic simple-generic
    "combination" word-prop [ simple-combination ] = ;

GENERIC: dispatch# ( word -- n )

M: simple-generic dispatch# drop 0 ;

M: standard-generic dispatch# "combination" word-prop first ;

M: simple-generic definer drop \ GENERIC: f ;

M: simple-generic definition drop f ;
