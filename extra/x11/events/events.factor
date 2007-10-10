! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays hashtables io kernel math
namespaces prettyprint sequences strings combinators x11.xlib ;
IN: x11.events

GENERIC: expose-event ( event window -- )

GENERIC: configure-event ( event window -- )

GENERIC: button-down-event ( event window -- )

GENERIC: button-up-event ( event window -- )

GENERIC: enter-event ( event window -- )

GENERIC: leave-event ( event window -- )

GENERIC: wheel-event ( event window -- )

GENERIC: motion-event ( event window -- )

GENERIC: key-down-event ( event window -- )

GENERIC: key-up-event ( event window -- )

GENERIC: focus-in-event ( event window -- )

GENERIC: focus-out-event ( event window -- )

GENERIC: selection-notify-event ( event window -- )

GENERIC: selection-request-event ( event window -- )

GENERIC: client-event ( event window -- )

: next-event ( -- event )
    dpy get "XEvent" <c-object> dup >r XNextEvent drop r> ;

: mask-event ( mask -- event )
    >r dpy get r> "XEvent" <c-object> dup >r XMaskEvent drop r> ;

: events-queued ( mode -- n ) >r dpy get r> XEventsQueued ;

: wheel? ( event -- ? ) XButtonEvent-button 4 7 between? ;

: button-down-event$ ( event window -- )
    over wheel? [ wheel-event ] [ button-down-event ] if ;

: button-up-event$ ( event window -- )
    over wheel? [ 2drop ] [ button-up-event ] if ;

: handle-event ( event window -- )
    over XAnyEvent-type {
        { [ dup Expose = ] [ drop expose-event ] }
        { [ dup ConfigureNotify = ] [ drop configure-event ] }
        { [ dup ButtonPress = ] [ drop button-down-event$ ] }
        { [ dup ButtonRelease = ] [ drop button-up-event$ ] }
        { [ dup EnterNotify = ] [ drop enter-event ] }
        { [ dup LeaveNotify = ] [ drop leave-event ] }
        { [ dup MotionNotify = ] [ drop motion-event ] }
        { [ dup KeyPress = ] [ drop key-down-event ] }
        { [ dup KeyRelease = ] [ drop key-up-event ] }
        { [ dup FocusIn = ] [ drop focus-in-event ] }
        { [ dup FocusOut = ] [ drop focus-out-event ] }
        { [ dup SelectionNotify = ] [ drop selection-notify-event ] }
        { [ dup SelectionRequest = ] [ drop selection-request-event ] }
        { [ dup ClientMessage = ] [ drop client-event ] }
        { [ t ] [ 3drop ] }
    } cond ;

: configured-loc ( event -- dim )
    dup XConfigureEvent-x swap XConfigureEvent-y 2array ;

: configured-dim ( event -- dim )
    dup XConfigureEvent-width swap XConfigureEvent-height 2array ;

: mouse-event-loc ( event -- loc )
    dup XButtonEvent-x swap XButtonEvent-y 2array ;

: close-box? ( event -- ? )
    dup XClientMessageEvent-message_type "WM_PROTOCOLS" x-atom =
    swap XClientMessageEvent-data0 "WM_DELETE_WINDOW" x-atom =
    and ;
