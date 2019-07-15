USING: accessors assocs compiler.tree compiler.tree.combinators
compiler.tree.propagation compiler.tree.propagation.info hashtables.identity io
kernel namespaces prettyprint sequences words ;

IN: compiler.tree.locals
USE: locals.backend

PREDICATE: local-writer-node < #call word>> \ set-local-value = ;

SYMBOL: local-infos

SYMBOL: track-local-infos
: track-local-infos? ( -- ? ) track-local-infos get ;

GENERIC: compute-box-info* ( node -- )

M: object compute-box-info* drop ;
M: local-writer-node compute-box-info*
    ! "local-writer-compute-box-info" print
    dup .
    node-input-infos first2 literal>>
    local-infos get push-at ;

! This pass must run between two propagation passes
: compute-local-boxes ( nodes -- nodes )
    ! "local box compute ?" print
    track-local-infos?
    [
        ! "local box compute" print
        dup
        [ compute-box-info* ] each-node
    ] when ;

: optimize-locals ( nodes -- nodes )
    ! "optimize locals" print
    IH{ } clone local-infos set
    compute-local-boxes
    local-infos get assoc-empty?
    [ propagate ] unless ;

! Info is a union type on all set locations including literal at call site
: (local-value-info) ( box -- info' )
    [ local-infos get at ] [ first clone <literal-info> ] bi
    prefix value-infos-union
    ! dup .
    ;

\ local-value [
    ! "local-value-outputs" print
    track-local-infos? [
        literal>> (local-value-info)
    ] [ drop object-info ] if
] "outputs" set-word-prop


! Hack inlining so loading this triggers the new behavior, this should obviously
! be removed and local-value and set-local-value defined non-inline properly

{ set-local-value local-value } [ f "inline" set-word-prop ] each
