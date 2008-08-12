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
    [ congruent? ] 2all? [ drop ] [ label>> f >>fixed-point drop ] if ;

: node-input-allocations ( node -- allocations )
    in-d>> [ allocation ] map ;

: node-output-allocations ( node -- allocations )
    out-d>> [ allocation ] map ;

: recursive-stacks ( #enter-recursive -- stacks )
    [ label>> calls>> [ in-d>> ] map ] [ in-d>> ] bi suffix
    escaping-values get '[ [ , disjoint-set-member? ] all? ] filter
    flip ;

: analyze-recursive-phi ( #enter-recursive -- )
    [ ] [ recursive-stacks ] [ out-d>> ] tri
    [ [ merge-values ] 2each ]
    [
        [ (merge-allocations) ] dip
        [ [ allocation ] map check-fixed-point ]
        [ record-allocations ]
        2bi
    ] 2bi ;

M: #recursive escape-analysis* ( #recursive -- )
    { 0 } clone [ USE: math
        dup first 10 = [ "OOPS" throw ] [ dup first 1+ swap set-first ] if
        child>>
        [ first out-d>> introduce-values ]
        [ first analyze-recursive-phi ]
        [ (escape-analysis) ]
        tri
    ] curry until-fixed-point ;

M: #enter-recursive escape-analysis* ( #enter-recursive -- )
    #! Handled by #recursive
    drop ;

: return-allocations ( node -- allocations )
    label>> return>> node-input-allocations ;

M: #call-recursive escape-analysis* ( #call-label -- )
    [ ] [ return-allocations ] [ node-output-allocations ] tri
    [ check-fixed-point ] [ drop swap out-d>> record-allocations ] 3bi ;

M: #return-recursive escape-analysis* ( #return-recursive -- )
    [ call-next-method ]
    [
        [ in-d>> ] [ label>> calls>> ] bi
        [ out-d>> escaping-values get '[ , equate ] 2each ] with each
    ] bi ;
