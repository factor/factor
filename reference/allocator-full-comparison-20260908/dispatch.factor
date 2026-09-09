! Diagnostic-only instrumentation. Load in a disposable process, never timing.
USING: accessors assocs compiler.cfg.register-allocation io json kernel
locals namespaces prettyprint quotations sequences tools.annotations vocabs words ;
IN: allocator-full-dispatch-audit

SYMBOL: body-counts

:: note-body ( label -- )
    body-counts get [ label swap inc-at ] when* ;

:: instrument-body ( word label -- )
    word [| old | old label '[ _ note-body ] prepose ] annotate ;

: instrument-methods ( -- )
    \ allocate-cfg "methods" word-prop >alist [
        first2 swap unparse "method:" prepend instrument-body
    ] each ;

! Policy names are supplied by the source audit for the frozen revision.
! Missing routines fail; silently skipping a renamed policy would hide fallback.
:: instrument-policy ( name vocabulary label -- )
    name vocabulary lookup-word
    dup [ label instrument-body ] [ drop "missing audited allocation policy" throw ] if ;

: begin-body-audit ( -- ) H{ } clone body-counts set ;

: end-body-audit ( -- counts )
    body-counts get clone f body-counts set ;

: print-body-audit ( -- ) end-body-audit >json print flush ;
