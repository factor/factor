! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors words assocs sequences arrays
compiler.tree stack-checker.backend
compiler.tree.dead-code.liveness ;
IN: compiler.tree.dead-code.simple

M: #call mark-live-values*
    dup word>> "flushable" word-prop
    [ drop ] [ look-at-inputs ] if ;

M: #alien-invoke mark-live-values* look-at-inputs ;

M: #alien-indirect mark-live-values* look-at-inputs ;

M: #return mark-live-values* look-at-inputs ;

: look-at-mapping ( value inputs outputs -- )
    [ index ] dip over [ nth look-at-value ] [ 2drop ] if ;

M: #copy compute-live-values*
    #! If the output of a copy is live, then the corresponding
    #! input is live also.
    [ out-d>> ] [ in-d>> ] bi look-at-mapping ;

M: #call compute-live-values* nip look-at-inputs ;

M: #call-recursive compute-live-values*
    #! If the output of a copy is live, then the corresponding
    #! inputs to #return nodes are live also.
    [ out-d>> ] [ label>> return>> ] bi look-at-mapping ;

M: #>r compute-live-values*
    [ out-r>> ] [ in-d>> ] bi look-at-mapping ;

M: #r> compute-live-values*
    [ out-d>> ] [ in-r>> ] bi look-at-mapping ;

M: #shuffle compute-live-values*
    mapping>> at look-at-value ;

M: #alien-invoke compute-live-values* nip look-at-inputs ;

M: #alien-indirect compute-live-values* nip look-at-inputs ;

M: #introduce remove-dead-code*
    dup value>> live-value? [
        dup value>> 1array #drop 2array
    ] unless ;

: filter-live ( values -- values' )
    [ live-value? ] filter ;

M: #>r remove-dead-code*
    [ filter-live ] change-out-r
    [ filter-live ] change-in-d
    dup in-d>> empty? [ drop f ] when ;

M: #r> remove-dead-code*
    [ filter-live ] change-out-d
    [ filter-live ] change-in-r
    dup in-r>> empty? [ drop f ] when ;

M: #push remove-dead-code*
    dup out-d>> first live-value? [ drop f ] unless ;

: dead-flushable-call? ( #call -- ? )
    [ word>> "flushable" word-prop ]
    [ out-d>> [ live-value? not ] all? ] bi and ;

: remove-flushable-call ( #call -- node )
    in-d>> #drop remove-dead-code* ;

: some-outputs-dead? ( #call -- ? )
    out-d>> [ live-value? not ] contains? ;

: drop-dead-outputs ( #call -- nodes )
    [ out-d>> ] [ [ make-values ] change-out-d ] bi
    [ nip ] [ out-d>> swap #copy remove-dead-code* ] 2bi
    2array ;

M: #call remove-dead-code*
    dup dead-flushable-call? [
        remove-flushable-call
    ] [
        dup some-outputs-dead? [
            drop-dead-outputs
        ] when
    ] if ;

M: #shuffle remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    dup in-d>> empty? [ drop f ] when ;

M: #copy remove-dead-code*
    [ in-d>> ] [ out-d>> ] bi
    2dup swap zip #shuffle
    remove-dead-code* ;
