! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple
classes.tuple.private combinators compiler.tree
compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.nodes
compiler.tree.propagation.info kernel math namespaces sequences
slots.private ;
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
        { [ dup class-of immutable-tuple-class? ] [ tuple-slots ] }
        [ drop f ]
    } cond ;

: record-literal-allocation ( value object -- )
    object-slots
    [ make-literal-slots swap record-allocation ]
    [ unknown-allocation ]
    if* ;

M: #push escape-analysis*
    dup literal>> layout-up-to-date?
    [ [ out-d>> first ] [ literal>> ] bi record-literal-allocation ]
    [ out-d>> unknown-allocations ]
    if ;

: record-unknown-allocation ( #call -- )
    [ in-d>> add-escaping-values ]
    [ out-d>> unknown-allocations ] bi ;

: record-tuple-allocation ( #call -- )
    dup immutable-tuple-boa?
    [ [ in-d>> but-last { } like ] [ out-d>> first ] bi record-allocation ]
    [ record-unknown-allocation ]
    if ;

: slot-offset ( #call -- n/f )
    dup in-d>> second node-value-info literal>> dup [ 2 - ] when ;

: valid-slot-offset? ( slot# in -- ? )
    over [
        allocation dup [
            dup array? [ bounds-check? ] [ 2drop f ] if
        ] [ 2drop t ] if
    ] [ 2drop f ] if ;

: unknown-slot-call ( out slot# in -- )
    [ unknown-allocation ] [ drop ] [ add-escaping-value ] tri* ;

: record-slot-call ( #call -- )
    [ out-d>> first ] [ slot-offset ] [ in-d>> first ] tri
    2dup valid-slot-offset?
    [ [ record-slot-access ] [ copy-slot-value ] 3bi ]
    [ unknown-slot-call ]
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

M: #alien-callback escape-analysis*
    child>> (escape-analysis) ;
