! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.timeouts system kernel namespaces
strings hashtables sequences assocs combinators vocabs.loader
init threads continuations math io.encodings io.streams.duplex
io.nonblocking accessors ;
IN: io.launcher

TUPLE: process

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
SYMBOL: +inherit+
SYMBOL: +stdout+

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
    process construct-empty
    H{ } clone >>environment
    +append-environment+ >>environment-mode ;

: process-started? ( process -- ? )
    dup handle>> swap status>> or ;

: process-running? ( process -- ? )
    process-handle >boolean ;

! Non-blocking process exit notification facility
SYMBOL: processes

[ H{ } clone processes set-global ] "io.launcher" add-init-hook

HOOK: register-process io-backend ( process -- )

M: object register-process drop ;

: process-started ( process handle -- )
    >>handle
    V{ } clone over processes get set-at
    register-process ;

M: process equal? 2drop f ;

M: process hashcode* process-handle hashcode* ;

: pass-environment? ( process -- ? )
    dup environment>> assoc-empty? not
    swap environment-mode>> +replace-environment+ eq? or ;

: get-environment ( process -- env )
    dup environment>>
    swap environment-mode>> {
        { +prepend-environment+ [ os-envs union ] }
        { +append-environment+ [ os-envs swap union ] }
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

TUPLE: process-failed code ;

: process-failed ( code -- * )
    \ process-failed construct-boa throw ;

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

HOOK: (process-stream) io-backend ( process -- handle in out )

TUPLE: process-stream process ;

: <process-stream> ( desc encoding -- stream )
    >r >process dup dup (process-stream)
    >r >r process-started process-stream construct-boa
    r> r> <reader&writer> r> <encoder-duplex>
    over set-delegate ;

: with-process-stream ( desc quot -- status )
    swap <process-stream>
    [ swap with-stream ] keep
    process>> wait-for-process ; inline

: notify-exit ( process status -- )
    >>status
    [ processes get delete-at* drop [ resume ] each ] keep
    f >>handle
    drop ;

GENERIC: underlying-handle ( stream -- handle )

M: port underlying-handle port-handle ;

M: duplex-stream underlying-handle
    dup duplex-stream-in underlying-handle
    swap duplex-stream-out underlying-handle tuck =
    [ "Invalid duplex stream" throw ] when ;
