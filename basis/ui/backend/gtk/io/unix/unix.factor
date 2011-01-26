! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct glib.ffi
io.backend.unix.multiplexers io.thread kernel libc literals namespaces
system threads ui.backend.gtk.io ;
IN: ui.backend.gtk.io.unix

: prepare ( source timeout -- ? )
    2drop f ;

: check ( source -- ? )
    poll_fds>> 0 g_slist_nth_data GPollFD memory>struct
    revents>> 0 = not ;

: dispatch ( source callback user-data -- ? )
     3drop
     0 mx get wait-for-events
     yield t ;

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
        mx get fd>> >>fd
        poll-fd-events >>events ;

M: unix init-io-event-source
    stop-io-thread
    GSourceFuncs malloc-struct &free
        [ prepare ] GSourceFuncsPrepareFunc >>prepare
        [ check ] GSourceFuncsCheckFunc >>check
        [ dispatch ] GSourceFuncsDispatchFunc >>dispatch
    GSource heap-size g_source_new &g_source_unref
    [ <poll-fd> g_source_add_poll ]
    [ f g_source_attach drop ] bi ;
