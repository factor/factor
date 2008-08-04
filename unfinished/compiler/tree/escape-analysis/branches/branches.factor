! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces sequences sets fry
stack-checker.branches
compiler.tree
compiler.tree.propagation.branches
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.branches

M: #branch escape-analysis*
    live-children sift [ (escape-analysis) ] each ;

: (merge-allocations) ( values -- allocation )
    [
        dup [ allocation ] map dup [ ] all? [
            dup [ length ] map all-equal? [
                nip flip
                [ (merge-allocations) ] [ [ merge-slots ] map ] bi
                [ record-allocations ] keep
            ] [ drop add-escaping-values f ] if
        ] [ drop add-escaping-values f ] if
    ] map ;

: merge-allocations ( in-values out-values -- )
    [ [ merge-values ] 2each ]
    [ [ (merge-allocations) ] dip record-allocations ]
    2bi ;

M: #phi escape-analysis*
    [ [ phi-in-d>> ] [ out-d>> ] bi merge-allocations ]
    [ [ phi-in-r>> ] [ out-r>> ] bi merge-allocations ]
    bi ;
