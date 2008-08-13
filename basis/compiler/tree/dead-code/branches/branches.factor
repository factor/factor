! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences namespaces kernel accessors assocs sets fry
arrays combinators stack-checker.backend compiler.tree
compiler.tree.combinators compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code.branches

M: #if mark-live-values* look-at-inputs ;

M: #dispatch mark-live-values* look-at-inputs ;

: look-at-phi ( value inputs outputs -- )
    [ index ] dip over [ nth look-at-values ] [ 2drop ] if ;

M: #phi compute-live-values*
    #! If any of the outputs of a #phi are live, then the
    #! corresponding inputs are live too.
    [ [ out-d>> ] [ phi-in-d>> ] bi look-at-phi ]
    [ [ out-r>> ] [ phi-in-r>> ] bi look-at-phi ]
    2bi ;

SYMBOL: if-node

M: #if remove-dead-code*
    [ [ (remove-dead-code) ] map ] change-children
    dup if-node set ;

: dead-value-indices ( values -- indices )
    [ length ] keep live-values get
    '[ , nth , key? not ] filter ; inline

: drop-d-values ( values indices -- node )
    [ drop ] [ nths ] 2bi
    dup make-values
    [ nip ] [ zip ] 2bi
    #shuffle ;

: drop-r-values ( values indices -- nodes )
    [ dup make-values [ #r> ] keep ] dip
    drop-d-values dup out-d>> dup make-values #>r
    3array ;

: insert-drops ( nodes d-values r-values d-indices r-indices -- nodes' )
    [ [ flip ] bi@ ] 2dip
    '[
        [ , drop-d-values 1array ]
        [ , drop-r-values ]
        bi* 3append
    ] 3map ;

: remove-phi-inputs ( #phi -- )
    if-node get swap
    {
        [ phi-in-d>> ]
        [ [ phi-in-d>> ] [ out-d>> ] bi dead-value-indices nths ]
        [ phi-in-r>> ]
        [ [ phi-in-r>> ] [ out-r>> ] bi dead-value-indices nths ]
    } cleave
    '[ , , , , insert-drops ] change-children drop ;

: remove-phi-outputs ( #phi -- )
    [ filter-live ] change-out-d
    [ filter-live ] change-out-r
    drop ;

M: #phi remove-dead-code*
    [ remove-phi-inputs ] [ remove-phi-outputs ] [ ] tri ;
