IN: generic
USING: errors hashtables kernel kernel-internals lists math
namespaces sequences vectors words ;

: set-vtable ( definition class vtable -- )
    >r types first r> set-nth ;

: add-method ( generic vtable definition class -- )
    #! Add the method entry to the vtable. Unlike define-method,
    #! this is called at vtable build time, and in the sorted
    #! order.
    dup metaclass "add-method" word-prop [
        [ "Metaclass is missing add-method" throw ]
    ] unless* call ;

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

: <empty-vtable> ( generic -- vtable )
    empty-method num-types swap <repeated> >vector ;

: <vtable> ( generic -- vtable )
    dup <empty-vtable> over methods [
        ( generic vtable method )
        >r 2dup r> unswons add-method
    ] each nip ;

: (small-generic) ( word methods -- quot )
    [
        2dup cdr (small-generic) [
            >r >r picker%
            r> car unswons "predicate" word-prop %
            , r> , \ ifte ,
        ] make-list
    ] [
        empty-method
    ] ifte* ;

: small-generic ( word -- def )
    dup methods reverse (small-generic) ;

: big-generic ( word -- def )
    [ dup picker% \ type , <vtable> , \ dispatch , ] make-list ;

: small-generic? ( word -- ? )
    "methods" word-prop hash-size 3 <= ;

: standard-combination ( word -- quot )
    dup small-generic? [ small-generic ] [ big-generic ] ifte ;

: define-generic ( word -- )
    >r [ dup ] [ standard-combination ] r> define-generic* ;
