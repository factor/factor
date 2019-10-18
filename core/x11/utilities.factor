! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors hashtables io kernel math
namespaces prettyprint sequences threads ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

: flush-dpy ( -- ) dpy get XFlush drop ;

: x-atom ( string -- atom ) dpy get swap 0 XInternAtom ;

: check-display
    [ "Cannot connect to X server - check $DISPLAY" throw ] unless* ;

: initialize-x ( display-string -- )
    dup [ string>char-alien ] when
    XOpenDisplay check-display dpy set-global
    dpy get XDefaultScreen scr set-global
    dpy get scr get XRootWindow root set-global ;

: close-x ( -- ) dpy get XCloseDisplay drop ;

: with-x ( display-string quot -- )
    >r initialize-x r> [ close-x ] cleanup ;

: configured-loc ( event -- dim )
    dup XConfigureEvent-x swap XConfigureEvent-y 2array ;

: configured-dim ( event -- dim )
    dup XConfigureEvent-width swap XConfigureEvent-height 2array ;

: mouse-event-loc ( event -- loc )
    dup XButtonEvent-x swap XButtonEvent-y 2array ;

: mouse-event>scroll-direction ( event -- pair )
    #! Reminder for myself: 4 is up, 5 is down
    XButtonEvent-button 5 = 1 -1 ? 0 swap 2array ;

: close-box? ( event -- ? )
    dup XClientMessageEvent-message_type "WM_PROTOCOLS" x-atom =
    swap XClientMessageEvent-data0 "WM_DELETE_WINDOW" x-atom =
    and ;
