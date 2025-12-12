! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types classes.struct
continuations glib.ffi io.backend.unix.multiplexers io.thread
kernel libc literals locals math namespaces threads ;
IN: glib.backend

<PRIVATE

: io-prepare ( source timeout -- ? )
    2drop f ;

: io-check ( source -- ? )
    poll_fds>> 0 g_slist_nth_data GPollFD memory>struct
    revents>> 0 = not ;

: io-dispatch ( source callback user-data -- ? )
    3drop
    0 mx get-global wait-for-events
    yield t ;

: <funcs> ( -- funcs )
    GSourceFuncs malloc-struct
        [ io-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ io-check ] GSourceFuncsCheckFunc >>check
        [ io-dispatch ] GSourceFuncsDispatchFunc >>dispatch ;

CONSTANT: poll-fd-events
    flags{
        G_IO_IN
        G_IO_OUT
        G_IO_PRI
        G_IO_ERR
        G_IO_HUP
        G_IO_NVAL
    }

: <poll-fd> ( -- poll-fd )
    GPollFD malloc-struct &free
        mx get-global fd>> >>fd
        poll-fd-events >>events ;

PRIVATE>

:: with-io ( quot -- )
    stop-io-thread
    <funcs> &free
    GSource heap-size g_source_new &g_source_unref :> source
    source <poll-fd> g_source_add_poll
    source f g_source_attach drop
    [ quot call( -- ) ]
    [
        source g_source_destroy
        start-io-thread
    ] finally ;

<PRIVATE

: set-timeout*-value ( alien value -- )
    swap 0 set-alien-signed-4 ; inline

: timer-prepare ( source timeout* -- ? )
    nip sleep-time 1,000,000,000 or
    [ 1,000,000 /i set-timeout*-value ] keep 0 = ;

: timer-check ( source -- ? )
    drop sleep-time 0 = ;

: timer-dispatch ( source callback user_data -- ? )
    3drop yield t ;

: <timer-funcs> ( -- timer-funcs )
    GSourceFuncs malloc-struct
        [ timer-prepare ] GSourceFuncsPrepareFunc >>prepare
        [ timer-check ] GSourceFuncsCheckFunc >>check
        [ timer-dispatch ] GSourceFuncsDispatchFunc >>dispatch ;

PRIVATE>

:: with-timer ( quot -- )
    <timer-funcs> &free
    GSource heap-size g_source_new &g_source_unref :> source
    source G_PRIORITY_DEFAULT_IDLE g_source_set_priority
    source f g_source_attach drop
    [ quot call( -- ) ]
    [ source g_source_destroy ] finally ;
