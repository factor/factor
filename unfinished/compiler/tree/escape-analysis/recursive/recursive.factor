! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math combinators accessors namespaces
compiler.tree
compiler.tree.copy-equiv
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

: check-fixed-point ( node alloc1 alloc2 -- node )
    [ congruent? ] 2all?
    [ dup label>> f >>fixed-point drop ] unless ; inline

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
        [ [ allocation ] map check-fixed-point drop ]
        [ record-allocations ]
        2bi
    ] 2bi ;

M: #recursive escape-analysis* ( #recursive -- )
    [
        ! copies [ clone ] change

        child>>
        [ first analyze-recursive-phi ]
        [ (escape-analysis) ]
        bi
    ] until-fixed-point ;

M: #call-recursive escape-analysis* ( #call-label -- )
    dup
    [ node-output-allocations ]
    [ label>> return>> node-input-allocations ] bi
    [ check-fixed-point ] keep
    swap out-d>> record-allocations ;

! M: #return-recursive escape-analysis* ( #return-recursive -- )
!     dup dup label>> calls>> dup empty? [ 3drop ] [
!         [ node-input-allocations ]
!         [ first node-output-allocations ] bi*
!         check-fixed-point drop
!     ] if ;
