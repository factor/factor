! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences classes.tuple
classes.tuple.private math math.private slots.private
combinators dequeues search-dequeues namespaces fry
compiler.tree
compiler.tree.propagation.info
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.work-list
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.simple

: record-tuple-allocation ( #call -- )
    #! Delegation.
    dup dup in-d>> peek node-value-info literal>>
    class>> all-slots rest-slice [ read-only>> ] all? [
        [ in-d>> but-last ] [ out-d>> first ] bi
        record-allocation
    ] [ drop ] if ;

: record-slot-call ( #call -- )
    [ out-d>> first ]
    [ dup in-d>> second node-value-info literal>> ]
    [ in-d>> first ] tri
    over fixnum? [ [ 3 - ] dip record-slot-access ] [ 3drop ] if ;

M: #call escape-analysis*
    dup word>> {
        { \ <tuple-boa> [ record-tuple-allocation ] }
        { \ slot [ record-slot-call ] }
        [ drop in-d>> add-escaping-values ]
    } case ;

M: #return escape-analysis*
    in-d>> add-escaping-values ;
