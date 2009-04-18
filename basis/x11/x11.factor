! Copyright (C) 2005, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings continuations io io.backend
io.encodings.ascii kernel namespaces x11.xlib
vocabs vocabs.loader calendar threads ;
IN: x11

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

: init-locale ( -- )
   LC_ALL "" setlocale [ "setlocale() failed" print flush ] unless
   XSupportsLocale [ "XSupportsLocale() failed" print flush ] unless ;

: flush-dpy ( -- ) dpy get XFlush drop ;

: x-atom ( string -- atom ) [ dpy get ] dip 0 XInternAtom ;

: check-display ( alien -- alien' )
    [ "Cannot connect to X server - check $DISPLAY" throw ] unless* ;

HOOK: init-x-io io-backend ( -- )

M: object init-x-io ;

HOOK: wait-for-display io-backend ( -- )

M: object wait-for-display 10 milliseconds sleep ;

HOOK: awaken-event-loop io-backend ( -- )

M: object awaken-event-loop ;

: init-x ( display-string -- )
    init-locale
    dup [ ascii string>alien ] when
    XOpenDisplay check-display dpy set-global
    dpy get XDefaultScreen scr set-global
    dpy get scr get XRootWindow root set-global
    init-x-io ;

: close-x ( -- ) dpy get XCloseDisplay drop ;

: with-x ( display-string quot -- )
    [ init-x ] dip [ close-x ] [ ] cleanup ; inline

"io.backend.unix" vocab [ "x11.unix" require ] when