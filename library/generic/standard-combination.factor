IN: generic
USING: arrays errors hashtables kernel kernel-internals lists
math namespaces sequences vectors words ;

: picker ( dispatch# -- quot )
    { [ dup ] [ over ] [ pick ] } nth ;

: unpicker ( dispatch# -- quot )
    { [ nip ] [ >r nip r> swap ] [ >r >r nip r> r> -rot ] } nth ;

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

: simplify-alist ( class assoc -- default assoc )
    dup cdr [
        2dup cdr car first class< [
            cdr simplify-alist
        ] [
            uncons >r second nip r>
        ] if
    ] [
        nip car second [ ]
    ] if ;

: vtable-methods ( dispatch# alist-seq -- alist-seq )
    dup length [
        type>class [ swap simplify-alist ] [ car second [ ] ] if*
        >r over r> class-predicates alist>quot
    ] 2map nip ;

: <vtable> ( dispatch# word n -- vtable )
    #! n is vtable size; either num-types or num-tags.
    >r 2dup empty-method \ object bootstrap-word swap 2array
    >r methods >list r> swons r> sort-methods vtable-methods ;

: small-generic ( dispatch# word -- def )
    2dup methods class-predicates >r empty-method r> alist>quot ;

: big-generic ( dispatch# word n dispatcher -- def )
    [ >r pick picker % r> , <vtable> , \ dispatch , ] [ ] make ;

: tag-generic? ( word -- ? )
    "methods" word-prop hash-keys [ types ] map concat
    [ tag-mask < ] all? ;

: small-generic? ( word -- ? )
    "methods" word-prop hash-size 3 <= ;

: standard-combination ( word dispatch# -- quot )
    swap {
        { [ dup tag-generic? ] [ num-tags \ tag big-generic ] }
        { [ dup small-generic? ] [ small-generic ] }
        { [ t ] [ num-types \ type big-generic ] }
    } cond ;

: define-generic ( word -- )
    [ 0 standard-combination ] define-generic* ;

PREDICATE: generic standard-generic
    1 swap "combination" word-prop ?nth
    \ standard-combination eq? ;
