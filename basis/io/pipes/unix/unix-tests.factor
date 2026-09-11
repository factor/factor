USING: accessors continuations destructors io io.backend.unix
io.encodings io.encodings.utf8 io.pipes io.pipes.unix kernel math
namespaces sequences sets splitting tools.annotations tools.test ;
FROM: namespaces => set ;
IN: io.pipes.unix.tests

SYMBOL: pipe-init-count
TUPLE: pipe-init-counter n ;

: check-pipe-init ( fd -- fd )
    pipe-init-count get [
        [ 1 + ] change-n n>> 2 = [ "pipe initialization failed" throw ] when
    ] when* ;

! Force the second descriptor initialization to fail after pipe(2) has
! created both ends. Restore the annotation even if the assertion fails.
{ t } [
    [
        \ init-fd [ [ check-pipe-init ] swap compose ] annotate
        0 pipe-init-counter boa pipe-init-count [
            disposables get cardinality
            [ (pipe) dispose ] [ "pipe initialization failed" = ] must-fail-with
            disposables get cardinality =
        ] with-variable
    ] [ \ init-fd reset ] finally
] unit-test

{ { 0 0 } } [ { "ls" "grep ." } run-pipeline ] unit-test

{ { 0 f 0 } } [
    {
        "ls"
        [
            input-stream [ utf8 <decoder> ] change
            output-stream [ utf8 <encoder> ] change
            input-stream get stream-lines reverse write-lines f
        ]
        "grep ."
    } run-pipeline
] unit-test
