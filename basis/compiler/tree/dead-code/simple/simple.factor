! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors words assocs sequences arrays namespaces
fry locals definitions classes classes.algebra generic
stack-checker.state
stack-checker.backend
compiler.tree
compiler.tree.propagation.info
compiler.tree.dead-code.liveness ;
IN: compiler.tree.dead-code.simple

GENERIC: flushable? ( word -- ? )

M: predicate flushable? drop t ;

M: word flushable? "flushable" word-prop ;

M: method-body flushable? "method-generic" word-prop flushable? ;

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

M: #shuffle compute-live-values*
    mapping>> at look-at-value ;

M: #alien-invoke compute-live-values* nip look-at-inputs ;

M: #alien-indirect compute-live-values* nip look-at-inputs ;

: filter-mapping ( assoc -- assoc' )
    live-values get '[ drop _ key? ] assoc-filter ;

: filter-corresponding ( new old -- old' )
    #! Remove elements from 'old' if the element with the same
    #! index in 'new' is dead.
    zip filter-mapping values ;

: filter-live ( values -- values' )
    dup empty? [ [ live-value? ] filter ] unless ;

:: drop-values ( inputs outputs mapping-keys mapping-values -- #shuffle )
    inputs
    outputs
    outputs
    mapping-keys
    mapping-values
    filter-corresponding zip #data-shuffle ; inline

:: drop-dead-values ( outputs -- #shuffle )
    outputs make-values :> new-outputs
    outputs filter-live :> live-outputs
    new-outputs
    live-outputs
    outputs
    new-outputs
    drop-values ;

: drop-dead-outputs ( node -- #shuffle )
    dup out-d>> drop-dead-values [ in-d>> >>out-d drop ] keep ;

: some-outputs-dead? ( #call -- ? )
    out-d>> [ live-value? not ] any? ;

: maybe-drop-dead-outputs ( node -- nodes )
    dup some-outputs-dead? [
        dup drop-dead-outputs 2array
    ] when ;

M: #introduce remove-dead-code* ( #introduce -- nodes )
    maybe-drop-dead-outputs ;

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

M: #call remove-dead-code*
    dup dead-flushable-call?
    [ remove-flushable-call ] [ maybe-drop-dead-outputs ] if ;

M: #shuffle remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    [ filter-live ] change-in-r
    [ filter-live ] change-out-r
    [ filter-mapping ] change-mapping
    dup [ in-d>> empty? ] [ in-r>> empty? ] bi and [ drop f ] when ;

M: #copy remove-dead-code*
    [ in-d>> ] [ out-d>> ] bi
    2dup swap zip #data-shuffle
    remove-dead-code* ;

M: #terminate remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-in-r ;

M: #alien-invoke remove-dead-code*
    maybe-drop-dead-outputs ;

M: #alien-indirect remove-dead-code*
    maybe-drop-dead-outputs ;
