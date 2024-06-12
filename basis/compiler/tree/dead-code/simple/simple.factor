! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra combinators
combinators.short-circuit compiler.tree
compiler.tree.dead-code.liveness compiler.tree.propagation.info
fry kernel locals math math.private namespaces sequences
stack-checker.backend stack-checker.dependencies words ;
IN: compiler.tree.dead-code.simple

: flushable-call? ( #call -- ? )
    dup word>> dup flushable? [
        word>input-infos [
            [ node-input-infos ] dip
            [ value-info<= ] 2all?
        ] [ drop t ] if*
    ] [ 2drop f ] if ;

M: #call mark-live-values*
    dup flushable-call? [ drop ] [ look-at-inputs ] if ;

M: #alien-node mark-live-values* look-at-inputs ;

M: #return mark-live-values* look-at-inputs ;

: look-at-mapping ( value inputs outputs -- )
    [ index ] dip over [ nth look-at-value ] [ 2drop ] if ;

M: #copy compute-live-values*
    ! If the output of a copy is live, then the corresponding
    ! input is live also.
    [ out-d>> ] [ in-d>> ] bi look-at-mapping ;

M: #call compute-live-values* nip look-at-inputs ;

M: #shuffle compute-live-values*
    mapping>> at look-at-value ;

M: #alien-node compute-live-values* nip look-at-inputs ;

: filter-mapping ( assoc -- assoc' )
    live-values get '[ _ key? ] filter-keys ;

: filter-corresponding ( new old -- old' )
    zip filter-mapping values ;

: filter-live ( values -- values' )
    dup empty? [ live-values get '[ _ at ] filter ] unless ;

:: drop-values ( inputs outputs mapping-keys mapping-values -- #shuffle )
    inputs
    outputs
    outputs
    mapping-keys
    mapping-values
    filter-corresponding zip <#data-shuffle> ; inline

:: drop-dead-values ( outputs -- #shuffle )
    outputs length make-values :> new-outputs
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
    [ out-d>> first live-value? ] 1verify ;

: dead-flushable-call? ( #call -- ? )
    dup flushable-call? [
        out-d>> [ live-value? not ] all?
    ] [ drop f ] if ;

: remove-flushable-call ( #call -- node )
    [ word>> add-depends-on-flushable ]
    [ in-d>> <#drop> remove-dead-code* ]
    bi ;

: define-simplifications ( word seq -- )
    "simplifications" set-word-prop ;

! true if dead
\ /mod {
    { { f t } /i }
    { { t f } mod }
} define-simplifications

\ fixnum/mod {
    { { f t } fixnum/i }
    { { t f } fixnum-mod }
} define-simplifications

\ bignum/mod {
    { { f t } bignum/i }
    { { t f } bignum-mod }
} define-simplifications

: out-d-matches? ( out-d seq -- ? )
    [ swap live-value? xor ] 2all? ;

: (simplify-call) ( #call -- new-word/f )
    [ out-d>> ] [ word>> "simplifications" word-prop ] bi
    [ first out-d-matches? ] with find nip dup [ second ] when ;

: simplify-call ( #call -- nodes )
    dup (simplify-call) [
        >>word [ filter-live ] change-out-d
    ] [
        maybe-drop-dead-outputs
    ] if* ;

M: #call remove-dead-code*
    {
        { [ dup dead-flushable-call? ] [ remove-flushable-call ] }
        { [ dup word>> "simplifications" word-prop ] [ simplify-call ] }
        [ maybe-drop-dead-outputs ]
    } cond ;

M: #shuffle remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-out-d
    [ filter-live ] change-in-r
    [ filter-live ] change-out-r
    [ filter-mapping ] change-mapping
    dup { [ in-d>> empty? ] [ in-r>> empty? ] } 1&& [ drop f ] when ;

M: #copy remove-dead-code*
    [ in-d>> ] [ out-d>> ] bi
    2dup swap zip <#data-shuffle>
    remove-dead-code* ;

M: #terminate remove-dead-code*
    [ filter-live ] change-in-d
    [ filter-live ] change-in-r ;

M: #alien-node remove-dead-code*
    maybe-drop-dead-outputs ;

M: #alien-callback remove-dead-code*
    [ (remove-dead-code) ] change-child ;
