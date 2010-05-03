! Copyright (C) 2005, 2009 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings continuations io
io.encodings.ascii kernel namespaces x11.xlib x11.io
vocabs vocabs.loader ;
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

{ "x11" "io.backend.unix" } "x11.io.unix" require-when
