! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs calendar combinators concurrency.flags
debugger destructors environment fry init io io.backend
io.encodings io.encodings.utf8 io.pipes io.pipes.private
io.ports io.streams.duplex io.timeouts kernel math math.order
namespaces prettyprint sequences strings system threads vocabs ;

IN: io.launcher

TUPLE: process < identity-tuple

command
detached
hidden

environment
environment-mode

stdin
stdout
stderr

priority
group

timeout

handle status
killed

pipe ;

SYMBOL: +closed+
SYMBOL: +stdout+

TUPLE: appender path ;

C: <appender> appender

SYMBOL: +prepend-environment+
SYMBOL: +replace-environment+
SYMBOL: +append-environment+

SYMBOL: +lowest-priority+
SYMBOL: +low-priority+
SYMBOL: +normal-priority+
SYMBOL: +high-priority+
SYMBOL: +highest-priority+
SYMBOL: +realtime-priority+

SYMBOL: +same-group+
SYMBOL: +new-group+
SYMBOL: +new-session+

: <process> ( -- process )
    process new
        H{ } clone >>environment
        +append-environment+ >>environment-mode
        +same-group+ >>group ;

: process-started? ( process -- ? )
    [ handle>> ] [ status>> ] bi or ;

: process-running? ( process -- ? )
    handle>> >boolean ;

! Non-blocking process exit notification facility
SYMBOL: processes

HOOK: (wait-for-processes) io-backend ( -- ? )

<PRIVATE

SYMBOL: wait-flag
SYMBOL: wait-delay

: wait-loop ( -- )
    processes get assoc-empty? [
        5 wait-delay set-global
        wait-flag get-global lower-flag
    ] [
        (wait-for-processes) [
            wait-delay [
                [ milliseconds sleep ] [ 5 + 100 max ] bi
            ] change-global
        ] when
    ] if ;

: start-wait-thread ( -- )
    <flag> wait-flag set-global
    5 wait-delay set-global
    [ wait-loop t ] "Process wait" spawn-server drop ;

STARTUP-HOOK: [
    H{ } clone processes set-global
    start-wait-thread
]

: process-started ( process handle -- )
    >>handle
    V{ } clone swap processes get set-at
    wait-flag get-global raise-flag ;

: notify-exit ( process status -- )
    >>status
    [ processes get delete-at* drop [ resume ] each ] keep
    f >>handle drop ;

: pass-environment? ( process -- ? )
    dup environment>> assoc-empty? not
    swap environment-mode>> +replace-environment+ eq? or ;

: get-environment ( process -- env )
    [ environment>> ] [ environment-mode>> ] bi {
        { +prepend-environment+ [ os-envs assoc-union ] }
        { +append-environment+ [ os-envs swap assoc-union ] }
        { +replace-environment+ [ ] }
    } case ;

PRIVATE>

GENERIC: >process ( obj -- process )

ERROR: process-already-started process ;

M: process-already-started error.
    "Process has already been started" print nl
    "Launch descriptor:" print nl
    process>> . ;

M: process >process
    dup process-started? [ process-already-started ] when
    clone ;

M: object >process <process> swap >>command ;

HOOK: (current-process) io-backend ( -- handle )

ERROR: process-was-killed process ;

M: process-was-killed error.
    "Process was killed as a result of a call to" print
    "kill-process, or a timeout" print
    nl
    "Launch descriptor:" print nl
    process>> . ;

: (wait-for-process) ( process -- status )
    dup handle>>
    [ self over processes get at push "process" suspend drop ] when
    dup killed>> [ process-was-killed ] [ status>> ] if ;

: wait-for-process ( process -- status )
    [ (wait-for-process) ] with-timeout ;

HOOK: (run-process) io-backend ( process -- handle )

: run-detached ( desc -- process )
    >process [ dup (run-process) process-started ] keep ;

: run-process ( desc -- process )
    run-detached
    dup detached>> [ dup wait-for-process drop ] unless ;

: run-processes ( descs -- processes )
    [ run-process ] map ;

ERROR: process-failed process ;

M: process-failed error.
    [
        "Process exited with error code " write process>> status>> . nl
        "Launch descriptor:" print nl
    ] [ process>> . ] bi ;

