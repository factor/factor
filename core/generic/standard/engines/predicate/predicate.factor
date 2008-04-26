USING: generic.standard.engines generic namespaces kernel
sequences classes.algebra accessors words combinators
assocs ;
IN: generic.standard.engines.predicate

TUPLE: predicate-dispatch-engine methods ;

C: <predicate-dispatch-engine> predicate-dispatch-engine

: class-predicates ( assoc -- assoc )
    [ >r "predicate" word-prop picker prepend r> ] assoc-map ;

: keep-going? ( assoc -- ? )
    assumed get swap second first class< ;

: prune-redundant-predicates ( assoc -- default assoc' )
    {
        { [ dup empty? ] [ drop [ "Unreachable" throw ] { } ] }
        { [ dup length 1 = ] [ first second { } ] }
        { [ dup keep-going? ] [ rest-slice prune-redundant-predicates ] }
        [ [ first second ] [ rest-slice ] bi ]
    } cond ;

: sort-methods ( assoc -- assoc' )
    [ keys sort-classes ]
    [ [ dupd at ] curry ] bi { } map>assoc ;

M: predicate-dispatch-engine engine>quot
    methods>> clone
    default get object bootstrap-word pick set-at engines>quots
    sort-methods prune-redundant-predicates
    class-predicates alist>quot ;
