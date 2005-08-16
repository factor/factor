IN: generic
USING: errors hashtables kernel kernel-internals lists math
namespaces sequences vectors words ;

: picker% "picker" word-prop % ;

: error-method ( generic -- method )
    [ dup picker% literalize , \ no-method , ] make-list ;

DEFER: delegate

: empty-method ( generic -- method )
    dup "picker" word-prop [ dup ] = [
        [
            [ dup delegate ] %
            [ dup , ] make-list ,
            error-method ,
            \ ?ifte ,
        ] make-list
    ] [
        error-method
    ] ifte ;

: class-predicates ( generic assoc -- assoc )
    >r "picker" word-prop r> [
        uncons >r "predicate" word-prop append r> cons
    ] map-with ;

: alist>quot ( default alist -- quot )
    [ unswons [ % , , \ ifte , ] make-list ] each ;

: sort-methods ( assoc -- vtable )
    #! Input is a predicate -> method association.
    num-types [
        type>class dup
        [ swap [ car classes-intersect? ] subset-with ]
        [ 2drop f ] ifte
    ] map-with ;

: <vtable> ( generic -- vtable )
    dup dup methods sort-methods [ class-predicates ] map-with 
    >r empty-method r> [ alist>quot ] map-with ;

: small-generic ( word -- def )
    dup dup methods class-predicates
    >r empty-method r> alist>quot ;

: big-generic ( word -- def )
    [ dup picker% \ type , <vtable> , \ dispatch , ] make-list ;

: small-generic? ( word -- ? )
    "methods" word-prop hash-size 3 <= ;

: standard-combination ( word -- quot )
    dup small-generic? [ small-generic ] [ big-generic ] ifte ;

: define-generic ( word -- )
    >r [ dup ] [ standard-combination ] r> define-generic* ;
