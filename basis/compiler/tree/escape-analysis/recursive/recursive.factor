! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.tree
compiler.tree.combinators
compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.branches
compiler.tree.escape-analysis.nodes compiler.tree.recursive
disjoint-sets fry kernel namespaces sequences ;
IN: compiler.tree.escape-analysis.recursive

: congruent? ( alloc1 alloc2 -- ? )
    {
        { [ 2dup [ boolean? ] either? ] [ eq? ] }
        { [ 2dup 2length = not ] [ 2drop f ] }
        [ [ [ allocation ] bi@ congruent? ] 2all? ]
    } cond ;

: check-fixed-point ( node alloc1 alloc2 -- )
    [ congruent? ] 2all? [ drop ] [ label>> f >>fixed-point drop ] if ;

: node-input-allocations ( node -- allocations )
    in-d>> [ allocation ] map ;

: node-output-allocations ( node -- allocations )
    out-d>> [ allocation ] map ;

: recursive-stacks ( #enter-recursive -- stacks )
    recursive-phi-in
    escaping-values get '[ [ _ disjoint-set-member? ] all? ] filter
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
    [ label>> return>> in-d>> introduce-values ]
    [
        [
            child>>
            [ first out-d>> introduce-values ]
            [ first analyze-recursive-phi ]
            [ (escape-analysis) ]
            tri
        ] until-fixed-point
    ] bi ;

M: #enter-recursive escape-analysis* ( #enter-recursive -- )
    ! Handled by #recursive
    drop ;

M: #call-recursive escape-analysis* ( #call-label -- )
    [ ] [ label>> return>> ] [ node-output-allocations ] tri
    [ [ node-input-allocations ] dip check-fixed-point ]
    [ drop swap [ in-d>> ] [ out-d>> ] bi* copy-values ]
    3bi ;

M: #return-recursive escape-analysis* ( #return-recursive -- )
    [ call-next-method ]
    [
        [ in-d>> ] [ label>> calls>> ] bi
        [ node>> out-d>> escaping-values get '[ _ equate ] 2each ] with each
    ] bi ;
