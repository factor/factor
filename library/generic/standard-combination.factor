IN: generic
USING: errors hashtables kernel kernel-internals lists math
namespaces sequences vectors words ;

: error-method ( picker word -- method )
    [ swap % literalize , \ no-method , ] make-list ;

: empty-method ( picker word -- method )
    over [ dup ] = [
        [
            [ dup delegate ] % dup unit , error-method , \ ?ifte ,
        ] make-list
    ] [
        error-method
    ] ifte ;

: class-predicates ( picker assoc -- assoc )
    [ uncons >r "predicate" word-prop append r> cons ] map-with ;

: alist>quot ( default alist -- quot )
    [ unswons [ % , , \ ifte , ] make-list ] each ;

: sort-methods ( assoc -- vtable )
    #! Input is a predicate -> method association.
    num-types [
        type>class dup
        [ swap [ car classes-intersect? ] subset-with ]
        [ 2drop f ] ifte
    ] map-with ;

: <vtable> ( picker word -- vtable )
    2dup methods sort-methods [ class-predicates ] map-with
    >r empty-method r> [ alist>quot ] map-with ;

: small-generic ( picker word -- def )
    2dup methods class-predicates >r empty-method r> alist>quot ;

: big-generic ( picker word -- def )
    [ over % \ type , <vtable> , \ dispatch , ] make-list ;

: small-generic? ( word -- ? )
    "methods" word-prop hash-size 3 <= ;

: standard-combination ( word picker -- quot )
    swap dup small-generic?
    [ small-generic ] [ big-generic ] ifte ;

: simple-combination ( word -- quot )
    [ dup ] standard-combination ;

: define-generic ( word -- )
    [ simple-combination ] define-generic* ;

PREDICATE: generic simple-generic ( word -- ? )
    "combination" word-prop [ simple-combination ] = ;
