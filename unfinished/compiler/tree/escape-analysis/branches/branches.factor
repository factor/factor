! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences
compiler.tree
compiler.tree.propagation.branches
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.branches

SYMBOL: children-escape-data

M: #branch escape-analysis*
    live-children sift [ (escape-analysis) ] each ;

: (merge-allocations) ( values -- allocation )
    [
        [ allocation ] map dup [ ] all? [
            dup [ length ] map all-equal? [
                flip
                [ (merge-allocations) ] [ [ merge-slots ] map ] bi
                [ record-allocations ] keep
            ] [ drop f ] if
        ] [ drop f ] if
    ] map ;

: merge-allocations ( in-values out-values -- )
    [ (merge-allocations) ] dip record-allocations ;

M: #phi escape-analysis*
    [ [ phi-in-d>> ] [ out-d>> ] bi merge-allocations ]
    [ [ phi-in-r>> ] [ out-r>> ] bi merge-allocations ]
    bi ;
