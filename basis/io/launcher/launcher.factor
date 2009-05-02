! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel namespaces strings hashtables sequences 
assocs combinators vocabs.loader init threads continuations
math accessors concurrency.flags destructors environment
io io.encodings.ascii io.backend io.timeouts io.pipes
io.pipes.private io.encodings io.streams.duplex io.ports
debugger prettyprint summary calendar ;
IN: io.launcher

TUPLE: process < identity-tuple

command
detached

environment
environment-mode

stdin
stdout
stderr

priority

timeout

handle status
killed ;

SYMBOL: +closed+
SYMBOL: +stdout+

TUPLE: appender path ;

: <appender> ( path -- appender ) appender boa ;

SYMBOL: +prepend-environment+
SYMBOL: +replace-environment+
SYMBOL: +append-environment+

SYMBOL: +lowest-priority+
SYMBOL: +low-priority+
SYMBOL: +normal-priority+
SYMBOL: +high-priority+
SYMBOL: +highest-priority+
SYMBOL: +realtime-priority+

: <process> ( -- process )
    process new
    H{ } clone >>environment
    +append-environment+ >>environment-mode ;

: process-started? ( process -- ? )
    dup handle>> swap status>> or ;

: process-running? ( process -- ? )
    handle>> >boolean ;

! Non-blocking process exit notification facility
SYMBOL: processes

HOOK: wait-for-processes io-backend ( -- ? )

SYMBOL: wait-flag

: wait-loop ( -- )
    processes get assoc-empty?
    [ wait-flag get-global lower-flag ]
    [ wait-for-processes [ 100 milliseconds sleep ] when ] if ;

: start-wait-thread ( -- )
    <flag> wait-flag set-global
    [ wait-loop t ] "Process wait" spawn-server drop ;

[
    H{ } clone processes set-global
    start-wait-thread
] "io.launcher" add-init-hook

: process-started ( process handle -- )
    >>handle
    V{ } clone swap processes get set-at
    wait-flag get-global raise-flag ;

M: process hashcode* handle>> hashcode* ;

: pass-environment? ( process -- ? )
    dup environment>> assoc-empty? not
    swap environment-mode>> +replace-environment+ eq? or ;

: get-environment ( process -- env )
    dup environment>>
    swap environment-mode>> {
        { +prepend-environment+ [ os-envs assoc-union ] }
        { +append-environment+ [ os-envs swap assoc-union ] }
        { +replace-environment+ [ ] }
    } case ;

: string-array? ( obj -- ? )
    dup sequence? [ [ string? ] all? ] [ drop f ] if ;

GENERIC: >process ( obj -- process )

ERROR: process-already-started process ;

M: process-already-started error.
    "Process has already been started" print nl
    "Launch descriptor:" print nl
    process>> . ;

M: process >process
    dup process-started? [
        process-already-started
    ] when
    clone ;

M: object >process <process> swap >>command ;

HOOK: current-process-handle io-backend ( -- handle )

HOOK: run-process* io-backend ( process -- handle )

ERROR: process-was-killed process ;

M: process-was-killed error.
    "Process was killed as a result of a call to" print
    "kill-process, or a timeout" print
    nl
    "Launch descriptor:" print nl
    process>> . ;

: wait-for-process ( process -- status )
    [
        dup handle>>
        [
            dup [ processes get at push ] curry
            "process" suspend drop
        ] when
        dup killed>>
        [ process-was-killed ] [ status>> ] if
    ] with-timeout ;

: run-detached ( desc -- process )
    >process
    dup dup run-process* process-started
    dup timeout>> [ over set-timeout ] when* ;

: run-process ( desc -- process )
    run-detached
    dup detached>> [ dup wait-for-process drop ] unless ;

ERROR: process-failed process code ;

M: process-failed error.
    dup "Process exited with error code " write code>> . nl
    "Launch descriptor:" print nl
    process>> . ;

: wait-for-success ( process -- )
    dup wait-for-process dup 0 =
    [ 2drop ] [ process-failed ] if ;

: try-process ( desc -- )
    run-process wait-for-success ;

HOOK: kill-process* io-backend ( handle -- )

: kill-process ( process -- )
    t >>killed
    handle>> [ kill-process* ] when* ;

M: process timeout timeout>> ;

M: process set-timeout swap >>timeout drop ;

M: process cancel-operation kill-process ;

M: object run-pipeline-element
    [ >process swap >>stdout swap >>stdin run-detached ]
    [ drop [ [ dispose ] when* ] bi@ ]
    3bi
    wait-for-process ;

: <process-reader*> ( desc encoding -- stream process )
    [
        [
            (pipe) {
                [ |dispose drop ]
                [
                    swap >process
                        [ swap out>> or ] change-stdout
                    run-detached
                ]
                [ out>> dispose ]
                [ in>> <input-port> ]
            } cleave
        ] dip <decoder> swap
    ] with-destructors ;

: <process-reader> ( desc encoding -- stream )
    <process-reader*> drop ; inline

: with-process-reader ( desc encoding quot -- )
    [ <process-reader*> ] dip
    swap [ with-input-stream ] dip
    wait-for-success ; inline

: <process-writer*> ( desc encoding -- stream process )
    [
        [
            (pipe) {
                [ |dispose drop ]
                [
                    swap >process
                        [ swap in>> or ] change-stdin
                    run-detached
                ]
                [ in>> dispose ]
                [ out>> <output-port> ]
            } cleave
        ] dip <encoder> swap
    ] with-destructors ;

: <process-writer> ( desc encoding -- stream )
    <process-writer*> drop ; inline

: with-process-writer ( desc encoding quot -- )
    [ <process-writer*> ] dip
    swap [ with-output-stream ] dip
    wait-for-success ; inline

: <process-stream*> ( desc encoding -- stream process )
    [
        [
            (pipe) (pipe) {
                [ [ |dispose drop ] bi@ ]
                [
                    rot >process
                        [ swap in>> or ] change-stdin
                        [ swap out>> or ] change-stdout
                    run-detached
                ]
                [ [ out>> dispose ] [ in>> dispose ] bi* ]
                [ [ in>> <input-port> ] [ out>> <output-port> ] bi* ]
            } 2cleave
        ] dip <encoder-duplex> swap
    ] with-destructors ;

: <process-stream> ( desc encoding -- stream )
    <process-stream*> drop ; inline

: with-process-stream ( desc encoding quot -- )
    [ <process-stream*> ] dip
    swap [ with-stream ] dip
    wait-for-success ; inline

: notify-exit ( process status -- )
    >>status
    [ processes get delete-at* drop [ resume ] each ] keep
    f >>handle
    drop ;

{
    { [ os unix? ] [ "io.launcher.unix" require ] }
    { [ os winnt? ] [ "io.launcher.windows.nt" require ] }
    [ ]
} cond

: run-desc ( desc -- result ) ascii <process-reader> f swap stream-read-until drop ;
