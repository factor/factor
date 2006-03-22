! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors gadgets hashtables io kernel math
namespaces prettyprint sequences threads ;

GENERIC: expose-event ( event window -- )

GENERIC: resize-event ( event window -- )

GENERIC: button-down-event ( event window -- )

GENERIC: button-up-event ( event window -- )

GENERIC: motion-event ( event window -- )

GENERIC: key-event ( event window -- )

GENERIC: client-event ( event window -- )

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
    >r dpy get r> "XEvent" <c-object> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: wait-event ( -- event )
    QueuedAfterFlush events-queued 0 >
    [ next-event ] [ ui-step wait-event ] if ;

: handle-event ( event window -- )
    over XAnyEvent-type {
        { [ dup Expose = ] [ drop expose-event ] }
        { [ dup ConfigureNotify = ] [ drop resize-event ] }
        { [ dup ButtonPress = ] [ drop button-down-event ] }
        { [ dup ButtonRelease = ] [ drop button-up-event ] }
        { [ dup MotionNotify = ] [ drop motion-event ] }
        { [ dup KeyPress = ] [ drop key-event ] }
        { [ dup ClientMessage = ] [ drop client-event ] }
        { [ t ] [ 3drop ] }
    } cond ;

: event-loop ( -- )
    wait-event dup XAnyEvent-window windows get hash dup
    [ handle-event ] [ 2drop ] if event-loop ;
