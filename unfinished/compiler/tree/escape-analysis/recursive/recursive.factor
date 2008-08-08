! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math combinators accessors namespaces
fry disjoint-sets
compiler.tree
compiler.tree.combinators
compiler.tree.escape-analysis.nodes
compiler.tree.escape-analysis.branches
compiler.tree.escape-analysis.allocations ;
IN: compiler.tree.escape-analysis.recursive

: congruent? ( alloc1 alloc2 -- ? )
    {
        { [ 2dup [ f eq? ] either? ] [ eq? ] }
        { [ 2dup [ t eq? ] either? ] [ eq? ] }
        { [ 2dup [ length ] bi@ = not ] [ 2drop f ] }
        [ [ [ allocation ] bi@ congruent? ] 2all? ]
    } cond ;

: check-fixed-point ( node alloc1 alloc2 -- )
    [ congruent? ] 2all? [ drop ] [
        label>> f >>fixed-point drop
    ] if ;

: node-input-allocations ( node -- allocations )
    in-d>> [ allocation ] map ;

: node-output-allocations ( node -- allocations )
    out-d>> [ allocation ] map ;

: recursive-stacks ( #enter-recursive -- stacks )
    [ label>> calls>> [ in-d>> ] map ] [ in-d>> ] bi suffix ;

: analyze-recursive-phi ( #enter-recursive -- )
    [ ] [ recursive-stacks flip ] [ out-d>> ] tri
    [ [ merge-values ] 2each ]
    [
        [ (merge-allocations) ] dip
        [ [ allocation ] map check-fixed-point ]
        [ record-allocations ]
        2bi
    ] 2bi ;

M: #recursive escape-analysis* ( #recursive -- )
    [
        child>>
        [ first analyze-recursive-phi ]
        [ (escape-analysis) ]
        bi
    ] until-fixed-point ;

: return-allocations ( node -- allocations )
    label>> return>> node-input-allocations ;

M: #call-recursive escape-analysis* ( #call-label -- )
    [ ] [ return-allocations ] [ node-output-allocations ] tri
    [ check-fixed-point ] [ drop swap out-d>> record-allocations ] 3bi ;

M: #return-recursive escape-analysis* ( #return-recursive -- )
    [ in-d>> ] [ label>> calls>> ] bi
    [ out-d>> escaping-values get '[ , equate ] 2each ] with each ;
