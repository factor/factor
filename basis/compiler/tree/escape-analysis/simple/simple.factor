! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences classes.tuple
classes.tuple.private arrays math math.private slots.private
combinators deques search-deques namespaces fry classes
classes.algebra assocs stack-checker.state
compiler.tree
compiler.tree.propagation.info
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.simple

M: #declare escape-analysis* drop ;

M: #terminate escape-analysis* drop ;

M: #renaming escape-analysis* inputs/outputs copy-values ;

: declared-class ( value -- class/f )
    next-node get dup #declare? [ declaration>> at ] [ 2drop f ] if ;

: record-param-allocation ( value class -- )
    dup immutable-tuple-class? [
        [ swap set-value-class ] [
            all-slots [
                [ <slot-value> dup ] [ class>> ] bi*
                record-param-allocation
            ] map swap record-allocation
        ] 2bi
    ] [ drop unknown-allocation ] if ;

M: #introduce escape-analysis*
    out-d>> [ dup declared-class record-param-allocation ] each ;

DEFER: record-literal-allocation

: make-literal-slots ( seq -- values )
    [ <slot-value> [ swap record-literal-allocation ] keep ] map ;

: object-slots ( object -- slots/f )
    {
        { [ dup class immutable-tuple-class? ] [ tuple-slots ] }
        [ drop f ]
    } cond ;

: record-literal-allocation ( value object -- )
    object-slots
    [ make-literal-slots swap record-allocation ]
    [ unknown-allocation ]
    if* ;

M: #push escape-analysis*
    [ out-d>> first ] [ literal>> ] bi record-literal-allocation ;

: record-unknown-allocation ( #call -- )
    [ in-d>> add-escaping-values ]
    [ out-d>> unknown-allocations ] bi ;

: record-tuple-allocation ( #call -- )
    dup immutable-tuple-boa?
    [ [ in-d>> but-last ] [ out-d>> first ] bi record-allocation ]
    [ record-unknown-allocation ]
    if ;

: slot-offset ( #call -- n/f )
    dup in-d>>
    [ second node-value-info literal>> ]
    [ first node-value-info class>> ] 2bi
    2dup [ fixnum? ] [ tuple class<= ] bi* and [
        over 2 >= [ drop 2 - ] [ 2drop f ] if
    ] [ 2drop f ] if ;

: record-slot-call ( #call -- )
    [ out-d>> first ] [ slot-offset ] [ in-d>> first ] tri over
    [ [ record-slot-access ] [ copy-slot-value ] 3bi ]
    [ [ unknown-allocation ] [ drop ] [ add-escaping-value ] tri* ]
    if ;

M: #call escape-analysis*
    dup word>> {
        { \ <tuple-boa> [ record-tuple-allocation ] }
        { \ slot [ record-slot-call ] }
        [ drop record-unknown-allocation ]
    } case ;

M: #return escape-analysis*
    in-d>> add-escaping-values ;

M: #alien-node escape-analysis*
    [ in-d>> add-escaping-values ]
    [ out-d>> unknown-allocations ]
    bi ;

M: #alien-callback escape-analysis* drop ;
