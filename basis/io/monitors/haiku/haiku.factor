! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings alien.syntax arrays assocs
classes.struct combinators continuations destructors destructors.private io
hashtables init io.backend io.backend.unix io.monitors io.monitors.recursive
io.pathnames io.ports kernel libc locals math namespaces sequences
system threads vectors ;
IN: io.monitors.haiku

LIBRARY: factor
STRUCT: haiku-monitor-event { action int } { name char[256] } ;
FUNCTION: void* factor_haiku_monitor_open ( c-string path )
FUNCTION: int factor_haiku_monitor_fd ( void* handle )
FUNCTION: int factor_haiku_monitor_take_fd ( void* handle )
FUNCTION: int factor_haiku_monitor_next ( void* handle, haiku-monitor-event* event )
FUNCTION: void factor_haiku_monitor_close ( void* handle )
FUNCTION: int factor_haiku_monitor_shared_dup_fd ( )
FUNCTION: int factor_haiku_monitor_shared_next ( void** handle, haiku-monitor-event* event )

TUPLE: haiku-monitor < monitor handle ;
SYMBOL: haiku-monitors
SYMBOL: haiku-monitor-handles
SYMBOL: haiku-shared-port
STARTUP-HOOK: [
    H{ } clone haiku-monitor-handles set-global
    f haiku-shared-port set-global
]

! Allocate and register the Factor fd owner before native ownership transfers.
! An empty owner can be disposed safely if FFI symbol lookup itself fails.
TUPLE: haiku-monitor-fd < fd ;
M: haiku-monitor-fd dispose
    [
        dup fd>> 0 < [
            [ unregister-disposable ] [ t >>disposed drop ] bi
        ] [ call-next-method ] if
    ] unless-disposed ;

:: haiku-monitor-port ( -- port )
    [
        haiku-monitor-fd new-disposable -1 >>fd |dispose :> owner
        factor_haiku_monitor_shared_dup_fd dup io-error
        owner swap >>fd drop
        owner init-fd <input-port>
    ] with-destructors ;

: haiku-change-action ( action -- changes )
    {
        { 1 [ +add-file+ ] }
        { 2 [ +remove-file+ ] }
        { 3 [ +modify-file+ ] }
        { 4 [ +rename-file-old+ ] }
        { 5 [ +rename-file-new+ ] }
        [ "Invalid Haiku NodeMonitor action" throw ]
    } case 1array ;

M:: haiku-monitor dispose* ( monitor -- )
    [
        monitor handle>> [
            dup alien-address haiku-monitor-handles get-global delete-at
            factor_haiku_monitor_close
        ] when*
    ] [ monitor call-next-method ] finally ;

:: drain-haiku-events ( -- )
    f void* <ref> :> handle
    haiku-monitor-event new :> event
    handle event factor_haiku_monitor_shared_next :> available
    available -1 = [
        errno :> error
        handle void* deref [
            alien-address haiku-monitor-handles get-global at [
                dispose
                [ error (throw-errno) ] "Haiku NodeMonitor error" spawn drop
                drain-haiku-events
            ] [ error (throw-errno) ] if*
        ] [ error (throw-errno) ] if*
    ] [
        available 1 = [
            handle void* deref alien-address haiku-monitor-handles get-global at
            [
                event name>> alien>native-string
                event action>> haiku-change-action rot queue-change
            ] when*
            drain-haiku-events
        ] when
    ] if ;

DEFER: ensure-haiku-reader

: reset-haiku-reader ( -- )
    [ haiku-shared-port get-global [ dispose ] when* ]
    [ f haiku-shared-port set-global ] finally ;

: haiku-read-loop ( -- )
    haiku-shared-port get-global stream-read1 [
        drop drain-haiku-events haiku-read-loop
    ] [ "Haiku shared NodeMonitor pipe closed unexpectedly" throw ] if* ;

: haiku-read-thread ( -- )
    [ haiku-read-loop ] [
        ! An unexpected shared transport failure terminates affected monitors
        ! honestly and permits a later scope to acquire a fresh native dup.
        [
            reset-haiku-reader
            haiku-monitor-handles get-global values dispose-each
        ] dip rethrow
    ] recover ;

: ensure-haiku-reader ( -- )
    haiku-shared-port get-global [ ] [
        [
            haiku-monitor-port haiku-shared-port set-global
            [ haiku-read-thread ] "Haiku shared NodeMonitor reader" spawn drop
        ] [ [ reset-haiku-reader ] dip rethrow ] recover
    ] if ;

:: <haiku-monitor> ( path mailbox -- monitor )
    haiku-monitors get [
        path absolute-path :> path
        path mailbox haiku-monitor new-monitor :> monitor
        [
            path factor_haiku_monitor_open dup
            [ monitor swap >>handle drop ]
            [ errno (throw-errno) ] if
            monitor monitor handle>> alien-address haiku-monitor-handles get-global set-at
            monitor haiku-monitors get push
            monitor
        ] [ monitor dispose rethrow ] recover
    ] [ "Calling <monitor> outside with-monitors" throw ] if ;

M: haiku (monitor)
    swap [ <recursive-monitor> ] [ <haiku-monitor> ] if ;
M: haiku init-monitors ensure-haiku-reader V{ } clone haiku-monitors set ;
M: haiku dispose-monitors haiku-monitors get dispose-each ;
