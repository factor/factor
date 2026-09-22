USING: accessors continuations destructors io io.backend.unix
io.buffers io.encodings io.encodings.binary io.encodings.utf8
io.launcher io.pipes io.pipes.private io.pipes.unix kernel libc
locals math namespaces sequences sets splitting tools.annotations
tools.test unix unix.ffi ;
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
            HS{ } clone disposables [
                [ (pipe) dispose f ] [ "pipe initialization failed" = ] recover
                disposables get null? and
            ] with-variable
        ] with-variable
    ] [ \ init-fd reset ] finally
] unit-test

: closed-pipe-end? ( fd -- ? )
    [
        [ disposed>> ]
        [ disposables get in? not ]
        [ fd>> F_GETFD 0 fcntl -1 = errno EBADF = and ] tri and and
    ] preserve-errno ;

: closed-pipe? ( pipe -- ? )
    [ in>> closed-pipe-end? ] [ out>> closed-pipe-end? ] bi and ;

{ t } [
    [let
        0 :> allocations!
        [
            \ <buffer> [
                [
                    allocations 1 + allocations!
                    allocations 2 = [ "second buffer allocation failed" throw ] when
                ] prepose
            ] annotate
            HS{ } clone disposables [
                [ binary <pipe> dispose ]
                [ "second buffer allocation failed" = ] must-fail-with
                disposables get null?
            ] with-variable
        ] [ \ <buffer> reset ] finally
    ]
] unit-test

{ t } [
    [
        \ <buffer> [ drop [ drop "buffer allocation failed" throw ] ] annotate
        (pipe) [| pipe |
            [ pipe [ in>> ] [ out>> ] bi [ f ] run-pipeline-element drop ]
            [ "buffer allocation failed" = ] must-fail-with
            pipe closed-pipe?
        ] with-disposal
    ] [ \ <buffer> reset ] finally
] unit-test

{ t } [
    [
        \ run-detached [ drop [ drop "process launch failed" throw ] ] annotate
        (pipe) [| pipe |
            [ pipe [ in>> ] [ out>> ] bi "unused" run-pipeline-element drop ]
            [ "process launch failed" = ] must-fail-with
            pipe closed-pipe?
        ] with-disposal
    ] [ \ run-detached reset ] finally
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
