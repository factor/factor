! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types classes.struct
continuations glib.ffi io.backend kernel libc locals math
threads ;
IN: ui.backend.gtk.io

HOOK: with-event-loop io-backend ( quot -- )

! Timer

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

M:: object with-event-loop ( quot -- )
    <timer-funcs> &free
    GSource heap-size g_source_new &g_source_unref :> source
    source f g_source_attach drop
    [ quot call( -- ) ]
    [ source g_source_destroy ] [ ] cleanup ;