: check-success ( process status -- )
    0 = [ drop ] [ process-failed ] if ;

GENERIC: wait-for-success ( obj -- )

M: process wait-for-success
    dup wait-for-process check-success ;

M: sequence wait-for-success
    [ wait-for-success ] each ;

: try-process ( desc -- )
    run-process wait-for-success ;

HOOK: (kill-process) io-backend ( process -- )

: kill-process ( process -- )
    t >>killed
    [ pipe>> [ dispose ] when* ]
    [ dup handle>> [ (kill-process) ] [ drop ] if ] bi ;

M: process timeout timeout>> ;

M: process set-timeout timeout<< ;

M: process cancel-operation kill-process ;

M: object run-pipeline-element
    [
        >process
            swap >>stdout
            swap >>stdin
        run-detached
    ] [
        [
            drop [ [ &dispose drop ] when* ] bi@
        ] with-destructors
    ] 3bi wait-for-process ;

<PRIVATE

: <process-with-pipe> ( desc -- process pipe )
    >process (pipe) |dispose [ >>pipe ] keep ;

: (process-reader) ( desc encoding -- stream process )
    [
        [
            <process-with-pipe> {
                [ '[ _ out>> or ] change-stdout ]
                [ drop run-detached ]
                [ out>> dispose ]
                [ in>> <input-port> ]
            } cleave
        ] dip <decoder> swap
    ] with-destructors ;

PRIVATE>

: <process-reader> ( desc encoding -- stream )
    (process-reader) drop ; inline

: with-process-reader* ( desc encoding quot -- process status )
    [ (process-reader) ] dip '[
        [ _ with-input-stream ] dip dup (wait-for-process)
    ] with-timeout ; inline

: with-process-reader ( desc encoding quot -- )
    with-process-reader* check-success ; inline

: process-lines ( desc -- lines )
    utf8 <process-reader> stream-lines ;

: process-contents ( desc -- contents )
    utf8 <process-reader> stream-contents ;

<PRIVATE

: (process-writer) ( desc encoding -- stream process )
    [
        [
            <process-with-pipe> {
                [ '[ _ in>> or ] change-stdin ]
                [ drop run-detached ]
                [ in>> dispose ]
                [ out>> <output-port> ]
            } cleave
        ] dip <encoder> swap
    ] with-destructors ;

PRIVATE>

: <process-writer> ( desc encoding -- stream )
    (process-writer) drop ; inline

: with-process-writer* ( desc encoding quot -- process status )
    [ (process-writer) ] dip '[
        [ _ with-output-stream ] dip dup (wait-for-process)
    ] with-timeout ; inline

: with-process-writer ( desc encoding quot -- )
    with-process-writer* check-success ; inline

<PRIVATE

: (process-stream) ( desc encoding -- stream process )
    [
        [
            (pipe) |dispose
            (pipe) |dispose {
                [
                    rot >process t >>hidden
                        [ swap in>> or ] change-stdin
                        [ swap out>> or ] change-stdout
                    run-detached
                ]
                [ [ out>> &dispose drop ] [ in>> &dispose drop ] bi* ]
                [ [ in>> <input-port> ] [ out>> <output-port> ] bi* ]
            } 2cleave
        ] dip <encoder-duplex> swap
    ] with-destructors ;

PRIVATE>

: <process-stream> ( desc encoding -- stream )
    (process-stream) drop ; inline

: with-process-stream* ( desc encoding quot -- process status )
    [ (process-stream) ] dip '[
        [ _ with-stream ] dip dup (wait-for-process)
    ] with-timeout ; inline

: with-process-stream ( desc encoding quot -- )
    with-process-stream* check-success ; inline

ERROR: output-process-error { output string } { process process } ;

M: output-process-error error.
    [ "Process:" print process>> . nl ]
    [ "Output:" print output>> print ]
    bi ;

: try-output-process ( command -- )
    >process
    +stdout+ >>stderr
    [ +closed+ or ] change-stdin
    utf8 (process-reader)
    [ [ stream-contents ] [ dup (wait-for-process) ] bi* ] with-timeout
    0 = [ 2drop ] [ output-process-error ] if ;

{
    { [ os unix? ] [ "io.launcher.unix" require ] }
    { [ os windows? ] [ "io.launcher.windows" require ] }
} cond
