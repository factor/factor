! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences classes.tuple
classes.tuple.private math math.private slots.private
combinators dequeues search-dequeues namespaces fry classes
stack-checker.state
compiler.tree
compiler.tree.propagation.info
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.simple

M: #introduce escape-analysis*
    value>> unknown-allocation ;

: record-literal-allocation ( value object -- )
    dup class immutable-tuple-class? [
        tuple-slots rest-slice
        [ <slot-value> [ swap record-literal-allocation ] keep ] map
        swap record-allocation
    ] [
        drop unknown-allocation
    ] if ;

M: #push escape-analysis*
    #! Delegation.
    [ out-d>> first ] [ literal>> ] bi record-literal-allocation ;

: record-tuple-allocation ( #call -- )
    #! Delegation.
    dup dup in-d>> peek node-value-info literal>>
    class>> immutable-tuple-class? [
        [ in-d>> but-last ] [ out-d>> first ] bi
        record-allocation
    ] [ out-d>> unknown-allocations ] if ;

: record-slot-call ( #call -- )
    [ out-d>> first ]
    [ dup in-d>> second node-value-info literal>> ]
    [ in-d>> first ] tri
    over fixnum? [
        [ 3 - ] dip record-slot-access
    ] [
        2drop unknown-allocation
    ] if ;

M: #call escape-analysis*
    dup word>> {
        { \ <tuple-boa> [ record-tuple-allocation ] }
        { \ slot [ record-slot-call ] }
        [
            drop
            [ in-d>> add-escaping-values ]
            [ out-d>> unknown-allocations ] bi
        ]
    } case ;

M: #return escape-analysis*
    in-d>> add-escaping-values ;
