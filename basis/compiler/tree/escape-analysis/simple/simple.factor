! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences classes.tuple
classes.tuple.private arrays math math.private slots.private
combinators dequeues search-dequeues namespaces fry classes
classes.algebra stack-checker.state
compiler.tree
compiler.tree.intrinsics
compiler.tree.propagation.info
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.simple

M: #terminate escape-analysis* drop ;

M: #renaming escape-analysis* inputs/outputs [ copy-value ] 2each ;

M: #introduce escape-analysis* out-d>> unknown-allocations ;

DEFER: record-literal-allocation

: make-literal-slots ( seq -- values )
    [ <slot-value> [ swap record-literal-allocation ] keep ] map ;

: object-slots ( object -- slots/f )
    #! Delegation
    {
        { [ dup class immutable-tuple-class? ] [ tuple-slots rest-slice ] }
        { [ dup complex? ] [ [ real-part ] [ imaginary-part ] bi 2array ] }
        [ drop f ]
    } cond ;

: record-literal-allocation ( value object -- )
    object-slots
    [ make-literal-slots swap record-allocation ]
    [ unknown-allocation ]
    if* ;

M: #push escape-analysis*
    #! Delegation.
    [ out-d>> first ] [ literal>> ] bi record-literal-allocation ;

: record-tuple-allocation ( #call -- )
    [ in-d>> but-last ] [ out-d>> first ] bi record-allocation ;

: record-complex-allocation ( #call -- )
    [ in-d>> ] [ out-d>> first ] bi record-allocation ;

: slot-offset ( #call -- n/f )
    dup in-d>>
    [ first node-value-info class>> ]
    [ second node-value-info literal>> ] 2bi
    dup fixnum? [
        {
            { [ over tuple class<= ] [ 3 - ] }
            { [ over complex class<= ] [ 1 - ] }
            [ drop f ]
        } cond nip
    ] [ 2drop f ] if ;

: record-slot-call ( #call -- )
    [ out-d>> first ] [ slot-offset ] [ in-d>> first ] tri
    over [
        [ record-slot-access ] [ copy-slot-value ] 3bi
    ] [ 2drop unknown-allocation ] if ;

M: #call escape-analysis*
    dup word>> {
        { \ <immutable-tuple-boa> [ record-tuple-allocation ] }
        { \ <complex> [ record-complex-allocation ] }
        { \ slot [ record-slot-call ] }
        [
            drop
            [ in-d>> add-escaping-values ]
            [ out-d>> unknown-allocations ] bi
        ]
    } case ;

M: #return escape-analysis*
    in-d>> add-escaping-values ;

M: #alien-invoke escape-analysis*
    [ in-d>> add-escaping-values ]
    [ out-d>> unknown-allocation ]
    bi ;

M: #alien-indirect escape-analysis*
    [ in-d>> add-escaping-values ]
    [ out-d>> unknown-allocation ]
    bi ;
