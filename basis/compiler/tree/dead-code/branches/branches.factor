! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs columns combinators compiler.tree
compiler.tree.dead-code.liveness compiler.tree.dead-code.simple
fry kernel namespaces sequences stack-checker.backend
stack-checker.branches ;
IN: compiler.tree.dead-code.branches

M: #if mark-live-values* look-at-inputs ;

M: #dispatch mark-live-values* look-at-inputs ;

: look-at-phi ( value outputs inputs -- )
    [ index ] dip swap [ <column> look-at-values ] [ drop ] if* ;

M: #phi compute-live-values*
    ! If any of the outputs of a #phi are live, then the
    ! corresponding inputs are live too.
    [ out-d>> ] [ phi-in-d>> ] bi look-at-phi ;

SYMBOL: if-node

M: #branch remove-dead-code*
    [ [ [ (remove-dead-code) ] map ] change-children ]
    [ if-node set ]
    bi ;

: remove-phi-inputs ( #phi -- )
    if-node get children>>
    [ dup ends-with-terminate? [ drop f ] [ last out-d>> ] if ] map
    pad-with-bottom >>phi-in-d drop ;

: live-value-indices ( values -- indices )
    [ length <iota> ] keep live-values get
    '[ _ nth _ key? ] filter ; inline

: drop-indexed-values ( values indices -- node )
    [ drop filter-live ] [ swap nths ] 2bi
    [ length make-values ] keep
    [ drop ] [ zip ] 2bi
    <#data-shuffle> ;

: insert-drops ( nodes values indices -- nodes' )
    '[
        over ends-with-terminate?
        [ drop ] [ _ drop-indexed-values suffix ] if
    ] 2map ;

: hoist-drops ( #phi -- )
    if-node get swap
    [ phi-in-d>> ] [ out-d>> live-value-indices ] bi
    '[ _ _ insert-drops ] change-children drop ;

: remove-phi-outputs ( #phi -- )
    [ filter-live ] change-out-d drop ;

M: #phi remove-dead-code*
    {
        [ hoist-drops ]
        [ remove-phi-inputs ]
        [ remove-phi-outputs ]
        [ ]
    } cleave ;
