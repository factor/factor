! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors words assocs sequences arrays namespaces
fry locals definitions classes.algebra
stack-checker.state
stack-checker.backend
compiler.tree
compiler.tree.propagation.info
compiler.tree.dead-code.liveness ;
IN: compiler.tree.dead-code.simple

: flushable? ( word -- ? )
    [ "flushable" word-prop ] [ "predicating" word-prop ] bi or ;

: flushable-call? ( #call -- ? )
    dup word>> dup flushable? [
        "input-classes" word-prop dup [
            [ node-input-infos ] dip
            [ [ class>> ] dip class<= ] 2all?
        ] [ 2drop t ] if
    ] [ 2drop f ] if ;

M: #call mark-live-values*
    dup flushable-call? [ drop ] [ look-at-inputs ] if ;

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

M: #>r compute-live-values*
    [ out-r>> ] [ in-d>> ] bi look-at-mapping ;

M: #r> compute-live-values*
    [ out-d>> ] [ in-r>> ] bi look-at-mapping ;

M: #shuffle compute-live-values*
    mapping>> at look-at-value ;

M: #alien-invoke compute-live-values* nip look-at-inputs ;

M: #alien-indirect compute-live-values* nip look-at-inputs ;

: filter-mapping ( assoc -- assoc' )
    live-values get '[ drop , key? ] assoc-filter ;

: filter-corresponding ( new old -- old' )
    #! Remove elements from 'old' if the element with the same
    #! index in 'new' is dead.
    zip filter-mapping values ;

: filter-live ( values -- values' )
    [ live-value? ] filter ;

:: drop-values ( inputs outputs mapping-keys mapping-values -- #shuffle )
    inputs
    outputs
    outputs
    mapping-keys
    mapping-values
    filter-corresponding zip #shuffle ; inline

:: drop-dead-values ( outputs -- #shuffle )
    [let* | new-outputs [ outputs make-values ]
            live-outputs [ outputs filter-live ] |
        new-outputs
        live-outputs
        outputs
        new-outputs
        drop-values
    ] ;

: drop-dead-outputs ( node -- nodes )
    dup out-d>> drop-dead-values tuck in-d>> >>out-d drop ;

M: #introduce remove-dead-code* ( #introduce -- nodes )
    dup drop-dead-outputs 2array ;

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
    dup flushable-call? [
        out-d>> [ live-value? not ] all?
    ] [ drop f ] if ;

: remove-flushable-call ( #call -- node )
    [ word>> flushed-dependency depends-on ]
    [ in-d>> #drop remove-dead-code* ]
    bi ;

: some-outputs-dead? ( #call -- ? )
    out-d>> [ live-value? not ] contains? ;

M: #call remove-dead-code*
    dup dead-flushable-call? [
        remove-flushable-call
    ] [
        dup some-outputs-dead? [
            dup drop-dead-outputs 2array
        ] when
    ] if ;

M: #shuffle remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    [ filter-mapping ] change-mapping
    dup in-d>> empty? [ drop f ] when ;

M: #copy remove-dead-code*
    [ in-d>> ] [ out-d>> ] bi
    2dup swap zip #shuffle
    remove-dead-code* ;

M: #terminate remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-in-r ;
