! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel namespaces strings hashtables sequences 
assocs combinators vocabs.loader init threads continuations
math accessors concurrency.flags destructors
io io.backend io.timeouts io.pipes io.pipes.private io.encodings
io.streams.duplex io.nonblocking ;
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
    process-handle >boolean ;

! Non-blocking process exit notification facility
SYMBOL: processes

[ H{ } clone processes set-global ] "io.launcher" add-init-hook

HOOK: wait-for-processes io-backend ( -- ? )

SYMBOL: wait-flag

: wait-loop ( -- )
    processes get assoc-empty?
    [ wait-flag get-global lower-flag ]
    [ wait-for-processes [ 100 sleep ] when ] if ;

: start-wait-thread ( -- )
    <flag> wait-flag set-global
    [ wait-loop t ] "Process wait" spawn-server drop ;

[ start-wait-thread ] "io.launcher" add-init-hook

: process-started ( process handle -- )
    >>handle
    V{ } clone swap processes get set-at
    wait-flag get-global raise-flag ;

M: process hashcode* process-handle hashcode* ;

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

M: process >process
    dup process-started? [
        "Process has already been started once" throw
    ] when
    clone ;

M: object >process <process> swap >>command ;

HOOK: current-process-handle io-backend ( -- handle )

HOOK: run-process* io-backend ( process -- handle )

: wait-for-process ( process -- status )
    [
        dup handle>>
        [
            dup [ processes get at push ] curry
            "process" suspend drop
        ] when
        dup killed>>
        [ "Process was killed" throw ] [ status>> ] if
    ] with-timeout ;

: run-detached ( desc -- process )
    >process
    dup dup run-process* process-started
    dup timeout>> [ over set-timeout ] when* ;

: run-process ( desc -- process )
    run-detached
    dup detached>> [ dup wait-for-process drop ] unless ;

ERROR: process-failed code ;

: try-process ( desc -- )
    run-process wait-for-process dup zero?
    [ drop ] [ process-failed ] if ;

HOOK: kill-process* io-backend ( handle -- )

: kill-process ( process -- )
    t >>killed
    handle>> [ kill-process* ] when* ;

M: process timeout timeout>> ;

M: process set-timeout set-process-timeout ;

M: process timed-out kill-process ;

M: object run-pipeline-element
    [ >process swap >>stdout swap >>stdin run-detached ]
    [ drop [ [ close-handle ] when* ] bi@ ]
    3bi
    wait-for-process ;

: <process-reader*> ( process encoding -- process stream )
    [
        >r (pipe) {
            [ add-error-destructor ]
            [
                swap >process
                    [ swap out>> or ] change-stdout
                run-detached
            ]
            [ out>> close-handle ]
            [ in>> <input-port> ]
        } cleave r> <decoder>
    ] with-destructors ;

: <process-reader> ( desc encoding -- stream )
    <process-reader*> nip ; inline

: <process-writer*> ( process encoding -- process stream )
    [
        >r (pipe) {
            [ add-error-destructor ]
            [
                swap >process
                    [ swap in>> or ] change-stdout
                run-detached
            ]
            [ in>> close-handle ]
            [ out>> <output-port> ]
        } cleave r> <encoder>
    ] with-destructors ;

: <process-writer> ( desc encoding -- stream )
    <process-writer*> nip ; inline

: <process-stream*> ( process encoding -- process stream )
    [
        >r (pipe) (pipe) {
            [ [ add-error-destructor ] bi@ ]
            [
                rot >process
                    [ swap out>> or ] change-stdout
                    [ swap in>> or ] change-stdin
                run-detached
            ]
            [ [ in>> close-handle ] [ out>> close-handle ] bi* ]
            [ [ in>> <input-port> ] [ out>> <output-port> ] bi* ]
        } 2cleave r> <encoder-duplex>
    ] with-destructors ;

: <process-stream> ( desc encoding -- stream )
    <process-stream*> nip ; inline

: notify-exit ( process status -- )
    >>status
    [ processes get delete-at* drop [ resume ] each ] keep
    f >>handle
    drop ;

GENERIC: underlying-handle ( stream -- handle )

M: port underlying-handle handle>> ;

M: duplex-stream underlying-handle
    [ in>> underlying-handle ]
    [ out>> underlying-handle ] bi
    [ = [ "Invalid duplex stream" throw ] when ] keep ;

M: encoder underlying-handle
    stream>> underlying-handle ;

M: decoder underlying-handle
    stream>> underlying-handle ;
