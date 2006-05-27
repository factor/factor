! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors gadgets hashtables io kernel math
namespaces prettyprint sequences threads ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

: flush-dpy ( -- ) dpy get XFlush drop ;

: sync-dpy ( discard -- ) >r dpy get r> XSync ;

: x-atom ( string -- atom ) dpy get swap 0 XInternAtom ;

: check-display
    [ "Cannot connect to X server - check $DISPLAY" throw ] unless* ;

: initialize-x ( display-string -- )
    XOpenDisplay check-display dpy set
    dpy get XDefaultScreen scr set
    dpy get scr get XRootWindow root set ;

: close-x ( -- ) dpy get XCloseDisplay drop ;
    
: with-x ( display-string quot -- )
    [
        reset-views
        swap initialize-x
        [ close-x ] cleanup
    ] with-scope ;
