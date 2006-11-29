! Copyright (C) 2005, 2006 Eduardo Cavazos and Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: x11
USING: alien arrays errors gadgets hashtables io kernel math
namespaces prettyprint sequences threads ;

: >int-array ( seq -- <int-array> )
    dup length dup "int" <c-array> -rot
    [ pick set-int-nth ] 2each ;

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
