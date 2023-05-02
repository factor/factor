! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct continuations glib.ffi
io.backend.unix.multiplexers io.thread kernel libc literals locals
namespaces threads ;
IN: ui.backend.gtk2.io

: prepare ( source timeout -- ? )
    2drop f ;

: check ( source -- ? )
    poll_fds>> 0 g_slist_nth_data GPollFD memory>struct
    revents>> 0 = not ;

: dispatch ( source callback user-data -- ? )
    3drop
    0 mx get-global wait-for-events
    yield t ;

: <funcs> ( -- funcs )
    GSourceFuncs malloc-struct
        [ prepare ] GSourceFuncsPrepareFunc >>prepare
        [ check ] GSourceFuncsCheckFunc >>check
        [ dispatch ] GSourceFuncsDispatchFunc >>dispatch ;

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

:: with-event-loop ( quot -- )
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
