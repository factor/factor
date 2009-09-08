! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.struct combinators kernel
math.order namespaces x11 x11.xlib ;
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
    dpy get XEvent <struct> [ XNextEvent drop ] keep ;

: mask-event ( mask -- event )
    [ dpy get ] dip XEvent <struct> [ XMaskEvent drop ] keep ;

: events-queued ( mode -- n ) [ dpy get ] dip XEventsQueued ;

: wheel? ( event -- ? ) button>> 4 7 between? ;

: button-down-event$ ( event window -- )
    over wheel? [ wheel-event ] [ button-down-event ] if ;

: button-up-event$ ( event window -- )
    over wheel? [ 2drop ] [ button-up-event ] if ;

: handle-event ( event window -- )
    swap dup XAnyEvent>> type>> {
        { Expose [ XExposeEvent>> swap expose-event ] }
        { ConfigureNotify [ XConfigureEvent>> swap configure-event ] }
        { ButtonPress [ XButtonEvent>> swap button-down-event$ ] }
        { ButtonRelease [ XButtonEvent>> swap button-up-event$ ] }
        { EnterNotify [ XCrossingEvent>> swap enter-event ] }
        { LeaveNotify [ XCrossingEvent>> swap leave-event ] }
        { MotionNotify [ XMotionEvent>> swap motion-event ] }
        { KeyPress [ XKeyEvent>> swap key-down-event ] }
        { KeyRelease [ XKeyEvent>> swap key-up-event ] }
        { FocusIn [ XFocusChangeEvent>> swap focus-in-event ] }
        { FocusOut [ XFocusChangeEvent>> swap focus-out-event ] }
        { SelectionNotify [ XSelectionEvent>> swap selection-notify-event ] }
        { SelectionRequest [ XSelectionRequestEvent>> swap selection-request-event ] }
        { ClientMessage [ XClientMessageEvent>> swap client-event ] }
        [ 3drop ]
    } case ;

: event-loc ( event -- loc )
    [ x>> ] [ y>> ] bi 2array ;

: event-dim ( event -- dim )
    [ width>> ] [ height>> ] bi 2array ;

: close-box? ( event -- ? )
    [ message_type>> "WM_PROTOCOLS" x-atom = ]
    [ data0>> "WM_DELETE_WINDOW" x-atom = ]
    bi and ;
