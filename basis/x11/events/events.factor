! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays hashtables io kernel math
math.order namespaces prettyprint sequences strings combinators
x11 x11.xlib ;
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
    dpy get "XEvent" <c-object> [ XNextEvent drop ] keep ;

: mask-event ( mask -- event )
    [ dpy get ] dip "XEvent" <c-object> [ XMaskEvent drop ] keep ;

: events-queued ( mode -- n ) [ dpy get ] dip XEventsQueued ;

: wheel? ( event -- ? ) XButtonEvent-button 4 7 between? ;

: button-down-event$ ( event window -- )
    over wheel? [ wheel-event ] [ button-down-event ] if ;

: button-up-event$ ( event window -- )
    over wheel? [ 2drop ] [ button-up-event ] if ;

: handle-event ( event window -- )
    over XAnyEvent-type {
        { Expose [ expose-event ] }
        { ConfigureNotify [ configure-event ] }
        { ButtonPress [ button-down-event$ ] }
        { ButtonRelease [ button-up-event$ ] }
        { EnterNotify [ enter-event ] }
        { LeaveNotify [ leave-event ] }
        { MotionNotify [ motion-event ] }
        { KeyPress [ key-down-event ] }
        { KeyRelease [ key-up-event ] }
        { FocusIn [ focus-in-event ] }
        { FocusOut [ focus-out-event ] }
        { SelectionNotify [ selection-notify-event ] }
        { SelectionRequest [ selection-request-event ] }
        { ClientMessage [ client-event ] }
        [ 3drop ]
    } case ;

: configured-loc ( event -- dim )
    [ XConfigureEvent-x ] [ XConfigureEvent-y ] bi 2array ;

: configured-dim ( event -- dim )
    [ XConfigureEvent-width ] [ XConfigureEvent-height ] bi 2array ;

: mouse-event-loc ( event -- loc )
    [ XButtonEvent-x ] [ XButtonEvent-y ] bi 2array ;

: close-box? ( event -- ? )
    [ XClientMessageEvent-message_type "WM_PROTOCOLS" x-atom = ]
    [ XClientMessageEvent-data0 "WM_DELETE_WINDOW" x-atom = ]
    bi and ;
